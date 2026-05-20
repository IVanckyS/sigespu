import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../config/constants.dart';
import '../../data/seed_data.dart';
import '../auth/auth_provider.dart';

const _scrapingBase = '${AppConstants.apiBaseUrl}/api/scraping';

// ── Status ────────────────────────────────────────────────────────────────────

class ScrapingStatus {
  final bool running;
  final String modo;
  final String fuente;
  final String fuenteLabel;
  final int step;
  final int totalSteps;
  final double progress;
  final int ok;
  final int errores;
  final String? error;

  const ScrapingStatus({
    required this.running,
    required this.modo,
    required this.fuente,
    required this.fuenteLabel,
    required this.step,
    required this.totalSteps,
    required this.progress,
    required this.ok,
    required this.errores,
    this.error,
  });

  factory ScrapingStatus.idle() => const ScrapingStatus(
        running: false, modo: '', fuente: '', fuenteLabel: '',
        step: 0, totalSteps: 0, progress: 0, ok: 0, errores: 0,
      );

  factory ScrapingStatus.fromJson(Map<String, dynamic> j) => ScrapingStatus(
        running: j['running'] == true,
        modo: j['modo'] as String? ?? '',
        fuente: j['fuente'] as String? ?? '',
        fuenteLabel: j['fuente_label'] as String? ?? '',
        step: (j['step'] as num?)?.toInt() ?? 0,
        totalSteps: (j['total_steps'] as num?)?.toInt() ?? 0,
        progress: (j['progress'] as num?)?.toDouble() ?? 0,
        ok: (j['ok'] as num?)?.toInt() ?? 0,
        errores: (j['errores'] as num?)?.toInt() ?? 0,
        error: j['error'] as String?,
      );
}

/// Polling cada 1s mientras la pantalla escucha. La UI lo activa solo durante el
/// scraping para no martillar al backend cuando no hace falta.
final scrapingStatusProvider = StreamProvider.autoDispose<ScrapingStatus>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final controller = StreamController<ScrapingStatus>();
  Timer? timer;

  Future<void> tick() async {
    try {
      final token = await storage.read(key: 'access_token');
      final resp = await http.get(
        Uri.parse('$_scrapingBase/status'),
        headers: token == null ? {} : {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        controller.add(ScrapingStatus.fromJson(json));
      }
    } catch (_) {/* ignore transient */}
  }

  tick();
  timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

// ── Listas de datos ───────────────────────────────────────────────────────────

Future<List<T>> _fetchList<T>(
  Ref ref,
  String path,
  T Function(Map<String, dynamic>) parser,
) async {
  final storage = ref.read(secureStorageProvider);
  final token = await storage.read(key: 'access_token');
  final resp = await http.get(
    Uri.parse('$_scrapingBase/$path?limit=500'),
    headers: token == null ? {} : {'Authorization': 'Bearer $token'},
  );
  if (resp.statusCode != 200) {
    throw Exception('Error al cargar $path: HTTP ${resp.statusCode}');
  }
  final data = jsonDecode(resp.body) as Map<String, dynamic>;
  final items = (data['items'] as List).cast<Map<String, dynamic>>();
  return items.map(parser).toList();
}

final scrapingPatentesProvider = FutureProvider.autoDispose<List<DatoPatente>>(
    (ref) => _fetchList(ref, 'patentes', DatoPatente.fromJson));

final scrapingPermisosProvider = FutureProvider.autoDispose<List<DatoPermiso>>(
    (ref) => _fetchList(ref, 'permisos', DatoPermiso.fromJson));

final scrapingTransitoProvider = FutureProvider.autoDispose<List<DatoTransito>>(
    (ref) => _fetchList(ref, 'transito', DatoTransito.fromJson));

final scrapingOrganizacionesProvider =
    FutureProvider.autoDispose<List<DatoOrganizacion>>(
        (ref) => _fetchList(ref, 'organizaciones', DatoOrganizacion.fromJson));

// ── Acciones (POST) ───────────────────────────────────────────────────────────

class ScrapingController {
  final Ref ref;
  ScrapingController(this.ref);

  Future<({bool ok, String? error})> runActual() => _post('run');
  Future<({bool ok, String? error})> runHistorico() => _post('historico');

  Future<({bool ok, String? error})> _post(String path) async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'access_token');
    if (token == null) return (ok: false, error: 'Sesión expirada');
    try {
      final resp = await http.post(
        Uri.parse('$_scrapingBase/$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '{}',
      );
      if (resp.statusCode == 200) return (ok: true, error: null);
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (ok: false, error: data['error'] as String? ?? 'Error');
    } catch (e) {
      return (ok: false, error: 'Error de conexión: $e');
    }
  }

  void refreshAll() {
    ref.invalidate(scrapingPatentesProvider);
    ref.invalidate(scrapingPermisosProvider);
    ref.invalidate(scrapingTransitoProvider);
    ref.invalidate(scrapingOrganizacionesProvider);
  }
}

final scrapingControllerProvider =
    Provider<ScrapingController>((ref) => ScrapingController(ref));
