import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

import '../geocoder/nominatim_client.dart';
import '../normalizers/direccion_lota.dart';
import '_parse_utils.dart';

/// URL del listado de patentes comerciales mensuales en lotatransparente.cl.
/// Fuente declarada en CLAUDE.md §7 (ig=164).
const String _kUrlPatentesMensuales =
    'https://www.lotatransparente.cl/index.php?ig=164';

/// Scrapea el listado de patentes comerciales y persiste en
/// `patentes_comerciales` con UPSERT por (numero_decreto, fecha_decreto).
///
/// El parseo es tolerante: si la fila no tiene las columnas mínimas o no
/// se puede convertir la fecha/número de decreto, se salta y se loguea.
/// El geocoding se intenta solo si la dirección no es obviamente sin
/// resolución (pabellones mineros, sectores sin nomenclatura formal).
///
/// Campos manuales (`verificado_por`, `ultima_verificacion_terreno`,
/// `observaciones`) se preservan en el UPDATE — el funcionario los carga
/// desde la app y un re-scrape no debe pisarlos.
Future<void> scrapePatentes(
    Session db, Command redis, NominatimClient geocoder) async {
  print('[scraper] patentes: GET $_kUrlPatentesMensuales');

  late http.Response response;
  try {
    response = await http
        .get(Uri.parse(_kUrlPatentesMensuales), headers: kScraperHeaders)
        .timeout(const Duration(seconds: 30));
  } catch (e) {
    print('[scraper] patentes: network error: $e');
    return;
  }

  if (response.statusCode != 200) {
    print('[scraper] patentes: HTTP ${response.statusCode}');
    return;
  }

  final document = parser.parse(response.body);
  var rows = document.querySelectorAll('table tbody tr');
  if (rows.isEmpty) {
    // Algunos sitios no usan <tbody>; intentar fallback genérico.
    final all = document.querySelectorAll('table tr');
    rows = all.where((r) => r.querySelectorAll('td').isNotEmpty).toList();
    print('[scraper] patentes: no tbody, fallback to tr: ${rows.length}');
  }
  print('[scraper] patentes: ${rows.length} rows');

  var inserted = 0;
  var geocoded = 0;
  var skipped = 0;

  for (final row in rows) {
    final cols = row.querySelectorAll('td');
    if (cols.length < 6) {
      skipped++;
      continue;
    }

    // Columnas típicas (best-effort): 0=Nº, 1=Fecha, 2=Tipo, 3=RUT,
    // 4=Razón social, 5=Giro, 6=Dirección. Si el portal cambia el orden,
    // hay que ajustar acá — los logs muestran cuántas filas se saltean.
    final numero = parseIntFlexible(cols[0].text);
    final fecha = parseFechaFlexible(cols[1].text);
    final tipo = cleanCell(cols[2].text);
    final rut = cleanCell(cols[3].text);
    final razon = cleanCell(cols[4].text);
    final giro = cleanCell(cols[5].text);
    final direccionRaw =
        cols.length > 6 ? cleanCell(cols[6].text) ?? '' : '';

    if (numero == null || fecha == null || razon == null) {
      skipped++;
      continue;
    }

    double? lat, lng;
    var confianza = 'fallo';
    String? direccionNormalizada;
    if (direccionRaw.isNotEmpty) {
      direccionNormalizada = normalizarDireccionLota(direccionRaw);
      if (direccionNormalizada != null) {
        final geo = await geocoder.geocode(direccionNormalizada);
        if (geo != null) {
          lat = geo['lat'] as double?;
          lng = geo['lon'] as double?;
          confianza = (geo['confidence'] as String?) ?? 'baja';
          geocoded++;
        }
      }
    }

    final geomEwkt =
        (lat != null && lng != null) ? 'SRID=4326;POINT($lng $lat)' : null;

    try {
      await db.execute(
        Sql.named('''
          INSERT INTO patentes_comerciales (
            numero_decreto, fecha_decreto, tipo_patente, rut, razon_social,
            giro, direccion_raw, direccion_normalizada,
            geom, geocoding_confianza, url_fuente, scraped_at
          ) VALUES (
            @numero, @fecha, @tipo, @rut, @razon,
            @giro, @dir_raw, @dir_norm,
            ST_GeomFromEWKT(@geom), @conf, @url, NOW()
          )
          ON CONFLICT (numero_decreto, fecha_decreto) DO UPDATE SET
            tipo_patente          = EXCLUDED.tipo_patente,
            rut                   = EXCLUDED.rut,
            razon_social          = EXCLUDED.razon_social,
            giro                  = EXCLUDED.giro,
            direccion_raw         = EXCLUDED.direccion_raw,
            direccion_normalizada = EXCLUDED.direccion_normalizada,
            geom                  = COALESCE(EXCLUDED.geom, patentes_comerciales.geom),
            geocoding_confianza   = EXCLUDED.geocoding_confianza,
            url_fuente            = EXCLUDED.url_fuente,
            scraped_at            = NOW(),
            updated_at            = NOW()
        '''),
        parameters: {
          'numero': numero,
          'fecha': fecha.toIso8601String().substring(0, 10),
          'tipo': tipo,
          'rut': rut,
          'razon': razon,
          'giro': giro,
          'dir_raw': direccionRaw,
          'dir_norm': direccionNormalizada,
          'geom': geomEwkt,
          'conf': confianza,
          'url': _kUrlPatentesMensuales,
        },
      );
      inserted++;
    } catch (e) {
      print('[scraper] patentes: insert error for decreto $numero: $e');
    }
  }

  // Marca de último scrape exitoso (24h TTL) — útil para health checks.
  try {
    await redis.send_object([
      'SET',
      'scraper:patentes:last',
      DateTime.now().toIso8601String(),
      'EX',
      '86400',
    ]);
  } catch (_) {/* Redis opcional para health stats */}

  print(
      '[scraper] patentes: inserted/updated=$inserted, geocoded=$geocoded, skipped=$skipped');
}

