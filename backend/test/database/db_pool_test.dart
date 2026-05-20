// backend/test/database/db_pool_test.dart
import 'package:test/test.dart';
import 'package:backend/src/database/db_pool.dart';

void main() {
  group('DatabaseService.parseDbUrl', () {
    test('parsea URL completa de PostgreSQL', () {
      final ep = DatabaseService.parseDbUrl(
        'postgresql://myuser:mypass@db.railway.app:5432/sigespu',
      );
      expect(ep.host, equals('db.railway.app'));
      expect(ep.port, equals(5432));
      expect(ep.database, equals('sigespu'));
      expect(ep.username, equals('myuser'));
      expect(ep.password, equals('mypass'));
    });

    test('usa puerto 5432 por defecto si no está en la URL', () {
      final ep = DatabaseService.parseDbUrl(
        'postgresql://user:pass@host/dbname',
      );
      expect(ep.port, equals(5432));
    });
  });

  group('DatabaseService.parseRedisUrl', () {
    test('parsea URL completa de Redis con password', () {
      final (host, port, password) = DatabaseService.parseRedisUrl(
        'redis://default:secret@redis.railway.app:6379',
      );
      expect(host, equals('redis.railway.app'));
      expect(port, equals(6379));
      expect(password, equals('secret'));
    });

    test('retorna password null cuando la URL no tiene credenciales', () {
      final (host, port, password) = DatabaseService.parseRedisUrl(
        'redis://redis.railway.app:6379',
      );
      expect(host, equals('redis.railway.app'));
      expect(port, equals(6379));
      expect(password, isNull);
    });

    test('extrae solo el password del formato default:password de Railway', () {
      final (_, _, password) = DatabaseService.parseRedisUrl(
        'redis://default:mypassword@host:6379',
      );
      expect(password, equals('mypassword'));
    });
  });
}
