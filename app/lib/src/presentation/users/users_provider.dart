import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';

class UsuarioItem {
  final String id;
  final String email;
  final String nombre;
  final String nivelAcceso;
  final bool activo;

  const UsuarioItem({
    required this.id,
    required this.email,
    required this.nombre,
    required this.nivelAcceso,
    required this.activo,
  });

  factory UsuarioItem.fromJson(Map<String, dynamic> j) => UsuarioItem(
        id: j['id'] as String,
        email: j['email'] as String,
        nombre: j['nombre'] as String,
        nivelAcceso: j['nivel_acceso'] as String,
        activo: j['activo'] as bool? ?? true,
      );

  UsuarioItem copyWith({String? nombre, String? nivelAcceso, bool? activo}) =>
      UsuarioItem(
        id: id,
        email: email,
        nombre: nombre ?? this.nombre,
        nivelAcceso: nivelAcceso ?? this.nivelAcceso,
        activo: activo ?? this.activo,
      );
}

// TODO(sprint-3): replace mock with real GET /auth/usuarios when endpoint exists
const _kMockUsers = [
  UsuarioItem(
    id: 'seed-001',
    email: 'director@lota.cl',
    nombre: 'Director Seguridad Pública',
    nivelAcceso: 'director',
    activo: true,
  ),
  UsuarioItem(
    id: 'seed-002',
    email: 'inspector1@lota.cl',
    nombre: 'Juan Pérez',
    nivelAcceso: 'operativo',
    activo: true,
  ),
  UsuarioItem(
    id: 'seed-003',
    email: 'msilva@lota.cl',
    nombre: 'María Silva',
    nivelAcceso: 'visitante',
    activo: true,
  ),
];

class UsersNotifier extends AsyncNotifier<List<UsuarioItem>> {
  static const _baseUrl = 'http://localhost:8080/auth';

  @override
  Future<List<UsuarioItem>> build() => _fetch();

  Future<List<UsuarioItem>> _fetch() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'access_token');
      final response = await http
          .get(Uri.parse('$_baseUrl/usuarios'),
              headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return list
            .map((j) => UsuarioItem.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback to mock while endpoint doesn't exist
    }
    return List.from(_kMockUsers);
  }

  Future<void> crear(String email, String nombre, String rol) async {
    // TODO(sprint-3): POST /auth/usuarios
    final nuevo = UsuarioItem(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      nombre: nombre,
      nivelAcceso: rol,
      activo: true,
    );
    state = AsyncData([...state.valueOrNull ?? [], nuevo]);
  }

  Future<void> editar(String id, String nombre, String rol) async {
    // TODO(sprint-3): PATCH /auth/usuarios/:id
    state = AsyncData(
      (state.valueOrNull ?? [])
          .map((u) =>
              u.id == id ? u.copyWith(nombre: nombre, nivelAcceso: rol) : u)
          .toList(),
    );
  }

  Future<void> eliminar(String id) async {
    // TODO(sprint-3): DELETE /auth/usuarios/:id
    state = AsyncData(
        (state.valueOrNull ?? []).where((u) => u.id != id).toList());
  }
}

final usersProvider =
    AsyncNotifierProvider<UsersNotifier, List<UsuarioItem>>(UsersNotifier.new);
