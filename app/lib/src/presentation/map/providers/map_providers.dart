import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/constants.dart';
import '../../../data/seed_data.dart';
import '../../auth/auth_provider.dart';
import '../../actividades/actividades_provider.dart';
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

// ── Elementos permanentes (no se filtran por fecha) ───────────────────────────
//
// Infraestructura fija, patentes comerciales y cámaras existen con
// independencia del rango de fechas seleccionado. Solo los incidentes
// transitorios (reportes, árbol caído, fuga de agua, etc.) se filtran.
const _permanentTypes = {
  'centro_acopio',
  'sede_comunitaria',
  'infraestructura',
  'patente',
  'luminaria',
  'camara_cctv',
  'camara',
};

bool _isTransient(String tipo) =>
    !_permanentTypes.contains(tipo) && tipo != 'plan_regulador';

// ── Elementos en memoria y persistencia local ────────────────────────────────

class UserElementsNotifier extends Notifier<List<ElementoMapa>> {
  static const _storageKey = 'sigespu_user_elements';
  static const _polygonsKey = 'sigespu_user_polygons_v1';

  @override
  List<ElementoMapa> build() {
    _load();
    _loadFromBackend();
    return [];
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List list = jsonDecode(jsonStr) as List;
        state = list.map((item) => _fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error cargando elementos locales: $e');
    }
    await _loadLocalPolygons();
  }

