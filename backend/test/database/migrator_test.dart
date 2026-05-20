import 'package:test/test.dart';

void main() {
  group('Ordenamiento de archivos de migración', () {
    test('los archivos se ordenan lexicográficamente por nombre', () {
      final names = [
        '003_add_indexes.sql',
        '001_initial_schema.sql',
        '002_seed_director.sql',
      ]..sort();

      expect(names, equals([
        '001_initial_schema.sql',
        '002_seed_director.sql',
        '003_add_indexes.sql',
      ]));
    });
  });
}
