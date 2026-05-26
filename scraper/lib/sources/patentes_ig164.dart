import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';
import '../progress.dart';

// ig=164: Patentes comerciales por decreto (Actos y Resoluciones)
// Flujo:  plantillas_selec_archivo&ig=164&a=[año]
//         → enlaces plantillas_generar_plantilla&ig=164&m=X&a=Y&ia=XXXXX (por mes)
//         → tabla HTML de 15 cols: N°, Año, Mes, Tipología, Tipo_acto, Denominación,
//           Número_acto, Fecha, Fecha_publicacion, Medio, Efectos_generales,
//           Fecha_actualización, Descripción, Enlace, Enlace_mod
// La Descripción contiene texto tipo:
//   "Otorga Patente Comercial Definitiva a ELYSIUM STUDIO SpA, Rut: 78.200.042-K, Giro: Peluquería y Bazar"
// No hay columna de dirección → geom siempre NULL.

const _base = 'https://www.lotatransparente.cl';
const _ua = 'SigespuLota/1.0 (+contacto@munilota.cl)';

Future<void> scrapePatentesIg164(
    Session db, Command redis,
    {int? year, ProgressTracker? tracker}) async {
  final now = DateTime.now();
  final y = year ?? now.year;
  await tracker?.stepStart(fuente: 'patentes_ig164', label: 'Patentes Decretos $y');
  print('[patentes_ig164] Iniciando — año=$y');

  final indexUrl = '$_base/index.php?action=plantillas_selec_archivo&ig=164&a=$y';
  final indexBody = await _get(indexUrl);
  if (indexBody == null) return;

  final doc = html.parse(indexBody);
  final dataAnchors = doc
      .querySelectorAll('a[href]')
      .where((a) =>
          (a.attributes['href'] ?? '').contains('plantillas_generar_plantilla') &&
          (a.attributes['href'] ?? '').contains('ig=164'))
      .toList();

  if (dataAnchors.isEmpty) {
    print('[patentes_ig164] Sin datos en el índice — abortando');
    return;
  }

  print('[patentes_ig164] ${dataAnchors.length} páginas encontradas');

  for (final anchor in dataAnchors) {
    await ProgressTracker.throwIfCancelled(redis);
    final href = anchor.attributes['href'] ?? '';
    final url = href.startsWith('http') ? href : '$_base/$href';
    await _processPagina(db, redis, url, tracker);
    await Future.delayed(const Duration(milliseconds: 600));
  }

  print('[patentes_ig164] Scraping completo');
}

/// Itera años hacia atrás en modo histórico.
Future<void> scrapePatentesIg164Historico(
    Session db, Command redis,
    {int yearFrom = 2022, int? yearTo, ProgressTracker? tracker}) async {
  final to = yearTo ?? DateTime.now().year;
  for (var y = yearFrom; y <= to; y++) {
    await scrapePatentesIg164(db, redis, year: y, tracker: tracker);
  }
}

