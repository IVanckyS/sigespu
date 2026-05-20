import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

import '_parse_utils.dart';

/// Listado de decretos de tránsito (cortes de calle, desvíos, restricciones).
/// Fuente declarada en CLAUDE.md §7 (ig=269).
const String _kUrlDecretosTransito =
    'https://www.lotatransparente.cl/index.php?ig=269';

/// Scrapea decretos de tránsito. No requiere geocoder porque guarda la
/// `direccion_afectada` como texto libre — un decreto suele afectar un
/// tramo o sector, no un punto específico geocodificable.
///
/// Dedup por `numero_decreto` con WHERE NOT EXISTS (sin UNIQUE constraint).
Future<void> scrapeDecretosTransito(Session db, Command redis) async {
  print('[scraper] decretos_transito: GET $_kUrlDecretosTransito');

  late http.Response response;
  try {
    response = await http
        .get(Uri.parse(_kUrlDecretosTransito), headers: kScraperHeaders)
        .timeout(const Duration(seconds: 30));
  } catch (e) {
    print('[scraper] decretos_transito: network error: $e');
    return;
  }

  if (response.statusCode != 200) {
    print('[scraper] decretos_transito: HTTP ${response.statusCode}');
    return;
  }

  final document = parser.parse(response.body);
  var rows = document.querySelectorAll('table tbody tr');
  if (rows.isEmpty) {
    final all = document.querySelectorAll('table tr');
    rows = all.where((r) => r.querySelectorAll('td').isNotEmpty).toList();
  }
  print('[scraper] decretos_transito: ${rows.length} rows');

  var inserted = 0;
  var skipped = 0;

  for (final row in rows) {
    final cols = row.querySelectorAll('td');
    if (cols.length < 4) {
      skipped++;
      continue;
    }

    // Columnas best-effort: 0=Nº decreto, 1=Tipo, 2=Descripción,
    // 3=Dirección afectada, 4=Fecha inicio, 5=Fecha fin, 6=Estado.
    final numero = cleanCell(cols[0].text);
    final tipo = cleanCell(cols[1].text);
    final descripcion = cleanCell(cols[2].text);
    final direccion = cleanCell(cols[3].text);
    final fechaInicio =
        cols.length > 4 ? parseFechaFlexible(cols[4].text) : null;
    final fechaFin = cols.length > 5 ? parseFechaFlexible(cols[5].text) : null;
    final estado = cols.length > 6 ? cleanCell(cols[6].text) : null;

    if (numero == null) {
      skipped++;
      continue;
    }

    try {
      await db.execute(
        Sql.named('''
          INSERT INTO decretos_transito (
            numero_decreto, tipo, descripcion, direccion_afectada,
            fecha_inicio, fecha_fin, estado, url_fuente, scraped_at
          )
          SELECT
            @numero, @tipo, @descripcion, @direccion,
            @fecha_inicio, @fecha_fin, @estado, @url, NOW()
          WHERE NOT EXISTS (
            SELECT 1 FROM decretos_transito WHERE numero_decreto = @numero
          )
        '''),
        parameters: {
          'numero': numero,
          'tipo': tipo,
          'descripcion': descripcion,
          'direccion': direccion,
          'fecha_inicio': fechaInicio?.toIso8601String().substring(0, 10),
          'fecha_fin': fechaFin?.toIso8601String().substring(0, 10),
          'estado': estado,
          'url': _kUrlDecretosTransito,
        },
      );
      inserted++;
    } catch (e) {
      print(
          '[scraper] decretos_transito: insert error for decreto $numero: $e');
    }
  }

  try {
    await redis.send_object([
      'SET',
      'scraper:decretos_transito:last',
      DateTime.now().toIso8601String(),
      'EX',
      '86400',
    ]);
  } catch (_) {}

  print('[scraper] decretos_transito: inserted=$inserted, skipped=$skipped');
}
