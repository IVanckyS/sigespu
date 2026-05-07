import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../auth/auth_provider.dart';

class Solicitud {
  final String id;
  final String email;
  final String nombre;
  final String cargo;
  final String direccion;
  final String fecha;
  final String estado;

  const Solicitud({
    required this.id,
    required this.email,
    required this.nombre,
    required this.cargo,
    required this.direccion,
    required this.fecha,
    required this.estado,
  });

  factory Solicitud.fromJson(Map<String, dynamic> j) => Solicitud(
        id: j['id'] as String,
        email: j['email'] as String,
        nombre: j['nombre'] as String,
        cargo: j['cargo'] as String? ?? '',
        direccion: j['direccion'] as String? ?? '',
        fecha: j['fecha'] as String? ?? '',
        estado: j['estado'] as String? ?? 'pendiente',
      );
}

class SolicitudesNotifier extends AsyncNotifier<List<Solicitud>> {
  static const _baseUrl = 'http://localhost:8080/auth';

  @override
  Future<List<Solicitud>> build() => _fetch();

  Future<List<Solicitud>> _fetch() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse('$_baseUrl/solicitudes'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error al cargar solicitudes: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List;
    return list
        .map((j) => Solicitud.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> resolver(String id, String accion) async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'access_token');
    final response = await http.put(
      Uri.parse('$_baseUrl/solicitudes/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'accion': accion}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al resolver solicitud: ${response.statusCode}');
    }
    ref.invalidateSelf();
  }
}

final solicitudesProvider =
    AsyncNotifierProvider<SolicitudesNotifier, List<Solicitud>>(
  SolicitudesNotifier.new,
);
