import 'package:cron/cron.dart';
import '../sources/patentes_mensuales.dart';
import '../sources/permisos_dom.dart';
import '../sources/decretos_transito.dart';
import '../sources/organizaciones.dart';
import '../geocoder/nominatim_client.dart';
import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

Future<void> startCron() async {
  final cron = Cron();
  
  final dbHost = Platform.environment['DB_HOST'] ?? 'localhost';
  final dbPort = int.parse(Platform.environment['DB_PORT'] ?? '5432');
  final dbName = Platform.environment['DB_NAME'] ?? 'sigespu';
  final dbUser = Platform.environment['DB_USER'] ?? 'sigespu_user';
  final dbPass = Platform.environment['DB_PASSWORD'] ?? 'secret_password';
  
  late Connection db;
  int retries = 5;
  while (retries > 0) {
    try {
      db = await Connection.open(
        Endpoint(host: dbHost, port: dbPort, database: dbName, username: dbUser, password: dbPass),
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
  
  late Command redis;
  retries = 5;
  while (retries > 0) {
    try {
      final redisConn = RedisConnection();
      redis = await redisConn.connect(redisHost, redisPort);
      break;
    } catch (e) {
      retries--;
      print('Fallo al conectar a Redis. Reintentando en 3s... (\$retries intentos restantes)');
      if (retries == 0) rethrow;
      await Future.delayed(const Duration(seconds: 3));
    }
  }
  
  final geocoder = NominatimClient();
  
  // Ejecución inicial para asegurar funcionamiento
  await scrapePatentes(db, redis, geocoder);

  cron.schedule(Schedule.parse('0 3 * * *'), () async {
    print('Ejecutando cron diario 03:00 AM');
    await scrapePatentes(db, redis, geocoder);
  });
  
  cron.schedule(Schedule.parse('10 3 * * *'), () async {
    print('Ejecutando cron diario 03:10 AM');
    await scrapePermisosDom(db, redis, geocoder);
  });
  
  cron.schedule(Schedule.parse('20 3 * * *'), () async {
    print('Ejecutando cron diario 03:20 AM');
    await scrapeDecretosTransito(db, redis);
  });
  
  cron.schedule(Schedule.parse('0 4 * * 0'), () async {
    print('Ejecutando cron semanal domingo 04:00 AM');
    await scrapeOrganizaciones(db, redis, geocoder);
  });
  
  print('Scheduler configurado y en espera...');
}
