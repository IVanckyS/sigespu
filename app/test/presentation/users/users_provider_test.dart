import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigespu/src/presentation/auth/auth_provider.dart';
import 'package:sigespu/src/presentation/users/users_provider.dart';

/// Secure storage falso: evita el platform channel real en tests unitarios.
/// `AuthNotifier._checkAuth()` y `_fetchRemote()` solo invocan `read`.
class _FakeSecureStorage implements FlutterSecureStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #read) return Future<String?>.value(null);
    if (invocation.memberName == #readAll) {
      return Future<Map<String, String>>.value(<String, String>{});
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('UsersNotifier', () {
    test('loads mock users when API unavailable', () async {
      final container = ProviderContainer(overrides: [
        secureStorageProvider.overrideWithValue(_FakeSecureStorage()),
      ]);
      addTearDown(container.dispose);
      final result = await container.read(usersProvider.future);
      expect(result, isNotEmpty);
      expect(result.any((u) => u.nivelAcceso == 'director'), isTrue);
    });
  });
}
