import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';
import '../geocoder/nominatim_client.dart';
import '../normalizers/direccion_lota.dart';
import '../progress.dart';

// ig=351: Registros Públicos de Organizaciones Vigentes
// Flujo:  plantillas_selec_archivo&ig=351&a=[año]
//         → 3 categorías: Junta de Vecinos, Org. Comunitarias Funcionales, Unión Comunal
//         → tabla HTML: N°, Tipo, Nombre, Rol/PJ, Fecha Concesión PJ, N° Reg. Civil,
//                       Sede/Funcionamiento, Directiva, Vigencia, Fecha Mod., Vencimiento

const _base = 'https://www.lotatransparente.cl';
const _ua = 'SigespuLota/1.0 (+contacto@munilota.cl)';

Future<void> scrapeOrganizaciones(
    Session db, Command redis, NominatimClient geocoder,
    {int? year, ProgressTracker? tracker}) async {
  final y = year ?? DateTime.now().year;
  await tracker?.stepStart(
      fuente: 'organizaciones', label: 'Organizaciones $y');
  print('[organizaciones] Iniciando — año=$y');

  final indexUrl =
      '$_base/index.php?action=plantillas_selec_archivo&ig=351&a=$y';
  final indexBody = await _get(indexUrl);
  if (indexBody == null) return;

  final doc = html.parse(indexBody);
  // Los enlaces tienen la forma: ?action=plantillas_generar_plantilla&ig=351&m=X&a=YYYY&ia=XXXXX
  final categoryAnchors = doc
      .querySelectorAll('a[href]')
      .where((a) =>
          (a.attributes['href'] ?? '').contains('plantillas_generar_plantilla') &&
          (a.attributes['href'] ?? '').contains('ig=351'))
      .toList();

  if (categoryAnchors.isEmpty) {
    print('[organizaciones] Sin categorías en el índice — abortando');
    return;
  }

  print('[organizaciones] ${categoryAnchors.length} categorías encontradas');

  for (final anchor in categoryAnchors) {
    await ProgressTracker.throwIfCancelled(redis);
    final href = anchor.attributes['href'] ?? '';
    final url = href.startsWith('http') ? href : '$_base/$href';
    // Usar el texto del enlace como nombre del sector
    final sector = anchor.text.trim().isNotEmpty
        ? anchor.text.trim()
        : _sectorFromUrl(url);

    await _processCategoria(db, redis, geocoder, url, sector, tracker);
    await Future.delayed(const Duration(milliseconds: 700));
  }

  print('[organizaciones] Scraping completo');
}

/// Itera años hacia atrás (por defecto desde 2020).
Future<void> scrapeOrganizacionesHistorico(
    Session db, Command redis, NominatimClient geocoder,
    {int yearFrom = 2020, int? yearTo, ProgressTracker? tracker}) async {
  final to = yearTo ?? DateTime.now().year;
  for (var y = yearFrom; y <= to; y++) {
    await scrapeOrganizaciones(db, redis, geocoder, year: y, tracker: tracker);
  }
}

