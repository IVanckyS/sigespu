import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigespu/src/presentation/users/users_provider.dart';

void main() {
  group('UsersNotifier', () {
    test('loads mock users when API unavailable', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final result = await container.read(usersProvider.future);
      expect(result, isNotEmpty);
      expect(result.any((u) => u.nivelAcceso == 'director'), isTrue);
    });
  });
}
