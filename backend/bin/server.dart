import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import '../lib/src/database/db_pool.dart';
import '../lib/src/database/migrator.dart';
import '../lib/src/auth/jwt_service.dart';
import '../lib/src/auth/auth_handler.dart';
import '../lib/src/middleware/rate_limit_middleware.dart';
import '../lib/src/middleware/cors_middleware.dart';
import '../lib/src/middleware/auth_middleware.dart';
import '../lib/src/routes/sismos_route.dart';
import '../lib/src/routes/capas_route.dart';
import '../lib/src/routes/elementos_route.dart';
import '../lib/src/routes/actividades_route.dart';
import '../lib/src/routes/zonas_route.dart';
import '../lib/src/routes/scraping_route.dart';
import '../lib/src/services/email_service.dart';
import 'package:scraper/scheduler/cron.dart';

final _log = Logger('Server');

/// Configura el logger global: nivel mínimo, formato y destino (stdout).
/// Llamar UNA SOLA VEZ al arrancar el proceso.
void _setupLogging() {
  // En producción se puede subir el umbral con LOG_LEVEL=WARNING.
  final levelName = Platform.environment['LOG_LEVEL'] ?? 'INFO';
  Logger.root.level = Level.LEVELS.firstWhere(
    (l) => l.name == levelName.toUpperCase(),
    orElse: () => Level.INFO,
  );
  Logger.root.onRecord.listen((r) {
    final ts = r.time.toIso8601String();
    final loc = r.loggerName.isEmpty ? '-' : r.loggerName;
    stdout.writeln('$ts [${r.level.name}] $loc: ${r.message}');
    if (r.error != null) {
      stdout.writeln('  error: ${r.error}');
    }
    if (r.stackTrace != null) {
      stdout.writeln(r.stackTrace);
    }
  });
}

void main(List<String> args) async {
  _setupLogging();

  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final dbService = DatabaseService();
  await dbService.initPostgres();
  await runMigrations(dbService.db);
  await dbService.initRedis();
  startScraperCron(dbService.db, dbService.redis);

  final jwtService = JwtService(dbService);
  final emailService = EmailService();
  final authHandler = AuthHandler(dbService, jwtService, emailService);

  final router = Router();

  router.get('/api/health', (Request req) async {
    bool pgOk = false;
    bool redisOk = false;
    try {
      await dbService.db.execute('SELECT 1');
      pgOk = true;
    } catch (_) {}
    try {
      await dbService.redis.send_object(['PING']);
      redisOk = true;
    } catch (_) {}
    if (!pgOk) {
      return Response(
        503,
        body: jsonEncode({'status': 'error', 'postgres': false, 'redis': redisOk}),
        headers: {'content-type': 'application/json'},
      );
    }
    return Response.ok(
      jsonEncode({'status': redisOk ? 'ok' : 'degraded', 'postgres': true, 'redis': redisOk}),
      headers: {'content-type': 'application/json'},
    );
  });
    
  router.mount('/auth', Pipeline()
    .addMiddleware(rateLimitMiddleware(dbService, limit: 20, windowSecs: 60, prefix: 'auth'))
    .addHandler(authHandler.router.call));

  router.mount('/api/sismos', Pipeline()
    .addMiddleware(authMiddleware(jwtService))
    .addHandler(buildSismosRouter(dbService).call));

  router.mount('/api/capas', Pipeline()
    .addMiddleware(authMiddleware(jwtService))
    .addHandler(buildCapasRouter(dbService).call));

  router.mount('/api/elementos', Pipeline()
    .addMiddleware(authMiddleware(jwtService))
    .addHandler(buildElementosRouter(dbService).call));

  router.mount('/api/actividades', Pipeline()
    .addMiddleware(authMiddleware(jwtService))
    .addHandler(buildActividadesRouter(dbService).call));

  router.mount('/api/zonas', Pipeline()
    .addMiddleware(authMiddleware(jwtService))
    .addHandler(buildZonasRouter(dbService).call));

  // Scraping: GET autenticado para todos; POST run/histórico solo director.
  // El guard director-only se aplica dentro del router para no exponer un
  // mismo prefix con distintos niveles de auth en pipelines paralelos.
  router.mount('/api/scraping', Pipeline()
    .addMiddleware(authMiddleware(jwtService))
    .addMiddleware(_scrapingWriteGuard())
    .addHandler(buildScrapingRouter(dbService).call));

  final handler = Pipeline()
      .addMiddleware(corsMiddleware())
      .addMiddleware(logRequests())
      .addMiddleware(rateLimitMiddleware(dbService, limit: 500, windowSecs: 60))
      .addHandler(router.call);

  final server = await serve(handler, ip, port);
  _log.info('Server listening on port ${server.port}');

  // Graceful shutdown: Docker/K8s send SIGTERM before SIGKILL
  Future<void> shutdown(String signal) async {
    _log.info('$signal recibido — cerrando servidor...');
    await server.close(force: false);
    await dbService.close();
    _log.info('Servidor cerrado limpiamente.');
  }

  ProcessSignal.sigterm.watch().listen((_) => shutdown('SIGTERM'));
  // SIGINT is only reliably available on non-Windows; wrap in try-catch
  try {
    ProcessSignal.sigint.watch().listen((_) => shutdown('SIGINT'));
  } catch (_) {}
}

/// Permite GET a cualquier usuario autenticado, exige rol director en POST.
/// Se aplica solo a /api/scraping/* — los GET de status/listados son lectura
/// para todos, los POST run/historico son acciones administrativas.
Middleware _scrapingWriteGuard() {
  return (Handler inner) {
    return (Request req) async {
      if (req.method != 'POST') return inner(req);
      final nivel = req.context['nivel_acceso'] as String?;
      if (nivel != 'director') {
        return Response.forbidden(
          '{"error":"Solo el director puede ejecutar el scraper"}',
          headers: {'content-type': 'application/json'},
        );
      }
      return inner(req);
    };
  };
}
