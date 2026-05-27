import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

class DatabaseService {
  static final _log = Logger('DatabaseService');

  Pool? _db;
  ReconnectingRedis? _redis;
  ReconnectingRedis? _scrapingRedis;

  Pool get db {
    if (_db == null) throw StateError('DatabaseService: initPostgres() no fue llamado');
    return _db!;
  }

  /// Conexión Redis para handlers HTTP (rate limit, JWT blacklist, status reads).
  ReconnectingRedis get redis {
    if (_redis == null) throw StateError('DatabaseService: initRedis() no fue llamado');
    return _redis!;
  }

  /// Conexión Redis dedicada al scraper (progress writes, cancel checks, geocode cache).
  /// Separada del handler HTTP para evitar contención — el paquete redis/Dart
  /// no soporta comandos concurrentes sobre una sola conexión TCP.
  ReconnectingRedis get scrapingRedis {
    if (_scrapingRedis == null) throw StateError('DatabaseService: initRedis() no fue llamado');
    return _scrapingRedis!;
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

  /// Inicializa Redis con dos conexiones independientes con auto-reconexión.
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
        _redis = await ReconnectingRedis.connect(host, port, password);
        _scrapingRedis = await ReconnectingRedis.connect(host, port, password);
        _log.info('Redis ready (2 conexiones con auto-reconexión) en $host:$port');
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
    await _redis?.close();
    await _scrapingRedis?.close();
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

/// Wrapper sobre [Command] que reconecta automáticamente si la conexión TCP cae.
///
/// El paquete redis/Dart no tiene auto-reconexión. Cuando el servidor Redis
/// cierra la conexión (reinicio, idle timeout, glitch de red), cualquier
/// send_object() lanza "Bad state: StreamSink is closed". Este wrapper
/// detecta ese error y reconecta una vez antes de reintentar el comando.
/// Incluye timeout de 5s por comando para no colgar si la conexión está muerta
/// pero el socket aún no lo notificó.
class ReconnectingRedis {
  static final _log = Logger('ReconnectingRedis');

  final String _host;
  final int _port;
  final String? _password;

  RedisConnection? _conn;
  Command? _cmd;

  ReconnectingRedis._(this._host, this._port, this._password);

  static Future<ReconnectingRedis> connect(
      String host, int port, String? password) async {
    final r = ReconnectingRedis._(host, port, password);
    await r._doConnect();
    return r;
  }

  Future<void> _doConnect() async {
    final conn = RedisConnection();
    final cmd = await conn.connect(_host, _port);
    if (_password != null && _password!.isNotEmpty) {
      await cmd.send_object(['AUTH', _password]);
    }
    _conn = conn;
    _cmd = cmd;
  }

  /// Ejecuta un comando Redis. Si la conexión está caída (StateError o
  /// TimeoutException), reconecta una vez y reintenta automáticamente.
  Future<dynamic> send_object(List<dynamic> args) async {
    try {
      return await _cmd!.send_object(args).timeout(const Duration(seconds: 5));
    } catch (e) {
      if (e is StateError || e is TimeoutException || e is SocketException) {
        _log.warning('Redis reconectando tras error: $e');
        try {
          await _conn?.close();
        } catch (_) {}
        _conn = null;
        _cmd = null;
        await _doConnect();
        return await _cmd!.send_object(args).timeout(const Duration(seconds: 5));
      }
      rethrow;
    }
  }

  Future<void> close() async {
    try {
      await _conn?.close();
    } catch (_) {}
    _conn = null;
    _cmd = null;
  }
}
