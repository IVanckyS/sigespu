import 'dart:io';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

class DatabaseService {
  static final _log = Logger('DatabaseService');

  late Pool _db;
  late Command _redis;

  Pool get db => _db;
  Command get redis => _redis;

  /// Inicializa Postgres. Llamar antes de runMigrations().
  Future<void> initPostgres() async {
    final databaseUrl = Platform.environment['DATABASE_URL'];
    final sslMode = _isProduction() ? SslMode.require : SslMode.disable;
    final maxConn = int.tryParse(Platform.environment['DB_POOL_SIZE'] ?? '') ?? 15;

    final Endpoint endpoint;
    if (databaseUrl != null && databaseUrl.isNotEmpty) {
      endpoint = parseDbUrl(databaseUrl);
    } else {
      endpoint = Endpoint(
        host: Platform.environment['DB_HOST'] ?? 'localhost',
        port: int.parse(Platform.environment['DB_PORT'] ?? '5432'),
        database: Platform.environment['DB_NAME'] ?? 'sigespu',
        username: Platform.environment['DB_USER'] ?? 'sigespu_user',
        password: Platform.environment['DB_PASSWORD'] ?? 'secret_password',
      );
    }

    int retries = 5;
    while (retries > 0) {
      try {
        _db = Pool.withEndpoints(
          [endpoint],
          settings: PoolSettings(
            sslMode: sslMode,
            maxConnectionCount: maxConn,
          ),
        );
        await _db.execute('SELECT 1');
        _log.info(
            'Postgres ready (maxConn=$maxConn) on ${endpoint.host}:${endpoint.port}/${endpoint.database}');
        break;
      } catch (e) {
        retries--;
        _log.warning(
            'Fallo al conectar a PostgreSQL. Reintentando en 3s... ($retries intentos restantes): $e');
        if (retries == 0) rethrow;
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  }

  /// Inicializa Redis. Llamar después de runMigrations().
  Future<void> initRedis() async {
    final redisUrl = Platform.environment['REDIS_URL'];
    final String host;
    final int port;
    final String? password;

    if (redisUrl != null && redisUrl.isNotEmpty) {
      (host, port, password) = parseRedisUrl(redisUrl);
    } else {
      host = Platform.environment['REDIS_HOST'] ?? 'localhost';
      port = int.parse(Platform.environment['REDIS_PORT'] ?? '6379');
      password = null;
    }

    int retries = 5;
    while (retries > 0) {
      try {
        final conn = RedisConnection();
        _redis = await conn.connect(host, port);
        if (password != null && password.isNotEmpty) {
          await _redis.send_object(['AUTH', password]);
        }
        _log.info('Redis ready on $host:$port');
        break;
      } catch (e) {
        retries--;
        _log.warning(
            'Fallo al conectar a Redis. Reintentando en 3s... ($retries intentos restantes): $e');
        if (retries == 0) rethrow;
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  }

  /// Conveniencia: inicializa Postgres + Redis juntos (para dev local y tests).
  Future<void> init() async {
    await initPostgres();
    await initRedis();
  }

  Future<void> close() async {
    await _db.close();
  }

  // ── URL parsers (static, expuestos para tests) ──────────────────────────────

  /// Parsea `postgresql://user:pass@host:port/dbname` → Endpoint.
  static Endpoint parseDbUrl(String url) {
    final uri = Uri.parse(url);
    final userParts = uri.userInfo.split(':');
    return Endpoint(
      host: uri.host,
      port: uri.port > 0 ? uri.port : 5432,
      database: uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'sigespu',
      username: userParts.isNotEmpty ? userParts[0] : null,
      password: userParts.length > 1 ? userParts.sublist(1).join(':') : null,
    );
  }

  /// Parsea `redis://default:pass@host:port` → (host, port, password?).
  static (String, int, String?) parseRedisUrl(String url) {
    final uri = Uri.parse(url);
    String? password;
    if (uri.userInfo.contains(':')) {
      final pwd = uri.userInfo.split(':').sublist(1).join(':');
      password = pwd.isEmpty ? null : pwd;
    }
    return (uri.host, uri.port > 0 ? uri.port : 6379, password);
  }

  // ── Helpers privados ────────────────────────────────────────────────────────

  static bool _isProduction() =>
      Platform.environment['APP_ENV']?.toLowerCase() == 'production' ||
      Platform.environment['RAILWAY_ENVIRONMENT'] != null;
}
