import 'dart:convert';
import 'dart:math';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constants.dart';
import '../auth/auth_provider.dart';

// ── Modelo de usuario ─────────────────────────────────────────────────────────

class UsuarioItem {
  final String id;
  final String email;
  final String nombre;
  final String nivelAcceso; // director | operativo | visitante
  final String unidad; // Dir. Seg. Pública · DIDECO · etc.
  final String? cargo;
  final String? rut;
  final bool activo;
  final DateTime? ultimaSesion;
  final bool esActual; // si es el usuario logueado actualmente

  const UsuarioItem({
    required this.id,
    required this.email,
    required this.nombre,
    required this.nivelAcceso,
    this.unidad = 'Municipal',
    this.cargo,
    this.rut,
    this.activo = true,
    this.ultimaSesion,
    this.esActual = false,
  });

  factory UsuarioItem.fromJson(Map<String, dynamic> j) => UsuarioItem(
        id: j['id'] as String,
        email: j['email'] as String,
        nombre: j['nombre'] as String,
        nivelAcceso: j['nivel_acceso'] as String? ?? 'visitante',
        unidad: j['unidad'] as String? ?? 'Municipal',
        cargo: j['cargo'] as String?,
        rut: j['rut'] as String?,
        activo: j['activo'] as bool? ?? true,
        ultimaSesion: j['ultima_sesion'] != null
            ? DateTime.tryParse(j['ultima_sesion'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'nombre': nombre,
        'nivel_acceso': nivelAcceso,
        'unidad': unidad,
        if (cargo != null) 'cargo': cargo,
        if (rut != null) 'rut': rut,
        'activo': activo,
        if (ultimaSesion != null) 'ultima_sesion': ultimaSesion!.toIso8601String(),
      };

  UsuarioItem copyWith({
    String? nombre,
    String? nivelAcceso,
    String? unidad,
    String? cargo,
    String? rut,
    bool? activo,
    DateTime? ultimaSesion,
    bool? esActual,
  }) =>
      UsuarioItem(
        id: id,
        email: email,
        nombre: nombre ?? this.nombre,
        nivelAcceso: nivelAcceso ?? this.nivelAcceso,
        unidad: unidad ?? this.unidad,
        cargo: cargo ?? this.cargo,
        rut: rut ?? this.rut,
        activo: activo ?? this.activo,
        ultimaSesion: ultimaSesion ?? this.ultimaSesion,
        esActual: esActual ?? this.esActual,
      );
}

// ── Helpers UI ────────────────────────────────────────────────────────────────

String unidadParaRol(String nivel) {
  switch (nivel) {
    case 'director':
      return 'Dir. Seguridad Pública';
    case 'operativo':
      return 'Inspección';
    default:
      return 'Municipal';
  }
}

const List<String> kUnidadesDisponibles = [
  'Dir. Seguridad Pública',
  'DIDECO',
  'Tránsito',
  'Obras',
  'SECPLA',
  'Inspección',
  'Municipal',
];

// ── Notifier ──────────────────────────────────────────────────────────────────

const _kSeedUsers = [
  UsuarioItem(
    id: 'seed-001',
    email: 'director@lota.cl',
    nombre: 'Director Seguridad Pública',
    nivelAcceso: 'director',
    unidad: 'Dir. Seguridad Pública',
    cargo: 'Director',
    activo: true,
  ),
  UsuarioItem(
    id: 'seed-002',
    email: 'inspector1@lota.cl',
    nombre: 'Juan Pérez',
    nivelAcceso: 'operativo',
    unidad: 'Inspección',
    cargo: 'Inspector municipal',
    activo: true,
  ),
  UsuarioItem(
    id: 'seed-003',
    email: 'msilva@lota.cl',
    nombre: 'María Silva',
    nivelAcceso: 'visitante',
    unidad: 'Municipal',
    activo: true,
  ),
];

class UsersNotifier extends AsyncNotifier<List<UsuarioItem>> {
  static String get _baseUrl => '${AppConstants.apiBaseUrl}/auth';
  static const _localKey = 'sigespu_local_users_v1';

  @override
  Future<List<UsuarioItem>> build() => _fetch();

  Future<List<UsuarioItem>> _fetch() async {
    // 1. Intento traer del backend (silencioso si falla)
    final remote = await _fetchRemote();

    // 2. Cargo creados localmente (persistidos en SharedPreferences)
    final local = await _loadLocal();

    // 3. Merge: backend tiene prioridad; locales se agregan si no existe el email
    final byEmail = <String, UsuarioItem>{};
    for (final u in (remote ?? _kSeedUsers)) {
      byEmail[u.email] = u;
    }
    for (final u in local) {
      byEmail.putIfAbsent(u.email, () => u);
    }

    // 4. Inyectar al usuario actual si no está
    final auth = ref.read(authProvider);
    final me = auth.user;
    if (me != null && me['email'] != null) {
      final email = me['email'] as String;
      final mine = UsuarioItem(
        id: me['id']?.toString() ?? 'me-${email.hashCode}',
        email: email,
        nombre: (me['nombre'] as String?) ?? email.split('@').first,
        nivelAcceso: (me['nivel_acceso'] as String?) ?? 'visitante',
        unidad: (me['unidad'] as String?) ??
            unidadParaRol((me['nivel_acceso'] as String?) ?? 'visitante'),
        cargo: me['cargo'] as String?,
        rut: me['rut'] as String?,
        activo: true,
        ultimaSesion: DateTime.now(),
        esActual: true,
      );
      // Si ya existe (por email), lo reemplazo marcándolo como actual
      byEmail[email] = mine;
    }

    return byEmail.values.toList()
      ..sort((a, b) {
        // Director primero, luego operativos, luego visitantes
        const order = {'director': 0, 'operativo': 1, 'visitante': 2};
        final ra = order[a.nivelAcceso] ?? 3;
        final rb = order[b.nivelAcceso] ?? 3;
        if (ra != rb) return ra.compareTo(rb);
        return a.nombre.compareTo(b.nombre);
      });
  }

  Future<List<UsuarioItem>?> _fetchRemote() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'access_token');
      final response = await http
          .get(
            Uri.parse('$_baseUrl/usuarios'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return list
            .map((j) => UsuarioItem.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[users] fetch remote: $e');
    }
    return null;
  }

  Future<List<UsuarioItem>> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map((j) => UsuarioItem.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[users] load local: $e');
      return [];
    }
  }

  Future<void> _saveLocal(List<UsuarioItem> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Solo persistimos los locales (no los seed ni el usuario actual)
      final toPersist = users
          .where((u) => u.id.startsWith('local-'))
          .map((u) => u.toJson())
          .toList();
      await prefs.setString(_localKey, jsonEncode(toPersist));
    } catch (e) {
      if (kDebugMode) debugPrint('[users] save local: $e');
    }
  }

