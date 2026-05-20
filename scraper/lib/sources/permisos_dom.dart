import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

import '../geocoder/nominatim_client.dart';
import '../normalizers/direccion_lota.dart';
import '_parse_utils.dart';

/// Listado de permisos otorgados por la Dirección de Obras Municipales.
/// Fuente declarada en CLAUDE.md §7 (ig=172).
const String _kUrlPermisosDom =
    'https://www.lotatransparente.cl/index.php?ig=172';

/// Scrapea permisos DOM y los inserta en `permisos_dom` (dedup por
/// numero_permiso vía `WHERE NOT EXISTS` — la tabla no tiene UNIQUE
/// constraint todavía; agregar uno en una migración futura permitirá
/// usar ON CONFLICT y simplificar este bloque).
Future<void> scrapePermisosDom(
    Session db, Command redis, NominatimClient geocoder) async {
  print('[scraper] permisos_dom: GET $_kUrlPermisosDom');

  late http.Response response;
  try {
    response = await http
        .get(Uri.parse(_kUrlPermisosDom), headers: kScraperHeaders)
        .timeout(const Duration(seconds: 30));
  } catch (e) {
    print('[scraper] permisos_dom: network error: $e');
    return;
  }

  if (response.statusCode != 200) {
    print('[scraper] permisos_dom: HTTP ${response.statusCode}');
    return;
  }

  final document = parser.parse(response.body);
  var rows = document.querySelectorAll('table tbody tr');
  if (rows.isEmpty) {
    final all = document.querySelectorAll('table tr');
    rows = all.where((r) => r.querySelectorAll('td').isNotEmpty).toList();
  }
  print('[scraper] permisos_dom: ${rows.length} rows');

  var inserted = 0;
  var geocoded = 0;
  var skipped = 0;

  for (final row in rows) {
    final cols = row.querySelectorAll('td');
    if (cols.length < 4) {
      skipped++;
      continue;
    }

    // Columnas best-effort: 0=Nº permiso, 1=Tipo, 2=Descripción,
    // 3=Dirección, 4=Fecha otorgamiento, 5=Estado.
    final numero = cleanCell(cols[0].text);
    final tipo = cleanCell(cols[1].text);
    final descripcion = cleanCell(cols[2].text);
    final direccionRaw = cleanCell(cols[3].text) ?? '';
    final fecha = cols.length > 4 ? parseFechaFlexible(cols[4].text) : null;
    final estado = cols.length > 5 ? cleanCell(cols[5].text) : null;

    if (numero == null) {
      skipped++;
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
          geocoded++;
        }
      }
    }

    final geomEwkt =
        (lat != null && lng != null) ? 'SRID=4326;POINT($lng $lat)' : null;

    try {
      // Dedup: solo insertar si no existe un permiso con ese número.
      // (La tabla no tiene UNIQUE — esto sustituye al ON CONFLICT.)
      await db.execute(
        Sql.named('''
          INSERT INTO permisos_dom (
            numero_permiso, tipo, descripcion, direccion_raw,
            geom, fecha_otorgamiento, estado, url_fuente, scraped_at
          )
          SELECT
            @numero, @tipo, @descripcion, @dir_raw,
            ST_GeomFromEWKT(@geom), @fecha, @estado, @url, NOW()
          WHERE NOT EXISTS (
            SELECT 1 FROM permisos_dom WHERE numero_permiso = @numero
          )
        '''),
        parameters: {
          'numero': numero,
          'tipo': tipo,
          'descripcion': descripcion,
          'dir_raw': direccionRaw,
          'geom': geomEwkt,
          'fecha': fecha?.toIso8601String().substring(0, 10),
          'estado': estado,
          'url': _kUrlPermisosDom,
        },
      );
      inserted++;
    } catch (e) {
      print('[scraper] permisos_dom: insert error for permiso $numero: $e');
    }
  }

  try {
    await redis.send_object([
      'SET',
      'scraper:permisos_dom:last',
      DateTime.now().toIso8601String(),
      'EX',
      '86400',
    ]);
  } catch (_) {}

  print(
      '[scraper] permisos_dom: inserted=$inserted, geocoded=$geocoded, skipped=$skipped');
}
