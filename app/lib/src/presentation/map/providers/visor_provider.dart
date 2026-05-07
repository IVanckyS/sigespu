import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import '../../../config/constants.dart';

// ── Active panel ──────────────────────────────────────────────────────────────

enum VisorPanel { none, capas, mapaBase, leyenda, imprimir }

final activePanelProvider = StateProvider<VisorPanel>((ref) => VisorPanel.none);

// ── Tile layer / Basemap ──────────────────────────────────────────────────────

enum MapaBase { cartoVoyager, osm, esriSatelite }

final mapaBaseProvider = StateProvider<MapaBase>((ref) => MapaBase.cartoVoyager);

const mapaBaseUrls = {
  MapaBase.cartoVoyager:
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
  MapaBase.osm: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  MapaBase.esriSatelite:
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
};

const mapaBaseSubdomains = {
  MapaBase.cartoVoyager: ['a', 'b', 'c', 'd'],
  MapaBase.osm: <String>[],
  MapaBase.esriSatelite: <String>[],
};

// ── Layer visibility ──────────────────────────────────────────────────────────

/// Whether the sismos layer is toggled on
final sismosVisibleProvider = StateProvider<bool>((ref) => false);

/// Map of custom capa id → visible override (null = use capa.visible default)
final customLayersVisibleProvider = StateProvider<Map<int, bool>>((ref) => {});

// ── Sismos data ───────────────────────────────────────────────────────────────

final sismosProvider = FutureProvider<List<SismoDto>>((ref) async {
  // TODO(sprint-3): replace with token from auth provider
  const apiBase = AppConstants.apiBaseUrl;
  final resp = await http.get(
    Uri.parse('$apiBase/api/sismos?dias=7&minmagnitude=3.0&maxradiuskm=500'),
  ).timeout(const Duration(seconds: 15));
  if (resp.statusCode != 200) return [];
  final data = jsonDecode(resp.body) as Map<String, dynamic>;
  final list = (data['sismos'] as List).cast<Map<String, dynamic>>();
  return list.map(SismoDto.fromJson).toList();
});

// ── Custom layers ──────────────────────────────────────────────────────────────

final capasPersonalizadasProvider =
    FutureProvider<List<CapaPersonalizadaDto>>((ref) async {
  // TODO(sprint-3): replace with token from auth provider
  const apiBase = AppConstants.apiBaseUrl;
  final resp = await http.get(
    Uri.parse('$apiBase/api/capas'),
  ).timeout(const Duration(seconds: 15));
  if (resp.statusCode != 200) return [];
  final data = jsonDecode(resp.body) as Map<String, dynamic>;
  final list = (data['capas'] as List).cast<Map<String, dynamic>>();
  return list.map(CapaPersonalizadaDto.fromJson).toList();
});

/// GeoJSON FeatureCollection for a specific custom capa
final capaGeoJsonProvider =
    FutureProvider.family<Map<String, dynamic>?, int>((ref, id) async {
  // TODO(sprint-3): replace with token from auth provider
  const apiBase = AppConstants.apiBaseUrl;
  final resp = await http.get(
    Uri.parse('$apiBase/api/capas/$id/geometrias'),
  ).timeout(const Duration(seconds: 15));
  if (resp.statusCode != 200) return null;
  return jsonDecode(resp.body) as Map<String, dynamic>;
});
