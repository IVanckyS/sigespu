// Entrypoint para correr el scraper de forma standalone (ej: debugging manual).
// En producción, el scraper corre embebido en el backend via startScraperCron().
import 'dart:async';
import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';
import 'package:scraper/scheduler/cron.dart';

void main() async {
  print('Iniciando SIGESPU Scraper Worker (standalone)...');

  final databaseUrl = Platform.environment['DATABASE_URL'];
  final sslMode = Platform.environment['APP_ENV'] == 'production'
      ? SslMode.require
      : SslMode.disable;

  final Endpoint endpoint;
  if (databaseUrl != null && databaseUrl.isNotEmpty) {
    final uri = Uri.parse(databaseUrl);
    final userInfo = Uri.decodeComponent(uri.userInfo);
    final sep = userInfo.indexOf(':');
    endpoint = Endpoint(
      host: uri.host,
      port: uri.port > 0 ? uri.port : 5432,
      database: uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'sigespu',
      username: sep >= 0 ? userInfo.substring(0, sep) : userInfo,
      password: sep >= 0 ? userInfo.substring(sep + 1) : null,
    );
  } else {
    endpoint = Endpoint(
      host: Platform.environment['DB_HOST'] ?? 'localhost',
      port: int.tryParse(Platform.environment['DB_PORT'] ?? '') ?? 5432,
      database: Platform.environment['DB_NAME'] ?? 'sigespu',
      username: Platform.environment['DB_USER'] ?? 'sigespu_user',
      password: Platform.environment['DB_PASSWORD'] ?? 'secret_password',
    );
  }

  final db = Pool.withEndpoints(
    [endpoint],
    settings: PoolSettings(sslMode: sslMode, maxConnectionCount: 3),
  );
  await db.execute('SELECT 1');
  print('[scraper] Postgres conectado');

  final redisUrl = Platform.environment['REDIS_URL'];
  final String redisHost;
  final int redisPort;
  String? redisPassword;

  if (redisUrl != null && redisUrl.isNotEmpty) {
    final uri = Uri.parse(redisUrl);
    redisHost = uri.host;
    redisPort = uri.port > 0 ? uri.port : 6379;
    if (uri.userInfo.contains(':')) {
      final pwd = Uri.decodeComponent(uri.userInfo.split(':').sublist(1).join(':'));
      redisPassword = pwd.isEmpty ? null : pwd;
    }
  } else {
    redisHost = Platform.environment['REDIS_HOST'] ?? 'localhost';
    redisPort = int.tryParse(Platform.environment['REDIS_PORT'] ?? '') ?? 6379;
  }

  final redisConn = RedisConnection();
  final redis = await redisConn.connect(redisHost, redisPort);
  if (redisPassword != null) {
    await redis.send_object(['AUTH', redisPassword]);
  }
  print('[scraper] Redis conectado');

  startScraperCron(db, redis);
  print('[scraper] Standalone iniciado. Ctrl+C para detener.');
  await Completer<Never>().future;
}
