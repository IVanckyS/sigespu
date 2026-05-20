import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';
import '../geocoder/nominatim_client.dart';
import '../progress.dart';

// ig=172: Permisos Dirección de Obras Municipales
// Flujo:  plantillas_selec_fecha&ig=172
//         → enlaces plantillas_selec_archivo&ig=172&m=[mes]&a=[año]  (por mes)
//         → tabla HTML con los actos/resoluciones de ese mes:
//           N°, AÑO, MES, TIPOLOGÍA DEL ACTO, TIPO DE ACTO, DENOMINACIÓN,
//           NÚMERO DEL ACTO, FECHA, Fecha publicación, Medio publicidad,
//           EFECTOS GENERALES, Fecha actualización, DESCRIPCIÓN, Enlace, Enlace modificación

const _base = 'https://www.lotatransparente.cl';
const _ua = 'SigespuLota/1.0 (+contacto@munilota.cl)';

Future<void> scrapePermisosDom(
    Connection db, Command redis, NominatimClient geocoder,
    {int? maxMonths = 6, ProgressTracker? tracker}) async {
  await tracker?.stepStart(
      fuente: 'permisos_dom',
      label: maxMonths == null
          ? 'Permisos DOM (todos los meses)'
          : 'Permisos DOM (últimos $maxMonths meses)');
  print('[permisos_dom] Iniciando scraping (maxMonths=$maxMonths)');

  // 1. Obtener listado de meses disponibles
  final navBody = await _get('$_base/index.php?action=plantillas_selec_fecha&ig=172');
  if (navBody == null) return;

  final navDoc = html.parse(navBody);
  // Los enlaces tienen la forma: ?action=plantillas_selec_archivo&ig=172&m=X&a=YYYY
  final monthLinks = navDoc
      .querySelectorAll('a[href]')
      .map((a) => a.attributes['href'] ?? '')
      .where((h) =>
          h.contains('plantillas_selec_archivo') &&
          h.contains('ig=172') &&
          h.contains('m=') &&
          h.contains('a='))
      .map((h) => h.startsWith('http') ? h : '$_base/$h')
      .toList();

  if (monthLinks.isEmpty) {
    print('[permisos_dom] Sin meses disponibles — abortando');
    return;
  }

  final selected = maxMonths == null ? monthLinks : monthLinks.take(maxMonths).toList();
  print('[permisos_dom] Procesando ${selected.length} meses');

  for (final url in selected) {
    await _processMes(db, url, tracker);
    await Future.delayed(const Duration(milliseconds: 600));
  }

  print('[permisos_dom] Scraping completo');
}

Future<void> _processMes(Connection db, String url, ProgressTracker? tracker) async {
  final body = await _get(url);
  if (body == null) return;

  final doc = html.parse(body);
  int ok = 0, err = 0;

  for (final row in doc.querySelectorAll('table tr')) {
    final cells = row.querySelectorAll('td');
    if (cells.length < 13) continue; // saltar encabezados y filas incompletas

    // Columnas de la tabla (índice 0-based):
    // 0:N°  1:AÑO  2:MES  3:TIPOLOGÍA  4:TIPO ACTO  5:DENOMINACIÓN
    // 6:NÚMERO ACTO  7:FECHA  8:Fecha publicación  9:Medio
    // 10:EFECTOS GENERALES  11:Última actualización  12:DESCRIPCIÓN
    // 13:Enlace publicación  14:Enlace modificación

    final numeroActo = cells[6].text.trim();
    if (numeroActo.isEmpty || numeroActo == 'NÚMERO DEL ACTO') continue;

    final tipologia = cells[3].text.trim();
    final tipoActo = cells[4].text.trim();
    final denominacion = cells[5].text.trim();
    final fechaStr = cells[7].text.trim(); // DD-MM-YYYY
    final descripcion = cells[12].text.trim();

    // Obtener href del enlace (columna 13 si existe)
    String? urlFuente;
    if (cells.length > 13) {
      final enlaceAnchor = cells[13].querySelector('a');
      urlFuente = enlaceAnchor?.attributes['href'];
      if (urlFuente != null && !urlFuente.startsWith('http')) {
        urlFuente = '$_base/$urlFuente';
      }
    }

    final fechaDate = _parseDate(fechaStr);
    final fechaIso = fechaDate != null ? _isoDate(fechaDate) : null;

    // tipo combina tipología + tipo de acto para mayor especificidad
    final tipo = [tipologia, tipoActo].where((s) => s.isNotEmpty).join(' — ');

    final rawData = jsonEncode({
      'numero_acto': numeroActo,
      'tipologia': tipologia,
      'tipo_acto': tipoActo,
      'denominacion': denominacion,
      'fecha': fechaStr,
      'descripcion': descripcion,
      'url_fuente': urlFuente,
      'url_mes': url,
    });

    try {
      // Verificar si ya existe para evitar duplicados (sin UNIQUE en el schema)
      final exists = await db.execute(
        Sql.named(
            'SELECT 1 FROM permisos_dom WHERE numero_permiso = @num AND url_fuente IS NOT DISTINCT FROM @urlFuente LIMIT 1'),
        parameters: {'num': numeroActo, 'urlFuente': urlFuente},
      );

      if (exists.isNotEmpty) {
        ok++;
        continue;
      }

      await db.execute(
        Sql.named('''
          INSERT INTO permisos_dom (
            id, numero_permiso, tipo, descripcion,
            fecha_otorgamiento, estado, url_fuente, scraped_at, raw_data
          ) VALUES (
            gen_random_uuid(), @num, @tipo, @desc,
            @fecha::date, @estado, @urlFuente, NOW(), @raw::jsonb
          )
        '''),
        parameters: {
          'num': numeroActo,
          'tipo': tipo.isNotEmpty ? tipo : denominacion,
          'desc': descripcion,
          'fecha': fechaIso,
          'estado': 'publicado',
          'urlFuente': urlFuente,
          'raw': rawData,
        },
      );
      ok++;
    } catch (e) {
      print('[permisos_dom] Error N° $numeroActo: $e');
      err++;
    }
  }

  tracker?.addOk(ok);
  tracker?.addErr(err);
  await tracker?.tick();

  final params = Uri.parse(url).queryParameters;
  print('[permisos_dom] m=${params['m']} a=${params['a']} — $ok OK, $err errores');
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
    print('[permisos_dom] HTTP ${r.statusCode} — $url');
    return null;
  } catch (e) {
    print('[permisos_dom] Fetch error $url: $e');
    return null;
  }
}
