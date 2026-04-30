import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

class DatabaseService {
  late Connection _db;
  late Command _redis;

  Connection get db => _db;
  Command get redis => _redis;

  Future<void> init() async {
    final host = Platform.environment['DB_HOST'] ?? 'localhost';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5432');
    final database = Platform.environment['DB_NAME'] ?? 'sigespu';
    final username = Platform.environment['DB_USER'] ?? 'sigespu_user';
    final password = Platform.environment['DB_PASSWORD'] ?? 'secret_password';

    int retries = 5;
    while (retries > 0) {
      try {
        _db = await Connection.open(
          Endpoint(host: host, port: port, database: database, username: username, password: password),
          settings: ConnectionSettings(sslMode: SslMode.disable),
        );
        break;
      } catch (e) {
        retries--;
        print('Fallo al conectar a PostgreSQL. Reintentando en 3s... (\$retries intentos restantes)');
        if (retries == 0) rethrow;
        await Future.delayed(const Duration(seconds: 3));
      }
    }

    final redisHost = Platform.environment['REDIS_HOST'] ?? 'localhost';
    final redisPort = int.parse(Platform.environment['REDIS_PORT'] ?? '6379');

    retries = 5;
    while (retries > 0) {
      try {
        final redisConn = RedisConnection();
        _redis = await redisConn.connect(redisHost, redisPort);
        break;
      } catch (e) {
        retries--;
        print('Fallo al conectar a Redis. Reintentando en 3s... (\$retries intentos restantes)');
        if (retries == 0) rethrow;
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  }

  Future<void> close() async {
    await _db.close();
  }
}
