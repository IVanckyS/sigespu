import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import '../lib/src/database/db_pool.dart';
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

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final dbService = DatabaseService();
  await dbService.init();
  print('Connected to PostgreSQL and Redis');

  final jwtService = JwtService(dbService);
  final emailService = EmailService();
  final authHandler = AuthHandler(dbService, jwtService, emailService);

  final router = Router()
    ..get('/api/health', (Request req) {
      return Response.ok('SIGESPU Lota API is running');
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
  print('Server listening on port ${server.port}');
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
