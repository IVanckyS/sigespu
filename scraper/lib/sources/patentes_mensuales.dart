import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';
import '../geocoder/nominatim_client.dart';
import '../normalizers/direccion_lota.dart';
import '../progress.dart';

// ig=103: Patentes por categoría semestral
// Flujo:  plantillas_selec_archivo&ig=103&m=[semestre]&a=[año]
//         → enlaces plantillas_generar_plantilla&ig=103&...&ia=XXXXX (una por categoría)
//         → tabla HTML: N°, ROL, R.U.T., NOMBRE, DIRECCION, GIRO, FECHA, MONTO, PATENTE

const _base = 'https://www.lotatransparente.cl';
const _ua = 'SigespuLota/1.0 (+contacto@munilota.cl)';

Future<void> scrapePatentes(
    Connection db, Command redis, NominatimClient geocoder,
    {int? year, int? semester, ProgressTracker? tracker}) async {
  final now = DateTime.now();
  final y = year ?? now.year;
  final s = semester ?? (now.month <= 6 ? 1 : 2);
  await tracker?.stepStart(fuente: 'patentes', label: 'Patentes $y S$s');
  print('[patentes] Iniciando — año=$y semestre=$s');

  final indexUrl =
      '$_base/index.php?action=plantillas_selec_archivo&ig=103&m=$s&a=$y';
  final indexBody = await _get(indexUrl);
  if (indexBody == null) return;

  final doc = html.parse(indexBody);
  final dataLinks = doc
      .querySelectorAll('a[href]')
      .map((a) => a.attributes['href'] ?? '')
      .where((h) =>
          h.contains('plantillas_generar_plantilla') && h.contains('ig=103'))
      .map((h) => h.startsWith('http') ? h : '$_base/$h')
      .toList();

  if (dataLinks.isEmpty) {
    print('[patentes] Sin categorías en el índice — abortando');
    return;
  }

  print('[patentes] ${dataLinks.length} categorías encontradas');

  for (final url in dataLinks) {
    await _processCategoria(db, redis, geocoder, url, y, s, tracker);
    await Future.delayed(const Duration(milliseconds: 700));
  }

  print('[patentes] Scraping completo');
}

/// Itera años/semestres en modo histórico. Por defecto desde 2022 hasta hoy.
Future<void> scrapePatentesHistorico(
    Connection db, Command redis, NominatimClient geocoder,
    {int yearFrom = 2022, int? yearTo, ProgressTracker? tracker}) async {
  final now = DateTime.now();
  final to = yearTo ?? now.year;
  for (var y = yearFrom; y <= to; y++) {
    final lastSem = (y == now.year && now.month <= 6) ? 1 : 2;
    for (var s = 1; s <= lastSem; s++) {
      await scrapePatentes(db, redis, geocoder, year: y, semester: s, tracker: tracker);
    }
  }
}

