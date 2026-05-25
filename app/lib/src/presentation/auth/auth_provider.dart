import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

const _absent = Object();

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;
  final String? pendingEmail;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.pendingEmail,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    Object? error = _absent,
    Map<String, dynamic>? user,
    Object? pendingEmail = _absent,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _absent) ? this.error : error as String?,
      user: user ?? this.user,
      pendingEmail: identical(pendingEmail, _absent) ? this.pendingEmail : pendingEmail as String?,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage;
  // TODO: Use env variable for base URL in production
  final String baseUrl = 'http://localhost:8080/auth';

  AuthNotifier(this._storage) : super(AuthState()) {
    _checkAuth();
  }

  /// Normaliza el email: quita espacios alrededor y lo pasa a minúsculas.
  ///
  /// El backend almacena los emails en minúscula y los compara
  /// case-sensitively, por lo que `Admin@lota.cl` no haría match con el
  /// registro `admin@lota.cl`. Esta función centraliza la normalización
  /// para login / register / solicitar-acceso.
  static String normalizeEmail(String email) => email.trim().toLowerCase();

  Future<void> _checkAuth() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return;

    // Validate session expiry if one was stored (set at login time).
    // Absent expiry = legacy session pre-feature → allow once (backwards compat).
    final expiryStr = await _storage.read(key: 'session_expiry');
    if (expiryStr != null) {
      final expiry = DateTime.tryParse(expiryStr);
      if (expiry != null && DateTime.now().isAfter(expiry)) {
        await _clearSession();
        return;
      }
    }

    final userStr = await _storage.read(key: 'user_info');
    Map<String, dynamic>? user;
    if (userStr != null) user = jsonDecode(userStr);
    state = state.copyWith(isAuthenticated: true, user: user);
  }

  Future<void> _clearSession() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_info');
    await _storage.delete(key: 'session_expiry');
    await _storage.delete(key: 'remember_me');
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': normalizeEmail(email),
          'password': password,
          'remember_me': rememberMe,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'access_token', value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);
        await _storage.write(key: 'user_info', value: jsonEncode(data['user']));
        await _writeSessionExpiry(rememberMe: rememberMe);

        state = state.copyWith(isAuthenticated: true, isLoading: false, user: data['user']);
        return true;
      } else {
        final data = jsonDecode(response.body);
        state = state.copyWith(isLoading: false, error: data['error'] ?? 'Error de autenticación');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error de conexión con el servidor');
      return false;
    }
  }

  Future<void> _writeSessionExpiry({required bool rememberMe}) async {
    final expiry = DateTime.now().add(
      rememberMe ? const Duration(days: 30) : const Duration(days: 7),
    );
    await _storage.write(key: 'session_expiry', value: expiry.toIso8601String());
    await _storage.write(key: 'remember_me', value: rememberMe.toString());
  }

  Future<bool> register(String nombre, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nombre': nombre, 'email': normalizeEmail(email), 'password': password}),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          pendingEmail: normalizeEmail(email),
        );
        return true;
      } else {
        final data = jsonDecode(response.body);
        state = state.copyWith(isLoading: false, error: data['error'] ?? 'Error al registrarse');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error de conexión con el servidor');
      return false;
    }
  }

  Future<bool> verificarCodigo(String email, String codigo) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verificar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': normalizeEmail(email), 'codigo': codigo}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'access_token', value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);
        await _storage.write(key: 'user_info', value: jsonEncode(data['user']));
        // Registration flow: default 7-day session (no remember-me option at signup).
        await _writeSessionExpiry(rememberMe: false);
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          error: null,
          pendingEmail: null,
          user: data['user'],
        );
        return true;
      } else {
        final data = jsonDecode(response.body);
        state = state.copyWith(isLoading: false, error: data['error'] ?? 'Código incorrecto');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error de conexión con el servidor');
      return false;
    }
  }

  Future<bool> reenviarCodigo(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reenviar-codigo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': normalizeEmail(email)}),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false, error: null);
        return true;
      } else {
        final data = jsonDecode(response.body);
        state = state.copyWith(isLoading: false, error: data['error'] ?? 'Error al reenviar código');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error de conexión con el servidor');
      return false;
    }
  }

  void clearPendingEmail() {
    state = state.copyWith(pendingEmail: null, error: null);
  }

  /// Paso 1 del flujo de recuperación: pide un código por correo.
  /// El backend responde 200 genérico sin importar si el email existe
  /// (anti-enumeración OWASP).
  Future<bool> solicitarReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/solicitar-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': normalizeEmail(email)}),
      );
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false, error: null);
        return true;
      } else {
        final data = jsonDecode(response.body);
        state = state.copyWith(
            isLoading: false,
            error: data['error'] ?? 'Error solicitando código de recuperación');
        return false;
      }
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'Error de conexión con el servidor');
      return false;
    }
  }

  /// Paso 3: valida código + actualiza contraseña.
  /// Si el código es incorrecto, el state.error refleja el mensaje del backend
  /// (incluye intentos restantes).
  Future<bool> resetPassword(
      String email, String codigo, String nuevaPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': normalizeEmail(email),
          'codigo': codigo,
          'password': nuevaPassword,
        }),
      );
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false, error: null);
        return true;
      } else {
        final data = jsonDecode(response.body);
        state = state.copyWith(
            isLoading: false,
            error: data['error'] ?? 'No se pudo actualizar la contraseña');
        return false;
      }
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'Error de conexión con el servidor');
      return false;
    }
  }

  Future<bool> solicitarAcceso(String cargo, String direccionMunicipal) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        state = state.copyWith(isLoading: false, error: 'Sesión expirada. Inicia sesión de nuevo.');
        return false;
      }
      final response = await http.post(
        Uri.parse('$baseUrl/solicitar-acceso'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'cargo': cargo,
          'direccion_municipal': direccionMunicipal,
        }),
      );

      if (response.statusCode == 200) {
        final updatedUser = Map<String, dynamic>.from(state.user ?? {});
        updatedUser['solicitud_operativo'] = 'pendiente';
        await _storage.write(key: 'user_info', value: jsonEncode(updatedUser));
        state = state.copyWith(isLoading: false, user: updatedUser);
        return true;
      } else {
        final data = jsonDecode(response.body);
        state = state.copyWith(isLoading: false, error: data['error'] ?? 'Error al enviar solicitud');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error de conexión con el servidor');
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _clearSession();
    state = AuthState();
  }

  /// Intenta refrescar el access token usando el refresh token almacenado.
  ///
  /// Devuelve true si obtuvo un nuevo par de tokens. Si el refresh ya no es
  /// válido (revocado, expirado o reusado) hace logout y devuelve false —
  /// el caller debe redirigir a login.
  ///
  /// Pensado para ser invocado por wrappers HTTP cuando el backend devuelve
  /// 401, evitando que cada feature implemente su propia lógica de refresh.
  Future<bool> tryRefresh() async {
    final refresh = await _storage.read(key: 'refresh_token');
    if (refresh == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refresh}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'access_token', value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);
        return true;
      }
      // 401/403: refresh inválido — sesión muerta, limpiar.
      await logout();
      return false;
    } catch (_) {
      // Error de red: NO hacer logout (puede ser transiente offline).
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(storage);
});
