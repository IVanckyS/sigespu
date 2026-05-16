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

  final handler = Pipeline()
      .addMiddleware(corsMiddleware())
      .addMiddleware(logRequests())
      .addMiddleware(rateLimitMiddleware(dbService, limit: 100, windowSecs: 60))
      .addHandler(router.call);

  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
