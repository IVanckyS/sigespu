import 'dart:io';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

class DatabaseService {
  static final _log = Logger('DatabaseService');

  Pool? _db;
  Command? _redis;
  RedisConnection? _redisConn;

  Pool get db {
    if (_db == null) throw StateError('DatabaseService: initPostgres() no fue llamado');
    return _db!;
  }

  Command get redis {
    if (_redis == null) throw StateError('DatabaseService: initRedis() no fue llamado');
    return _redis!;
  }

  /// Inicializa Postgres. Llamar antes de runMigrations().
  Future<void> initPostgres() async {
    final databaseUrl = Platform.environment['DATABASE_URL'];
    final sslMode = _resolveSslMode();
    final maxConn = int.tryParse(Platform.environment['DB_POOL_SIZE'] ?? '') ?? 15;

    final Endpoint endpoint;
    if (databaseUrl != null && databaseUrl.isNotEmpty) {
      endpoint = parseDbUrl(databaseUrl);
    } else {
      endpoint = Endpoint(
        host: Platform.environment['DB_HOST'] ?? 'localhost',
        port: int.tryParse(Platform.environment['DB_PORT'] ?? '') ?? 5432,
        database: Platform.environment['DB_NAME'] ?? 'sigespu',
        username: Platform.environment['DB_USER'] ?? 'sigespu_user',
        password: Platform.environment['DB_PASSWORD'] ??
            (throw StateError('DB_PASSWORD no está configurado. Establece DATABASE_URL o DB_PASSWORD.')),
      );
    }

    int retries = 5;
    while (retries > 0) {
      Pool? attempt;
      try {
        attempt = Pool.withEndpoints(
          [endpoint],
          settings: PoolSettings(
            sslMode: sslMode,
            maxConnectionCount: maxConn,
          ),
        );
        await attempt.execute('SELECT 1');
        _db = attempt;
        _log.info(
            'Postgres ready (maxConn=$maxConn) on ${endpoint.host}:${endpoint.port}/${endpoint.database}');
        break;
      } catch (e) {
        await attempt?.close();
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
      port = int.tryParse(Platform.environment['REDIS_PORT'] ?? '') ?? 6379;
      password = null;
    }

    int retries = 5;
    while (retries > 0) {
      try {
        final conn = RedisConnection();
        _redisConn = conn;
        _redis = await conn.connect(host, port);
        if (password != null && password.isNotEmpty) {
          await _redis!.send_object(['AUTH', password]);
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
    await _db?.close();
    await _redisConn?.close();
  }

  // ── URL parsers (static, expuestos para tests) ──────────────────────────────

  /// Parsea `postgresql://user:pass@host:port/dbname` → Endpoint.
  static Endpoint parseDbUrl(String url) {
    final uri = Uri.parse(url);
    final userInfo = Uri.decodeComponent(uri.userInfo);
    final sep = userInfo.indexOf(':');
    final username = sep >= 0 ? userInfo.substring(0, sep) : userInfo;
    final password = sep >= 0 ? userInfo.substring(sep + 1) : null;
    return Endpoint(
      host: uri.host,
      port: uri.port > 0 ? uri.port : 5432,
      database: uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'sigespu',
      username: username.isEmpty ? null : username,
      password: password?.isEmpty == true ? null : password,
    );
  }

  /// Parsea `redis://default:pass@host:port` → (host, port, password?).
  static (String, int, String?) parseRedisUrl(String url) {
    final uri = Uri.parse(url);
    final userInfo = Uri.decodeComponent(uri.userInfo);
    String? password;
    if (userInfo.contains(':')) {
      final sep = userInfo.indexOf(':');
      final pwd = userInfo.substring(sep + 1);
      password = pwd.isEmpty ? null : pwd;
    }
    return (uri.host, uri.port > 0 ? uri.port : 6379, password);
  }

  // ── Helpers privados ────────────────────────────────────────────────────────

  static SslMode _resolveSslMode() {
    final explicit = Platform.environment['DB_SSL']?.toLowerCase();
    if (explicit == 'disable') return SslMode.disable;
    if (explicit == 'require') return SslMode.require;
    return _isProduction() ? SslMode.require : SslMode.disable;
  }

  static bool _isProduction() =>
      Platform.environment['APP_ENV']?.toLowerCase() == 'production' ||
      Platform.environment['RAILWAY_ENVIRONMENT'] != null;
}