  Future<({bool ok, String? error})> crear({
    required String email,
    required String nombre,
    required String password,
    required String rol,
    required String unidad,
    String? cargo,
    String? rut,
  }) async {
    final emailNorm = email.trim().toLowerCase();

    // Validación de dominio (regla del proyecto)
    if (!emailNorm.endsWith('@lota.cl') && !emailNorm.endsWith('@munilota.cl')) {
      return (
        ok: false,
        error:
            'Solo emails @lota.cl o @munilota.cl están permitidos.',
      );
    }

    // Validación de duplicado
    final current = state.value ?? [];
    if (current.any((u) => u.email.toLowerCase() == emailNorm)) {
      return (ok: false, error: 'Ya existe un usuario con ese email.');
    }

    if (password.length < 8) {
      return (
        ok: false,
        error: 'La contraseña debe tener al menos 8 caracteres.',
      );
    }

    // Intentar registro en backend (silencioso si falla)
    try {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'access_token');
      await http
          .post(
            Uri.parse('$_baseUrl/usuarios'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'email': emailNorm,
              'nombre': nombre,
              'password': password,
              'nivel_acceso': rol,
              'unidad': unidad,
              if (cargo != null) 'cargo': cargo,
              if (rut != null) 'rut': rut,
            }),
          )
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      if (kDebugMode) debugPrint('[users] backend create: $e');
    }

    // Persistir local sí o sí (offline-first)
    final nuevo = UsuarioItem(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      email: emailNorm,
      nombre: nombre.trim(),
      nivelAcceso: rol,
      unidad: unidad,
      cargo: cargo,
      rut: rut,
      activo: true,
      ultimaSesion: null,
    );
    final next = [...current, nuevo];
    state = AsyncData(next);
    await _saveLocal(next);
    return (ok: true, error: null);
  }

  Future<void> editar(
    String id, {
    required String nombre,
    required String rol,
    required String unidad,
    String? cargo,
    String? rut,
    String? nuevaPassword,
  }) async {
    // Intentar actualizar contraseña en backend si se proporcionó una nueva
    if (nuevaPassword != null && nuevaPassword.isNotEmpty) {
      try {
        final storage = ref.read(secureStorageProvider);
        final token = await storage.read(key: 'access_token');
        await http
            .patch(
              Uri.parse('$_baseUrl/usuarios/$id/password'),
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
              body: jsonEncode({'password': nuevaPassword}),
            )
            .timeout(const Duration(seconds: 6));
      } catch (e) {
        if (kDebugMode) debugPrint('[users] backend update password: $e');
      }
    }

    final current = state.value ?? [];
    final next = current
        .map((u) => u.id == id
            ? u.copyWith(
                nombre: nombre,
                nivelAcceso: rol,
                unidad: unidad,
                cargo: cargo,
                rut: rut,
              )
            : u)
        .toList();
    state = AsyncData(next);
    await _saveLocal(next);
  }

  Future<void> eliminar(String id) async {
    final current = state.value ?? [];
    final next = current.where((u) => u.id != id).toList();
    state = AsyncData(next);
    await _saveLocal(next);
  }

  Future<void> toggleActivo(String id) async {
    final current = state.value ?? [];
    final next = current
        .map((u) => u.id == id ? u.copyWith(activo: !u.activo) : u)
        .toList();
    state = AsyncData(next);
    await _saveLocal(next);
  }
}

