import 'dart:async';
import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:scraper/scraper.dart' as scraper;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/db_pool.dart';

/// Endpoints públicos (lectura) + endpoints protegidos (gatillar scraping).
///
/// Lectura: cualquier usuario autenticado puede leer las tablas.
/// Escritura (run / histórico): solo director — el guard se aplica en server.dart
/// con el middleware `requireRole(['director'])`.
Router buildScrapingRouter(DatabaseService db) {
  final router = Router();

  router.get('/status', (Request req) async => _getStatus(db));
  router.get('/patentes', (Request req) async => _listPatentes(db, req.url.queryParameters));
  router.get('/permisos', (Request req) async => _listPermisos(db, req.url.queryParameters));
  router.get('/transito', (Request req) async => _listTransito(db, req.url.queryParameters));
  router.get('/organizaciones', (Request req) async => _listOrganizaciones(db, req.url.queryParameters));

  router.post('/run', (Request req) async => _runActual(db));
  router.post('/historico', (Request req) async => _runHistorico(db, req));

  return router;
}

// ── Status ────────────────────────────────────────────────────────────────────

Future<Response> _getStatus(DatabaseService db) async {
  final raw = await db.redis.send_object(['GET', 'scraping:status']);
  if (raw is! String) {
    return Response.ok(
      jsonEncode({'running': false}),
      headers: {'content-type': 'application/json'},
    );
  }
  return Response.ok(raw, headers: {'content-type': 'application/json'});
}

// ── Run actual / histórico ────────────────────────────────────────────────────

Future<Response> _runActual(DatabaseService db) async {
  if (await scraper.ProgressTracker.isRunning(db.redis)) {
    return Response(409, body: jsonEncode({'error': 'Ya hay un scraping en curso'}));
  }
  // Fire-and-forget: el handler responde de inmediato, el scraping corre en background.
  unawaited(scraper.runScrapingActual(db: db.db, redis: db.redis).catchError((e) {
    print('[scraping/run] $e');
  }));
  return Response.ok(jsonEncode({'message': 'Scraping iniciado'}));
}

Future<Response> _runHistorico(DatabaseService db, Request req) async {
  if (await scraper.ProgressTracker.isRunning(db.redis)) {
    return Response(409, body: jsonEncode({'error': 'Ya hay un scraping en curso'}));
  }

  int patentesYearFrom = 2022;
  int orgsYearFrom = 2020;
  final body = await req.readAsString();
  if (body.isNotEmpty) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      patentesYearFrom = (data['patentes_year_from'] as num?)?.toInt() ?? patentesYearFrom;
      orgsYearFrom = (data['organizaciones_year_from'] as num?)?.toInt() ?? orgsYearFrom;
    } catch (_) {}
  }

  unawaited(scraper.runScrapingHistorico(
    db: db.db,
    redis: db.redis,
    patentesYearFrom: patentesYearFrom,
    organizacionesYearFrom: orgsYearFrom,
  ).catchError((e) {
    print('[scraping/historico] $e');
  }));

  return Response.ok(jsonEncode({'message': 'Scraping histórico iniciado'}));
}

// ── Lecturas paginadas desde la BD ────────────────────────────────────────────

(int, int) _paging(Map<String, String> q) {
  final limit = (int.tryParse(q['limit'] ?? '200') ?? 200).clamp(1, 1000);
  final offset = (int.tryParse(q['offset'] ?? '0') ?? 0).clamp(0, 100000);
  return (limit, offset);
}

String? _isoString(dynamic v) =>
    v is DateTime ? v.toIso8601String() : v?.toString();

