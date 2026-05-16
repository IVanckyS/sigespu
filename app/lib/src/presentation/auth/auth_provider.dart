import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    if (token != null) {
      // Decode user info from JWT or stored user info
      final userStr = await _storage.read(key: 'user_info');
      Map<String, dynamic>? user;
      if (userStr != null) {
        user = jsonDecode(userStr);
      }
      state = state.copyWith(isAuthenticated: true, user: user);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': normalizeEmail(email), 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'access_token', value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);
        await _storage.write(key: 'user_info', value: jsonEncode(data['user']));
        
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
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_info');
    state = AuthState(); // Reset state
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(storage);
});
