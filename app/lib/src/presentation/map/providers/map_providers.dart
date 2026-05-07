import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/seed_data.dart';
import '../layers/plan_regulador_layer.dart';

// ── Capas activas ─────────────────────────────────────────────────────────────

final activeLayersProvider = StateProvider<Set<String>>((ref) => {});

// ── Modo dibujo ───────────────────────────────────────────────────────────────

final isDrawingModeProvider = StateProvider<bool>((ref) => false);
final drawingPointsProvider = StateProvider<List<LatLng>>((ref) => []);

/// null = nueva zona, 'S-2' etc = sector del Plan Regulador a editar
final drawingTargetProvider = StateProvider<String?>((ref) => null);

// ── Estado UI del mapa ────────────────────────────────────────────────────────

final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
final dangerFilterProvider = StateProvider<String>((ref) => 'all');
final heatmapOnProvider = StateProvider<bool>((ref) => false);
final dateRangeProvider = StateProvider<String>((ref) => '30');
final mapCenterCoordsProvider =
    StateProvider<(double, double)>((ref) => (-37.0896, -73.1584));

final activeZoneCategoriesProvider = StateProvider<Set<String>>((ref) => {
      'Seguridad',
      'Infraestructura',
      'Vialidad',
      'Comercio',
      'Comunitario',
    });

// ── Elementos en memoria ──────────────────────────────────────────────────────

final userElementsProvider = StateProvider<List<ElementoMapa>>((ref) => []);

final allElementsProvider = Provider<List<ElementoMapa>>((ref) {
  return [...kElementosSeed, ...ref.watch(userElementsProvider)];
});

final dateLimitProvider = Provider<DateTime?>((ref) {
  final range = ref.watch(dateRangeProvider);
  if (range == 'all') return null;
  final days = int.tryParse(range) ?? 30;
  return DateTime.now().subtract(Duration(days: days));
});

final filteredElementsProvider = Provider<List<ElementoMapa>>((ref) {
  final activeLayers = ref.watch(activeLayersProvider);
  final dangerFilter = ref.watch(dangerFilterProvider);
  final activeZoneCats = ref.watch(activeZoneCategoriesProvider);
  final dateLimit = ref.watch(dateLimitProvider);
  final allElements = ref.watch(allElementsProvider);
  final userPolygons = ref.watch(userPolygonsProvider);

  return allElements.where((e) {
    if (!activeLayers.contains(e.layerKey)) return false;

    final isUserPolygon = userPolygons.any((p) => p.zona.id == e.id);
    if (isUserPolygon) {
      final cat = mapTipoToCat(e.tipo);
      if (!activeZoneCats.contains(cat)) return false;
    }

    if (dateLimit != null) {
      final d = DateTime.tryParse(e.fecha);
      if (d != null && d.isBefore(dateLimit)) return false;
    }
    if (e.tipo == 'zona_peligro' &&
        dangerFilter != 'all' &&
        e.tipoPeligro != dangerFilter) {
      return false;
    }
    return true;
  }).toList();
});

// ── Polígonos dibujados ───────────────────────────────────────────────────────

final userPolygonsProvider =
    StateProvider<List<({List<LatLng> points, ElementoMapa zona})>>(
        (ref) => []);

final filteredUserPolygonsProvider =
    Provider<List<({List<LatLng> points, ElementoMapa zona})>>((ref) {
  final activeLayers = ref.watch(activeLayersProvider);
  final activeZoneCats = ref.watch(activeZoneCategoriesProvider);
  final userPolygons = ref.watch(userPolygonsProvider);
  final dateLimit = ref.watch(dateLimitProvider);

  return userPolygons.where((p) {
    if (!activeLayers.contains(p.zona.layerKey)) return false;
    final cat = mapTipoToCat(p.zona.tipo);
    if (!activeZoneCats.contains(cat)) return false;
    if (dateLimit != null) {
      final d = DateTime.tryParse(p.zona.fecha);
      if (d != null && d.isBefore(dateLimit)) return false;
    }
    return true;
  }).toList();
});

// ── Plan Regulador ────────────────────────────────────────────────────────────

final planReguladorEditsProvider =
    StateProvider<Map<String, List<LatLng>>>((ref) => {});

final planReguladorPolygonsProvider = Provider<List<Polygon>>((ref) {
  final edits = ref.watch(planReguladorEditsProvider);
  return PlanReguladorLayer.buildPolygons(edits: edits);
});

final planReguladorObsProvider =
    StateProvider<Map<String, String>>((ref) => {});

final planReguladorAttrProvider =
    StateProvider<Map<String, String>>((ref) => {});

// ── Controlador del mapa ──────────────────────────────────────────────────────

final mapControllerProvider = Provider<MapController>((ref) => MapController());

// ── Helpers ───────────────────────────────────────────────────────────────────

String mapTipoToCat(String tipo) {
  if (tipo == 'zona_peligro' || tipo.startsWith('reporte_')) return 'Seguridad';
  if (tipo == 'infraestructura' || tipo == 'luminaria' || tipo == 'camara') {
    return 'Infraestructura';
  }
  if (tipo == 'reporte_accidente' || tipo == 'vialidad') return 'Vialidad';
  if (tipo == 'patente') return 'Comercio';
  if (tipo == 'sede_comunitaria' || tipo == 'centro_acopio') return 'Comunitario';
  return 'Seguridad';
}