Future<void> _processPagina(Session db, Command redis, String url, ProgressTracker? tracker) async {
  final body = await _get(url);
  if (body == null) return;

  final doc = html.parse(body);
  int ok = 0, err = 0, rowNum = 0;

  for (final row in doc.querySelectorAll('table tr')) {
    final cells = row.querySelectorAll('td');
    if (cells.length < 13) continue; // saltar encabezados y filas incompletas
    rowNum++;

    // Columnas (índice 0-based):
    // 0:N°  1:Año  2:Mes  3:Tipología  4:Tipo_acto  5:Denominación
    // 6:Número_acto  7:Fecha  8:Fecha_publicacion  9:Medio
    // 10:Efectos_generales  11:Fecha_actualización  12:Descripción
    // 13:Enlace  14:Enlace_mod (opcional)

    final numeroActo = cells[6].text.trim();
    if (numeroActo.isEmpty || numeroActo == 'NÚMERO DEL ACTO' || numeroActo == 'Número_acto') continue;

    final numeroDecretoInt = int.tryParse(numeroActo.replaceAll(RegExp(r'[^\d]'), ''));
    if (numeroDecretoInt == null || numeroDecretoInt == 0) continue;

    final tipoActo = cells[4].text.trim();
    final fechaStr = cells[7].text.trim(); // DD-MM-YYYY
    final fechaPubStr = cells[8].text.trim(); // DD-MM-YYYY
    final descripcion = cells[12].text.trim();

    final fechaDate = _parseDate(fechaStr);
    if (fechaDate == null) continue; // requerido para UNIQUE(numero_decreto, fecha_decreto)
    final fechaIso = _isoDate(fechaDate);

    final fechaPubDate = _parseDate(fechaPubStr);
    final fechaPubIso = fechaPubDate != null ? _isoDate(fechaPubDate) : null;

    // ─── Parsear descripción ─────────────────────────────────────────────────
    // Ejemplos:
    //   "Otorga Patente Comercial Definitiva a ELYSIUM STUDIO SpA, Rut: 78.200.042-K, Giro: Peluquería"
    //   "Otorga Patente Profesional a Don Juan Pérez, Rut: 12.345.678-9, Giro: Contador"
    //   "Otorga Patente Alcoholes a BOTILLERÍA X LTDA., Rut N° 77.001.002-3, Giro: Botillería"

    String? tipoPatente;
    String? razonSocial;
    String? rut;
    String? giro;

    // tipo_patente: texto entre "Patente " y " a " (ej. "Comercial Definitiva", "Profesional")
    final tipoMatch = RegExp(
      r'[Pp]atente\s+(.+?)\s+a\s+(?:Don\s|Doña\s)?',
      caseSensitive: false,
    ).firstMatch(descripcion);
    if (tipoMatch != null) {
      tipoPatente = tipoMatch.group(1)?.trim();
    }

    // rut: varios formatos: "Rut: 12.345.678-9", "Rut N°: ...", "R.U.T. ..."
    final rutMatch = RegExp(
      r'[Rr][Uu][Tt]\.?\s*[Nn]?[°º]?\s*:?\s*(\d{1,2}\.\d{3}\.\d{3}-[\dkK])',
    ).firstMatch(descripcion);
    if (rutMatch != null) {
      rut = rutMatch.group(1)?.trim();
    }

    // giro: texto después de "Giro: " hasta el fin de la cadena (o coma)
    final giroMatch = RegExp(
      r'[Gg]iro\s*:\s*(.+?)$',
    ).firstMatch(descripcion);
    if (giroMatch != null) {
      giro = giroMatch.group(1)?.trim().replaceAll(RegExp(r'[,;.]+$'), '');
    }

    // razon_social: texto después de "a (Don|Doña)?" y antes de ", Rut" o ", Giro"
    final razonMatch = RegExp(
      r'\ba\s+(?:Don\s+|Doña\s+)?(.+?)(?:,\s*[Rr][Uu][Tt]|,\s*[Gg]iro|$)',
    ).firstMatch(descripcion);
    if (razonMatch != null) {
      razonSocial = razonMatch.group(1)?.trim();
    }

    await ProgressTracker.throwIfCancelled(redis);
    if (rowNum % 100 == 0) await tracker?.tick();

    // Dedup: verificar si ya existe por UNIQUE(numero_decreto, fecha_decreto)
    final existing = await db.execute(
      Sql.named(r'''
        SELECT 1 FROM patentes_comerciales
        WHERE numero_decreto = @decreto AND fecha_decreto = @fecha::date
        LIMIT 1
      '''),
      parameters: {'decreto': numeroDecretoInt, 'fecha': fechaIso},
    );
    if (existing.isNotEmpty) {
      ok++;
      continue;
    }

    final rawData = jsonEncode({
      'numero_acto': numeroActo,
      'tipo_acto': tipoActo,
      'fecha': fechaStr,
      'fecha_publicacion': fechaPubStr,
      'descripcion': descripcion,
      'tipo_patente_parsed': tipoPatente,
      'razon_social_parsed': razonSocial,
      'rut_parsed': rut,
      'giro_parsed': giro,
      'url_fuente': url,
    });

    try {
      // ig=164 no tiene dirección → sin geocoding, geom NULL
      await db.execute(
        Sql.named('''
          INSERT INTO patentes_comerciales (
            id, numero_decreto, fecha_decreto, fecha_publicacion,
            tipo_patente, rut, razon_social, giro,
            geocoding_confianza, url_fuente, scraped_at, raw_data
          ) VALUES (
            gen_random_uuid(), @decreto, @fecha::date, @fechaPub::date,
            @tipo, @rut, @nombre, @giro,
            'fallo', @url, NOW(), @raw::jsonb
          )
          ON CONFLICT (numero_decreto, fecha_decreto) DO UPDATE SET
            tipo_patente      = EXCLUDED.tipo_patente,
            rut               = EXCLUDED.rut,
            razon_social      = EXCLUDED.razon_social,
            giro              = EXCLUDED.giro,
            fecha_publicacion = EXCLUDED.fecha_publicacion,
            scraped_at        = EXCLUDED.scraped_at,
            raw_data          = EXCLUDED.raw_data
        '''),
        parameters: {
          'decreto': numeroDecretoInt,
          'fecha': fechaIso,
          'fechaPub': fechaPubIso,
          'tipo': tipoPatente,
          'rut': rut,
          'nombre': razonSocial,
          'giro': giro,
          'url': url,
          'raw': rawData,
        },
      );
      ok++;
    } catch (e) {
      print('[patentes_ig164] Error decreto $numeroActo: $e');
      err++;
    }
  }

  tracker?.addOk(ok);
  tracker?.addErr(err);
  await tracker?.tick();

  final params = Uri.parse(url).queryParameters;
  print('[patentes_ig164] m=${params['m']} a=${params['a']} ia=${params['ia']} — $ok OK, $err errores');
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
    final r = await http.get(Uri.parse(url), headers: {'User-Agent': _ua})
        .timeout(const Duration(seconds: 30));
    if (r.statusCode == 200) return r.body;
    print('[patentes_ig164] HTTP ${r.statusCode} — $url');
    return null;
  } catch (e) {
    print('[patentes_ig164] Fetch error $url: $e');
    return null;
  }
}