  Future<void> _loadLocalPolygons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_polygonsKey);
      if (jsonStr == null || jsonStr.isEmpty) return;
      final List list = jsonDecode(jsonStr) as List;
      final restored = list.map((j) {
        final pts = (j['points'] as List)
            .map((p) => LatLng(
                  (p['lat'] as num).toDouble(),
                  (p['lng'] as num).toDouble(),
                ))
            .toList();
        final zona = _fromJson(j['zona'] as Map<String, dynamic>);
        return (points: pts, zona: zona);
      }).toList();
      if (restored.isNotEmpty) {
        ref.read(userPolygonsProvider.notifier).state = restored;
      }
    } catch (e) {
      print('Error cargando polígonos locales: $e');
    }
  }

  Future<void> savePolygonData(List<LatLng> points, ElementoMapa zona) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_polygonsKey);
      final List current =
          (existing != null && existing.isNotEmpty) ? jsonDecode(existing) as List : [];
      current.removeWhere((j) => j['zona']?['id'] == zona.id);
      current.add({
        'points': points
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
        'zona': _toJson(zona),
      });
      await prefs.setString(_polygonsKey, jsonEncode(current));
    } catch (e) {
      print('Error guardando polígono local: $e');
    }
  }

  Future<void> _loadFromBackend() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'access_token');
      const apiBase = AppConstants.apiBaseUrl;
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      // 1. Cargar Puntos de Interés
      final respPuntos = await http.get(
        Uri.parse('$apiBase/api/elementos'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      List<ElementoMapa> backendElements = [];

      if (respPuntos.statusCode == 200) {
        final List list = jsonDecode(respPuntos.body);
        backendElements.addAll(list.map((j) {
          final p = PuntoInteres.fromJson(j);
          return ElementoMapa(
            id: p.id,
            tipo: p.tipo,
            nombre: p.nombre ?? '',
            direccion: p.direccion ?? '',
            sector: p.metadata?['sector'] ?? 'Centro',
            lat: p.lat,
            lng: p.lng,
            estado: p.estado,
            fecha: p.createdAt?.toIso8601String().substring(0, 10) ?? '',
            by: p.createdBy ?? 'Sistema',
            notas: p.descripcion ?? '',
            capacidad: p.metadata?['capacidad'],
            rut: p.metadata?['rut'],
            giro: p.metadata?['giro'],
            tipoPeligro: p.metadata?['tipoPeligro'],
            nivel: p.metadata?['nivel'],
            horario: p.metadata?['horario'],
          );
        }));
      }

      // 2. Cargar Zonas (opcional, si se implementa el GET en el backend)
      final respZonas = await http.get(
        Uri.parse('$apiBase/api/zonas'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (respZonas.statusCode == 200) {
        final List list = jsonDecode(respZonas.body);
        for (final j in list) {
          final id = j['id'] as String;
          if (backendElements.any((e) => e.id == id)) continue;
          
          final geojson = j['geojson'] as Map<String, dynamic>;
          final coords = (geojson['coordinates'] as List)[0] as List;
          // Calcular centroide para el marcador
          double sumLat = 0, sumLng = 0;
          for (final c in coords) {
            sumLng += c[0];
            sumLat += c[1];
          }
          final lat = sumLat / coords.length;
          final lng = sumLng / coords.length;

          backendElements.add(ElementoMapa(
            id: id,
            tipo: 'zona_peligro',
            nombre: j['nombre'] as String? ?? 'Zona',
            direccion: 'Lota',
            sector: 'Centro',
            lat: lat,
            lng: lng,
            estado: 'activo',
            fecha: (j['createdAt'] as String).substring(0, 10),
            by: 'Sistema',
            notas: j['descripcion'] as String? ?? '',
            nivel: j['nivelRiesgo'] as int?,
            tipoPeligro: j['tipoRiesgo'] as String?,
          ));

          // Actualizar polígonos
          final points = coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
          ref.read(userPolygonsProvider.notifier).update((s) {
            if (s.any((p) => p.zona.id == id)) return s;
            return [...s, (points: points, zona: backendElements.last)];
          });
        }
      }

      if (backendElements.isNotEmpty) {
        // Mezclar con locales, evitando duplicados por ID
        final localIds = state.map((e) => e.id).toSet();
        final newFromBackend = backendElements.where((e) => !localIds.contains(e.id)).toList();
        state = [...state, ...newFromBackend];
      }

    } catch (e) {
      print('Error cargando elementos del backend: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.map((e) => _toJson(e)).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      print('Error guardando elementos locales: $e');
    }
  }

  void update(List<ElementoMapa> Function(List<ElementoMapa>) fn) {
    state = fn(state);
    _save();
  }

  // Mapeo manual ya que ElementoMapa no es un DTO de shared con fromJson/toJson
  Map<String, dynamic> _toJson(ElementoMapa e) => {
    'id': e.id, 'tipo': e.tipo, 'nombre': e.nombre, 'direccion': e.direccion,
    'sector': e.sector, 'lat': e.lat, 'lng': e.lng, 'estado': e.estado,
    'fecha': e.fecha, 'by': e.by, 'notas': e.notas, 'capacidad': e.capacidad,
    'rut': e.rut, 'giro': e.giro, 'tipoPeligro': e.tipoPeligro, 'nivel': e.nivel,
    'horario': e.horario, 'vigenciaHasta': e.vigenciaHasta, 'rubro': e.rubro,
    'tipoAmenaza': e.tipoAmenaza,
  };

  ElementoMapa _fromJson(Map<String, dynamic> j) => ElementoMapa(
    id: j['id'], tipo: j['tipo'], nombre: j['nombre'], direccion: j['direccion'],
    sector: j['sector'], lat: j['lat'], lng: j['lng'], estado: j['estado'],
    fecha: j['fecha'], by: j['by'], notas: j['notas'],
    capacidad: j['capacidad'], rut: j['rut'], giro: j['giro'],
    tipoPeligro: j['tipoPeligro'], nivel: j['nivel'], horario: j['horario'],
    vigenciaHasta: j['vigenciaHasta'], rubro: j['rubro'],
    tipoAmenaza: j['tipoAmenaza'],
  );
}

final userElementsProvider = NotifierProvider<UserElementsNotifier, List<ElementoMapa>>(UserElementsNotifier.new);

class DeletedIdsNotifier extends Notifier<Set<String>> {
  static const _storageKey = 'sigespu_deleted_ids';

  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List list = jsonDecode(jsonStr) as List;
        state = list.cast<String>().toSet();
      }
    } catch (e) {
      print('Error cargando IDs eliminados: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toList()));
    } catch (e) {
      print('Error guardando IDs eliminados: $e');
    }
  }

  void update(Set<String> Function(Set<String>) fn) {
    state = fn(state);
    _save();
  }
}