final usersProvider =
    AsyncNotifierProvider<UsersNotifier, List<UsuarioItem>>(UsersNotifier.new);

// ── State de filtros ──────────────────────────────────────────────────────────

final usersSearchProvider = StateProvider<String>((ref) => '');
final usersRolFilterProvider = StateProvider<String>((ref) => 'all');
final usersUnidadFilterProvider = StateProvider<String>((ref) => 'all');
final usersEstadoFilterProvider = StateProvider<String>((ref) => 'activos');

final usersFiltradosProvider = Provider<List<UsuarioItem>>((ref) {
  final all = ref.watch(usersProvider).value ?? [];
  final q = ref.watch(usersSearchProvider).trim().toLowerCase();
  final rol = ref.watch(usersRolFilterProvider);
  final unidad = ref.watch(usersUnidadFilterProvider);
  final estado = ref.watch(usersEstadoFilterProvider);

  return all.where((u) {
    if (rol != 'all' && u.nivelAcceso != rol) return false;
    if (unidad != 'all' && u.unidad != unidad) return false;
    if (estado == 'activos' && !u.activo) return false;
    if (estado == 'inactivos' && u.activo) return false;
    if (q.isNotEmpty) {
      final hay = '${u.nombre} ${u.email} ${u.rut ?? ''} ${u.cargo ?? ''}'
          .toLowerCase();
      if (!hay.contains(q)) return false;
    }
    return true;
  }).toList();
});

// ── Password generator ────────────────────────────────────────────────────────

String generarPasswordSegura({int length = 12}) {
  const alfabeto =
      'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@\$%&*?';
  final rng = Random.secure();
  return List.generate(length, (_) => alfabeto[rng.nextInt(alfabeto.length)])
      .join();
}

// ── Excel export ──────────────────────────────────────────────────────────────

List<int> usersToExcel(List<UsuarioItem> users) {
  final wb = Excel.createExcel();
  final sheet = wb['Usuarios'];
  // Eliminar hoja por defecto "Sheet1" si quedó vacía
  wb.delete('Sheet1');

  // Cabecera en negrita
  final headers = ['Nombre', 'Email', 'RUT', 'Unidad', 'Cargo', 'Rol', 'Estado', 'Última sesión'];
  for (var i = 0; i < headers.length; i++) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
    cell.value = TextCellValue(headers[i]);
    cell.cellStyle = CellStyle(bold: true);
  }

  // Filas de datos
  for (var r = 0; r < users.length; r++) {
    final u = users[r];
    final row = [
      u.nombre,
      u.email,
      u.rut ?? '',
      u.unidad,
      u.cargo ?? '',
      u.nivelAcceso,
      u.activo ? 'Activo' : 'Inactivo',
      u.ultimaSesion?.toIso8601String() ?? '',
    ];
    for (var c = 0; c < row.length; c++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
          .value = TextCellValue(row[c]);
    }
  }

  return wb.encode() ?? [];
}
