import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import '../../../config/constants.dart';
import '../../../data/remote/cached_api.dart';
import '../../auth/auth_provider.dart';

// ── Active panel ──────────────────────────────────────────────────────────────

enum VisorPanel { none, capas, mapaBase, leyenda, imprimir }

final activePanelProvider = StateProvider<VisorPanel>((ref) => VisorPanel.none);

// ── Tile layer / Basemap ──────────────────────────────────────────────────────

enum MapaBase { cartoVoyager, osm, esriSatelite }

final mapaBaseProvider = StateProvider<MapaBase>((ref) => MapaBase.cartoVoyager);

const mapaBaseUrls = {
  // {r} se resuelve como "@2x" en pantallas de alta densidad cuando
  // TileLayer recibe retinaMode: RetinaMode.isHighDensity(context).
  // En pantallas normales {r} queda vacío y la URL es idéntica a antes.
  MapaBase.cartoVoyager:
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
  // OSM no soporta tiles @2x oficialmente; se omite {r}.
  MapaBase.osm: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  // Esri Satélite tampoco soporta tiles @2x; se omite {r}.
  MapaBase.esriSatelite:
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
};

const mapaBaseSubdomains = {
  MapaBase.cartoVoyager: ['a', 'b', 'c', 'd'],
  MapaBase.osm: <String>[],
  MapaBase.esriSatelite: <String>[],
};

// ── Layer visibility ──────────────────────────────────────────────────────────

/// Current visible map bounds [xmin, ymin, xmax, ymax]
final mapBoundsProvider = StateProvider<List<double>?>((ref) => null);

/// Whether the sismos layer is toggled on
final sismosVisibleProvider = StateProvider<bool>((ref) => false);

/// Map of custom capa id → visible override (null = use capa.visible default)
final customLayersVisibleProvider = StateProvider<Map<String, bool>>((ref) => {});

/// ID of the last interacted or explicitly selected layer for actions like Download
final selectedCapaIdProvider = StateProvider<String?>((ref) => null);

// ── Sismos data ───────────────────────────────────────────────────────────────

final sismosProvider = FutureProvider<List<SismoDto>>((ref) async {
  final storage = ref.read(secureStorageProvider);
  final token = await storage.read(key: 'access_token');
  const apiBase = AppConstants.apiBaseUrl;
  final api = ref.read(cachedApiProvider);

  final resp = await api.get(
    Uri.parse('$apiBase/api/sismos?dias=7&minmagnitude=3.0&maxradiuskm=500'),
    headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    cacheKey: 'api:/api/sismos',
    timeout: const Duration(seconds: 15),
  );

  if (!resp.hasData) return [];
  try {
    final data = jsonDecode(resp.body!) as Map<String, dynamic>;
    final list = (data['sismos'] as List).cast<Map<String, dynamic>>();
    return list.map(SismoDto.fromJson).toList();
  } catch (e) {
    if (kDebugMode) debugPrint('[sismos] parse error: $e');
    return [];
  }
});

// ── Custom layers ──────────────────────────────────────────────────────────────

final capasPersonalizadasProvider =
    FutureProvider<List<CapaPersonalizadaDto>>((ref) async {
  final storage = ref.read(secureStorageProvider);
  final token = await storage.read(key: 'access_token');
  const apiBase = AppConstants.apiBaseUrl;
  final api = ref.read(cachedApiProvider);

  final resp = await api.get(
    Uri.parse('$apiBase/api/capas'),
    headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    cacheKey: 'api:/api/capas',
    timeout: const Duration(seconds: 15),
  );

  if (!resp.hasData) return [];
  try {
    final data = jsonDecode(resp.body!) as Map<String, dynamic>;
    final list = (data['capas'] as List).cast<Map<String, dynamic>>();
    return list.map(CapaPersonalizadaDto.fromJson).toList();
  } catch (e) {
    if (kDebugMode) debugPrint('[capas] parse error: $e');
    return [];
  }
});

/// GeoJSON FeatureCollection for a specific custom capa
final capaGeoJsonProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final storage = ref.read(secureStorageProvider);
  final token = await storage.read(key: 'access_token');
  final bounds = ref.watch(mapBoundsProvider);
  const apiBase = AppConstants.apiBaseUrl;
  final api = ref.read(cachedApiProvider);

  String url = '$apiBase/api/capas/$id/geometrias';
  if (bounds != null && bounds.length == 4) {
    url += '?bbox=${bounds.join(',')}';
  }

  // El cacheKey ignora el bbox: queremos el último GeoJSON para esta capa,
  // independiente del recorte espacial actual.
  final resp = await api.get(
    Uri.parse(url),
    headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    cacheKey: 'api:/api/capas/$id/geometrias',
    timeout: const Duration(seconds: 15),
  );

  if (!resp.hasData) return null;
  try {
    return jsonDecode(resp.body!) as Map<String, dynamic>;
  } catch (e) {
    if (kDebugMode) debugPrint('[capa $id] parse error: $e');
    return null;
  }
});

/// GeoJSON FeatureCollection unificado para una capa base del sistema (tsunami, incendio)
final sistemaTipoGeojsonProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, tipo) async {
  final storage = ref.read(secureStorageProvider);
  final token = await storage.read(key: 'access_token');
  const apiBase = AppConstants.apiBaseUrl;
  final api = ref.read(cachedApiProvider);

  final resp = await api.get(
    Uri.parse('$apiBase/api/capas/sistema/$tipo'),
    headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    cacheKey: 'api:/api/capas/sistema/$tipo',
    timeout: const Duration(seconds: 20),
  );

  if (!resp.hasData) return null;
  try {
    return jsonDecode(resp.body!) as Map<String, dynamic>;
  } catch (e) {
    if (kDebugMode) debugPrint('[sistema $tipo] parse error: $e');
    return null;
  }
});

/// Export/Download a layer
Future<String?> exportCapa(String id) async {
  const apiBase = AppConstants.apiBaseUrl;
  // This just returns the URL for the user to download
  return '$apiBase/api/capas/$id/export';
}

/// Delete a custom layer
Future<bool> deleteCapa(WidgetRef ref, String id) async {
  final storage = ref.read(secureStorageProvider);
  final token = await storage.read(key: 'access_token');
  const apiBase = AppConstants.apiBaseUrl;

  try {
    final resp = await http.delete(
      Uri.parse('$apiBase/api/capas/$id'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    if (resp.statusCode == 200) {
      ref.invalidate(capasPersonalizadasProvider);
      return true;
    }
  } catch (_) {}
  return false;
}
