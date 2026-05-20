import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

import '../geocoder/nominatim_client.dart';
import '../normalizers/direccion_lota.dart';
import '_parse_utils.dart';

/// Dos URLs de organizaciones sociales en lotatransparente.cl
/// (CLAUDE.md §7):
///   ig=351 → "Organizaciones sociales vigentes"
///   ig=424 → "Organizaciones sociales + registro"
/// Se consultan ambas y se mergeon por `numero_personalidad`.
const String _kUrlOrgsVigentes =
    'https://www.lotatransparente.cl/index.php?ig=351';
const String _kUrlOrgsRegistro =
    'https://www.lotatransparente.cl/index.php?ig=424';

/// Scrapea organizaciones sociales desde las 2 fuentes y persiste en
/// `organizaciones_sociales`. Dedup por `numero_personalidad`.
Future<void> scrapeOrganizaciones(
    Session db, Command redis, NominatimClient geocoder) async {
  final urls = [_kUrlOrgsVigentes, _kUrlOrgsRegistro];

  var totalInserted = 0;
  var totalGeocoded = 0;
  var totalSkipped = 0;

  for (final url in urls) {
    print('[scraper] organizaciones: GET $url');

    late http.Response response;
    try {
      response = await http
          .get(Uri.parse(url), headers: kScraperHeaders)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      print('[scraper] organizaciones: network error en $url: $e');
      continue;
    }

    if (response.statusCode != 200) {
      print('[scraper] organizaciones: HTTP ${response.statusCode} en $url');
      continue;
    }

    final document = parser.parse(response.body);
    var rows = document.querySelectorAll('table tbody tr');
    if (rows.isEmpty) {
      final all = document.querySelectorAll('table tr');
      rows = all.where((r) => r.querySelectorAll('td').isNotEmpty).toList();
    }
    print('[scraper] organizaciones: ${rows.length} rows en $url');

    for (final row in rows) {
      final cols = row.querySelectorAll('td');
      if (cols.length < 4) {
        totalSkipped++;
        continue;
      }

      // Columnas best-effort: 0=Nº personalidad, 1=Tipo, 2=Nombre,
      // 3=Dirección, 4=Representante, 5=RUT representante,
      // 6=Vigencia hasta, 7=Sector.
      final numero = cleanCell(cols[0].text);
      final tipo = cleanCell(cols[1].text);
      final nombre = cleanCell(cols[2].text);
      final direccionRaw = cleanCell(cols[3].text) ?? '';
      final representante =
          cols.length > 4 ? cleanCell(cols[4].text) : null;
      final rutRep = cols.length > 5 ? cleanCell(cols[5].text) : null;
      final vigencia =
          cols.length > 6 ? parseFechaFlexible(cols[6].text) : null;
      final sector = cols.length > 7 ? cleanCell(cols[7].text) : null;

      if (numero == null || nombre == null) {
        totalSkipped++;
        continue;
      }

      double? lat, lng;
      if (direccionRaw.isNotEmpty) {
        final normalizada = normalizarDireccionLota(direccionRaw);
        if (normalizada != null) {
          final geo = await geocoder.geocode(normalizada);
          if (geo != null) {
            lat = geo['lat'] as double?;
            lng = geo['lon'] as double?;
            totalGeocoded++;
          }
        }
      }

      final geomEwkt = (lat != null && lng != null)
          ? 'SRID=4326;POINT($lng $lat)'
          : null;

      try {
        await db.execute(
          Sql.named('''
            INSERT INTO organizaciones_sociales (
              numero_personalidad, tipo, nombre, direccion,
              geom, representante, rut_representante,
              vigencia_hasta, sector, url_fuente, scraped_at
            )
            SELECT
              @numero, @tipo, @nombre, @direccion,
              ST_GeomFromEWKT(@geom), @representante, @rut_rep,
              @vigencia, @sector, @url, NOW()
            WHERE NOT EXISTS (
              SELECT 1 FROM organizaciones_sociales
              WHERE numero_personalidad = @numero
            )
          '''),
          parameters: {
            'numero': numero,
            'tipo': tipo,
            'nombre': nombre,
            'direccion': direccionRaw,
            'geom': geomEwkt,
            'representante': representante,
            'rut_rep': rutRep,
            'vigencia': vigencia?.toIso8601String().substring(0, 10),
            'sector': sector,
            'url': url,
          },
        );
        totalInserted++;
      } catch (e) {
        print(
            '[scraper] organizaciones: insert error para org $numero: $e');
      }
    }
  }

  try {
    await redis.send_object([
      'SET',
      'scraper:organizaciones:last',
      DateTime.now().toIso8601String(),
      'EX',
      '86400',
    ]);
  } catch (_) {}

  print(
      '[scraper] organizaciones: inserted=$totalInserted, geocoded=$totalGeocoded, skipped=$totalSkipped');
}