Future<Response> _listPatentes(DatabaseService db, Map<String, String> q) async {
  final (limit, offset) = _paging(q);
  final rows = await db.db.execute(
    Sql.named(r'''
      SELECT numero_decreto, fecha_decreto, tipo_patente, rut, razon_social, giro,
             direccion_raw, direccion_normalizada,
             ST_Y(geom::geometry) AS lat, ST_X(geom::geometry) AS lng,
             geocoding_confianza, url_fuente, scraped_at
      FROM patentes_comerciales
      ORDER BY fecha_decreto DESC NULLS LAST
      LIMIT @limit OFFSET @offset
    '''),
    parameters: {'limit': limit, 'offset': offset},
  );

  final items = rows.map((r) => {
        'n_decreto': r[0],
        'fecha_decreto': _isoString(r[1]),
        'tipo': r[2],
        'rut': r[3],
        'razon_social': r[4],
        'giro': r[5],
        'direccion': r[6],
        'direccion_normalizada': r[7],
        'lat': r[8],
        'lng': r[9],
        'confianza': r[10],
        'url': r[11],
        'scraped_at': _isoString(r[12]),
      }).toList();

  return Response.ok(
    jsonEncode({'items': items, 'total': items.length}),
    headers: {'content-type': 'application/json'},
  );
}

Future<Response> _listPermisos(DatabaseService db, Map<String, String> q) async {
  final (limit, offset) = _paging(q);
  final rows = await db.db.execute(
    Sql.named(r'''
      SELECT numero_permiso, tipo, descripcion,
             ST_Y(geom::geometry) AS lat, ST_X(geom::geometry) AS lng,
             fecha_otorgamiento, estado, url_fuente, scraped_at
      FROM permisos_dom
      ORDER BY fecha_otorgamiento DESC NULLS LAST
      LIMIT @limit OFFSET @offset
    '''),
    parameters: {'limit': limit, 'offset': offset},
  );

  final items = rows.map((r) => {
        'n_permiso': r[0],
        'tipo': r[1],
        'descripcion': r[2],
        'lat': r[3],
        'lng': r[4],
        'fecha': _isoString(r[5]),
        'estado': r[6],
        'url': r[7],
        'scraped_at': _isoString(r[8]),
      }).toList();

  return Response.ok(
    jsonEncode({'items': items, 'total': items.length}),
    headers: {'content-type': 'application/json'},
  );
}

Future<Response> _listTransito(DatabaseService db, Map<String, String> q) async {
  final (limit, offset) = _paging(q);
  final rows = await db.db.execute(
    Sql.named(r'''
      SELECT numero_decreto, tipo, descripcion, direccion_afectada,
             fecha_inicio, fecha_fin, estado, url_fuente, scraped_at
      FROM decretos_transito
      ORDER BY fecha_inicio DESC NULLS LAST
      LIMIT @limit OFFSET @offset
    '''),
    parameters: {'limit': limit, 'offset': offset},
  );

  final items = rows.map((r) => {
        'n_decreto': r[0],
        'tipo': r[1],
        'motivo': r[2],
        'direccion': r[3],
        'fecha_inicio': _isoString(r[4]),
        'fecha_fin': _isoString(r[5]),
        'estado': r[6],
        'url': r[7],
        'scraped_at': _isoString(r[8]),
      }).toList();

  return Response.ok(
    jsonEncode({'items': items, 'total': items.length}),
    headers: {'content-type': 'application/json'},
  );
}

Future<Response> _listOrganizaciones(DatabaseService db, Map<String, String> q) async {
  final (limit, offset) = _paging(q);
  final rows = await db.db.execute(
    Sql.named(r'''
      SELECT numero_personalidad, tipo, nombre, direccion,
             ST_Y(geom::geometry) AS lat, ST_X(geom::geometry) AS lng,
             representante, rut_representante, vigencia_hasta, sector,
             url_fuente, scraped_at
      FROM organizaciones_sociales
      ORDER BY scraped_at DESC NULLS LAST
      LIMIT @limit OFFSET @offset
    '''),
    parameters: {'limit': limit, 'offset': offset},
  );

  final items = rows.map((r) => {
        'n_personalidad': r[0],
        'tipo': r[1],
        'nombre': r[2],
        'direccion': r[3],
        'lat': r[4],
        'lng': r[5],
        'representante': r[6],
        'rut_rep': r[7],
        'vigencia': _isoString(r[8]),
        'sector': r[9],
        'url': r[10],
        'scraped_at': _isoString(r[11]),
      }).toList();

  return Response.ok(
    jsonEncode({'items': items, 'total': items.length}),
    headers: {'content-type': 'application/json'},
  );
}