Future<void> _processCategoria(Session db, Command redis,
    NominatimClient geocoder, String url, String sector,
    ProgressTracker? tracker) async {
  final body = await _get(url);
  if (body == null) return;

  final doc = html.parse(body);
  int ok = 0, err = 0;

  // Reemplazar registros del sector para mantener datos frescos
  // Se hace por lotes: delete + insert en la misma transacción conceptual
  await db.execute(
    Sql.named('DELETE FROM organizaciones_sociales WHERE sector = @sector'),
    parameters: {'sector': sector},
  );

  for (final row in doc.querySelectorAll('table tr')) {
    await ProgressTracker.throwIfCancelled(redis);
    final cells = row.querySelectorAll('td');
    if (cells.length < 10) continue; // saltar encabezados y filas incompletas

    // Columnas (índice 0-based):
    // 0:N°  1:Tipo Organización  2:Nombre  3:Rol/PJ  4:Fecha Concesión PJ
    // 5:N° Inscripción Registro Civil  6:Sede/Funcionamiento
    // 7:Directiva  8:Vigencia PJ  9:Fecha Modificaciones  10:Vencimiento

    final tipo = cells[1].text.trim();
    final nombre = cells[2].text.trim();
    if (nombre.isEmpty || nombre == 'Nombre') continue;

    final rolMunicipalidad = cells[3].text.trim(); // Rol/PJ
    final fechaConcesionStr = cells[4].text.trim(); // DD-MM-YYYY
    final numInscripcion = cells[5].text.trim();
    final sede = cells[6].text.trim();
    final directivaRaw = cells[7].text.trim();
    final fechaModStr = cells[9].text.trim(); // DD-MM-YYYY
    final vencimientoStr = cells[10].text.trim(); // DD-MM-YYYY

    // numero_personalidad: usar Rol/PJ si disponible, si no N° inscripción
    final numeroPers = rolMunicipalidad.isNotEmpty ? rolMunicipalidad : numInscripcion;

    // Representante: primer nombre de la lista de la directiva
    final representante = _extractRepresentante(directivaRaw);

    final fechaConcesionDate = _parseDate(fechaConcesionStr);
    final fechaConcesionIso = fechaConcesionDate != null ? _isoDate(fechaConcesionDate) : null;
    final fechaModDate = _parseDate(fechaModStr);
    final fechaModIso = fechaModDate != null ? _isoDate(fechaModDate) : null;
    final vencimientoDate = _parseDate(vencimientoStr);
    final vencimientoIso = vencimientoDate != null ? _isoDate(vencimientoDate) : null;

    final rawData = jsonEncode({
      'rol_municipalidad': rolMunicipalidad,
      'n_inscripcion_registro_civil': numInscripcion,
      'directiva': directivaRaw,
      'fecha_concesion': fechaConcesionStr,
      'fecha_modificaciones': fechaModStr,
      'vencimiento': vencimientoStr,
      'sede': sede,
    });

    // Geocoding de sede con caché Redis
    double? lat, lng;
    String confianza = 'fallo';

    if (sede.isNotEmpty) {
      final sedeNorm = normalizarDireccionLota(sede);
      if (sedeNorm != null) {
        final cacheKey = 'geocode:${Uri.encodeComponent(sedeNorm)}';
        final cached = await redis.send_object(['GET', cacheKey]);
        if (cached != null && cached is String) {
          final geo = jsonDecode(cached) as Map;
          lat = (geo['lat'] as num?)?.toDouble();
          lng = (geo['lng'] as num?)?.toDouble();
          confianza = (geo['confianza'] as String?) ?? 'fallo';
        } else {
          final geo = await geocoder.geocode(sedeNorm);
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
            // Negative caching (7 días)
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

    try {
      if (lat != null && lng != null) {
        await db.execute(
          Sql.named('''
            INSERT INTO organizaciones_sociales (
              id, numero_personalidad, tipo, nombre, direccion,
              geom, representante, vigencia_hasta, sector, url_fuente, scraped_at,
              rol_municipalidad, n_inscripcion_registro_civil, directiva,
              fecha_concesion, fecha_modificaciones, geocoding_confianza, raw_data
            ) VALUES (
              gen_random_uuid(), @numeroPers, @tipo, @nombre, @sede,
              ST_SetSRID(ST_MakePoint(@lng, @lat), 4326),
              @rep, @vig::date, @sector, @url, NOW(),
              @rolMun, @numInscripcion, @directiva,
              @fechaConcesion::date, @fechaMod::date, @confianza, @raw::jsonb
            )
          '''),
          parameters: {
            'numeroPers': numeroPers,
            'tipo': tipo,
            'nombre': nombre,
            'sede': sede,
            'lng': lng,
            'lat': lat,
            'rep': representante,
            'vig': vencimientoIso,
            'sector': sector,
            'url': url,
            'rolMun': rolMunicipalidad.isNotEmpty ? rolMunicipalidad : null,
            'numInscripcion': numInscripcion.isNotEmpty ? numInscripcion : null,
            'directiva': directivaRaw.isNotEmpty ? directivaRaw : null,
            'fechaConcesion': fechaConcesionIso,
            'fechaMod': fechaModIso,
            'confianza': confianza,
            'raw': rawData,
          },
        );
      } else {
        await db.execute(
          Sql.named('''
            INSERT INTO organizaciones_sociales (
              id, numero_personalidad, tipo, nombre, direccion,
              representante, vigencia_hasta, sector, url_fuente, scraped_at,
              rol_municipalidad, n_inscripcion_registro_civil, directiva,
              fecha_concesion, fecha_modificaciones, geocoding_confianza, raw_data
            ) VALUES (
              gen_random_uuid(), @numeroPers, @tipo, @nombre, @sede,
              @rep, @vig::date, @sector, @url, NOW(),
              @rolMun, @numInscripcion, @directiva,
              @fechaConcesion::date, @fechaMod::date, @confianza, @raw::jsonb
            )
          '''),
          parameters: {
            'numeroPers': numeroPers,
            'tipo': tipo,
            'nombre': nombre,
            'sede': sede,
            'rep': representante,
            'vig': vencimientoIso,
            'sector': sector,
            'url': url,
            'rolMun': rolMunicipalidad.isNotEmpty ? rolMunicipalidad : null,
            'numInscripcion': numInscripcion.isNotEmpty ? numInscripcion : null,
            'directiva': directivaRaw.isNotEmpty ? directivaRaw : null,
            'fechaConcesion': fechaConcesionIso,
            'fechaMod': fechaModIso,
            'confianza': confianza,
            'raw': rawData,
          },
        );
      }
      ok++;
    } catch (e) {
      print('[organizaciones] Error "$nombre": $e');
      err++;
    }
  }

  tracker?.addOk(ok);
  tracker?.addErr(err);
  await tracker?.tick();
  print('[organizaciones] $sector — $ok insertados, $err errores');
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

// Extrae el primer nombre de la directiva (formato: "Nombre Apellido, Nombre Apellido, ...")
String? _extractRepresentante(String directiva) {
  if (directiva.isEmpty || directiva == 'Sin información') return null;
  final firstEntry = directiva.split(',').first.trim();
  return firstEntry.isNotEmpty ? firstEntry : null;
}

String _sectorFromUrl(String url) {
  final ia = Uri.parse(url).queryParameters['ia'] ?? '';
  return 'categoria_$ia';
}

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
    print('[organizaciones] HTTP ${r.statusCode} — $url');
    return null;
  } catch (e) {
    print('[organizaciones] Fetch error $url: $e');
    return null;
  }
}