final deletedElementIdsProvider = NotifierProvider<DeletedIdsNotifier, Set<String>>(DeletedIdsNotifier.new);

final allElementsProvider = Provider<List<ElementoMapa>>((ref) {
  final userElements = ref.watch(userElementsProvider);
  final deletedIds = ref.watch(deletedElementIdsProvider);
  
  final userIds = userElements.map((e) => e.id).toSet();
  
  // Combinar: 
  // 1. Seed data que no ha sido borrada ni sobreescrita
  final filteredSeed = kElementosSeed.where((e) => 
    !deletedIds.contains(e.id) && !userIds.contains(e.id)
  );
  
  // 2. Elementos del usuario (nuevos o ediciones de seed)
  return [...filteredSeed, ...userElements];
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
  final dateLimit = ref.watch(dateLimitProvider);
  final allElements = ref.watch(allElementsProvider);

  return allElements.where((e) {
    if (!activeLayers.contains(e.layerKey)) return false;

    // Solo aplicar filtro de fecha a elementos transitorios (incidentes)
    if (dateLimit != null && _isTransient(e.tipo)) {
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
  final userPolygons = ref.watch(userPolygonsProvider);
  final dateLimit = ref.watch(dateLimitProvider);

  return userPolygons.where((p) {
    if (!activeLayers.contains(p.zona.layerKey)) return false;
    if (dateLimit != null && _isTransient(p.zona.tipo)) {
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

// ── Estado de vistas Tabla y Scraping (para export PDF contextual) ────────────

final tablaFilteredProvider =
    StateProvider<List<ElementoMapa>>((ref) => kElementosSeed);

final scrapingTabIndexProvider = StateProvider<int>((ref) => 0);

final scrapingFilteredPatenteProvider =
    StateProvider<List<DatoPatente>>((ref) => kPatentes);

final scrapingFilteredPermisoProvider =
    StateProvider<List<DatoPermiso>>((ref) => kPermisos);

final scrapingFilteredTransitoProvider =
    StateProvider<List<DatoTransito>>((ref) => kTransito);

final scrapingFilteredOrgProvider =
    StateProvider<List<DatoOrganizacion>>((ref) => kOrganizaciones);

// ── Capa actividades municipales ──────────────────────────────────────────────

final actividadesLayerElementsProvider = Provider<List<ElementoMapa>>((ref) {
  final actividades = ref.watch(actividadesProvider);
  return actividades
      .where((a) => a.lat != null && a.lng != null)
      .map((a) => ElementoMapa(
            id: a.id,
            tipo: 'actividad_${a.tipo.name}',
            nombre: a.titulo,
            lat: a.lat!,
            lng: a.lng!,
            direccion: a.direccion ?? '',
            sector: a.sector ?? '',
            estado: a.estado.name,
            fecha: a.fechaInicio.toIso8601String(),
            by: a.creadoPor,
            notas: a.descripcion,
          ))
      .toList();
});

// ── Support providers for layer counts and filters ───────────────────────────────

/// Conteo dinámico de elementos por layerKey, calculado desde allElementsProvider.
final layerCountsProvider = Provider<Map<String, int>>((ref) {
  final elements = ref.watch(allElementsProvider);
  final counts = <String, int>{};
  for (final e in elements) {
    counts[e.layerKey] = (counts[e.layerKey] ?? 0) + 1;
  }
  return counts;
});

/// Categorías únicas de zonas dibujadas con lápiz (tipo del ElementoMapa en userPolygonsProvider).
final customZonaCategoriesProvider = Provider<List<String>>((ref) {
  final polygons = ref.watch(userPolygonsProvider);
  final cats = polygons.map((p) => p.zona.tipo).toSet().toList()..sort();
  return cats;
});

/// Categorías de zonas dibujadas actualmente visibles.
final activeZonaCategoriesProvider = StateProvider<Set<String>>((ref) => {});