Future<void> _processCategoria(
    Connection db,
    Command redis,
    NominatimClient geocoder,
    String url,
    int y,
    int s,
    ProgressTracker? tracker) async {
  final body = await _get(url);
  if (body == null) return;

  final doc = html.parse(body);
  int ok = 0, err = 0;

  for (final row in doc.querySelectorAll('table tr')) {
    final cells = row.querySelectorAll('td');
    if (cells.length < 8) continue; // saltar encabezados (th) y filas vacías

    final rolStr = cells[1].text.trim();
    final rol = int.tryParse(rolStr.replaceAll(RegExp(r'[^\d]'), ''));
    if (rol == null || rol == 0) continue;

    final rut = cells[2].text.trim();
    final nombre = cells[3].text.trim();
    final direccionRaw = cells[4].text.trim();
    final giro = cells[5].text.trim();
    
    // El formato cambió en 2024: desapareció la columna FECHA (ahora son 8 columnas)
    final isOldFormat = cells.length >= 9;
    String fechaStr;
    String monto;
    String tipoPatente;

    if (isOldFormat) {
      fechaStr = cells[6].text.trim();
      monto = cells[7].text.trim();
      tipoPatente = cells[8].text.trim();
    } else {
      monto = cells[6].text.trim();
      tipoPatente = cells[7].text.trim();
      // Usar fecha nominal del semestre
      fechaStr = s == 1 ? '01-01-$y' : '01-07-$y';
    }

    if (nombre.isEmpty) continue;

    final fechaDecretoDate = _parseDate(fechaStr);
    if (fechaDecretoDate == null) continue; // requerido para UNIQUE(numero_decreto, fecha_decreto)

    final fechaIso = _isoDate(fechaDecretoDate);

    // ─── Geocoding con caché Redis (30 días) ─────────────────────────────────
    double? lat, lng;
    String confianza = 'fallo';
    String? direccionNorm;

    if (direccionRaw.isNotEmpty) {
      direccionNorm = normalizarDireccionLota(direccionRaw);
      if (direccionNorm != null) {
        final cacheKey = 'geocode:${Uri.encodeComponent(direccionNorm)}';
        final cached = await redis.send_object(['GET', cacheKey]);
        if (cached != null && cached is String) {
          final geo = jsonDecode(cached) as Map;
          lat = (geo['lat'] as num?)?.toDouble();
          lng = (geo['lng'] as num?)?.toDouble();
          confianza = (geo['confianza'] as String?) ?? 'fallo';
        } else {
          final geo = await geocoder.geocode(direccionNorm);
          if (geo != null) {
            lat = (geo['lat'] as num).toDouble();
            lng = (geo['lon'] as num).toDouble();
            confianza = 'alta';
            await redis.send_object([
              'SET',
              cacheKey,
              jsonEncode({'lat': lat, 'lng': lng, 'confianza': confianza}),
              'EX',
              '2592000',
            ]);
          } else {
            // Negative caching: cache the failure for 7 days
            await redis.send_object([
              'SET',
              cacheKey,
              jsonEncode({'lat': null, 'lng': null, 'confianza': 'fallo'}),
              'EX',
              '604800',
            ]);
          }
        }
      }
    }

    final rawData = jsonEncode({
      'rol': rolStr,
      'rut': rut,
      'nombre': nombre,
      'direccion': direccionRaw,
      'giro': giro,
      'fecha_otorgamiento': fechaStr,
      'monto': monto,
      'tipo_patente': tipoPatente,
    });

    try {
      if (lat != null && lng != null) {
        await db.execute(
          Sql.named('''
            INSERT INTO patentes_comerciales (
              id, numero_decreto, fecha_decreto, tipo_patente, rut,
              razon_social, giro, direccion_raw, direccion_normalizada,
              geom, geocoding_confianza, url_fuente, scraped_at, raw_data
            ) VALUES (
              gen_random_uuid(), @rol, @fecha::date, @tipo, @rut,
              @nombre, @giro, @dirRaw, @dirNorm,
              ST_SetSRID(ST_MakePoint(@lng, @lat), 4326),
              @confianza, @url, NOW(), @raw::jsonb
            )
            ON CONFLICT (numero_decreto, fecha_decreto) DO UPDATE SET
              razon_social          = EXCLUDED.razon_social,
              giro                  = EXCLUDED.giro,
              direccion_raw         = EXCLUDED.direccion_raw,
              direccion_normalizada = EXCLUDED.direccion_normalizada,
              geom                  = COALESCE(EXCLUDED.geom, patentes_comerciales.geom),
              geocoding_confianza   = EXCLUDED.geocoding_confianza,
              scraped_at            = EXCLUDED.scraped_at,
              raw_data              = EXCLUDED.raw_data
          '''),
          parameters: {
            'rol': rol,
            'fecha': fechaIso,
            'tipo': tipoPatente,
            'rut': rut,
            'nombre': nombre,
            'giro': giro,
            'dirRaw': direccionRaw,
            'dirNorm': direccionNorm,
            'lng': lng,
            'lat': lat,
            'confianza': confianza,
            'url': url,
            'raw': rawData,
          },
        );
      } else {
        await db.execute(
          Sql.named('''
            INSERT INTO patentes_comerciales (
              id, numero_decreto, fecha_decreto, tipo_patente, rut,
              razon_social, giro, direccion_raw, direccion_normalizada,
              geocoding_confianza, url_fuente, scraped_at, raw_data
            ) VALUES (
              gen_random_uuid(), @rol, @fecha::date, @tipo, @rut,
              @nombre, @giro, @dirRaw, @dirNorm,
              @confianza, @url, NOW(), @raw::jsonb
            )
            ON CONFLICT (numero_decreto, fecha_decreto) DO UPDATE SET
              razon_social  = EXCLUDED.razon_social,
              giro          = EXCLUDED.giro,
              direccion_raw = EXCLUDED.direccion_raw,
              scraped_at    = EXCLUDED.scraped_at,
              raw_data      = EXCLUDED.raw_data
          '''),
          parameters: {
            'rol': rol,
            'fecha': fechaIso,
            'tipo': tipoPatente,
            'rut': rut,
            'nombre': nombre,
            'giro': giro,
            'dirRaw': direccionRaw,
            'dirNorm': direccionNorm,
            'confianza': confianza,
            'url': url,
            'raw': rawData,
          },
        );
      }
      ok++;
    } catch (e) {
      print('[patentes] Error ROL $rol: $e');
      err++;
    }
  }

  tracker?.addOk(ok);
  tracker?.addErr(err);
  await tracker?.tick();

  final ia = Uri.parse(url).queryParameters['ia'] ?? url;
  print('[patentes] ia=$ia — $ok insertados/actualizados, $err errores');
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

DateTime? _parseDate(String s) {
  final parts = s.trim().split(RegExp(r'[-/]'));
  if (parts.length != 3) return null;
  try {
    return DateTime(
        int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  } catch (_) {
    return null;
  }
}

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

Future<String?> _get(String url) async {
  try {
    final r = await http.get(Uri.parse(url), headers: {'User-Agent': _ua});
    if (r.statusCode == 200) return r.body;
    print('[patentes] HTTP ${r.statusCode} — $url');
    return null;
  } catch (e) {
    print('[patentes] Fetch error $url: $e');
    return null;
  }
}
