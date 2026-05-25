import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/constants.dart';
import '../../../data/providers.dart';
import '../../../data/remote/cached_api.dart';
import '../../../data/seed_data.dart';
import '../../auth/auth_provider.dart';
import '../../actividades/actividades_provider.dart';
import '../layers/plan_regulador_layer.dart';
import 'visor_provider.dart';

// ── Capas activas ─────────────────────────────────────────────────────────────

final activeLayersProvider = StateProvider<Set<String>>((ref) => {});

// ── Ubicación del usuario (GPS) ───────────────────────────────────────────────

/// Última posición GPS obtenida del dispositivo. `null` mientras el usuario
/// no haya pedido localizarse o no se haya conseguido lectura todavía.
/// El marker dedicado en el mapa solo se renderiza cuando este provider
/// tiene un valor — así no aparece un punto fantasma en (0,0) al cargar.
final userLocationProvider = StateProvider<LatLng?>((ref) => null);

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

final _logElems = Logger('UserElements');
final _logDeleted = Logger('DeletedIds');

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
      _logElems.warning('Error cargando elementos locales', e);
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
      _logElems.warning('Error cargando polígonos locales', e);
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
      _logElems.warning('Error guardando polígono local', e);
    }
  }

  Future<void> _loadFromBackend() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'access_token');
      const apiBase = AppConstants.apiBaseUrl;
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;
      final api = ref.read(cachedApiProvider);

      // 1. Puntos de Interés — cache-first
      final puntosResp = await api.get(
        Uri.parse('$apiBase/api/elementos'),
        headers: headers,
        cacheKey: 'api:/api/elementos',
      );

      final backendElements = <ElementoMapa>[];

      if (puntosResp.hasData) {
        try {
          final List list = jsonDecode(puntosResp.body!);
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
        } catch (e) {
          _logElems.fine('Elemento mal formado del backend: $e');
        }
      }

      // 2. Zonas — cache-first
      final zonasResp = await api.get(
        Uri.parse('$apiBase/api/zonas'),
        headers: headers,
        cacheKey: 'api:/api/zonas',
      );

      if (zonasResp.hasData) {
        try {
          final List list = jsonDecode(zonasResp.body!);
          for (final j in list) {
            final id = j['id'] as String;
            if (backendElements.any((e) => e.id == id)) continue;

            final geojson = j['geojson'] as Map<String, dynamic>;
            final coords = (geojson['coordinates'] as List)[0] as List;
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

            final points = coords
                .map((c) => LatLng(c[1] as double, c[0] as double))
                .toList();
            ref.read(userPolygonsProvider.notifier).update((s) {
              if (s.any((p) => p.zona.id == id)) return s;
              return [...s, (points: points, zona: backendElements.last)];
            });
          }
        } catch (e) {
          _logElems.fine('Zona mal formada del backend: $e');
        }
      }

      if (backendElements.isNotEmpty) {
        final localIds = state.map((e) => e.id).toSet();
        final newFromBackend =
            backendElements.where((e) => !localIds.contains(e.id)).toList();
        if (newFromBackend.isNotEmpty) {
          state = [...state, ...newFromBackend];
        }
      }
    } catch (e) {
      // Capa final de seguridad: cualquier error inesperado no rompe la app.
      _logElems.warning('_loadFromBackend falló', e);
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.map((e) => _toJson(e)).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      _logElems.warning('Error guardando elementos locales', e);
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
      _logDeleted.warning('Error cargando', e);
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toList()));
    } catch (e) {
      _logDeleted.warning('Error guardando', e);
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
  final activeCats = ref.watch(activeZonaCategoriesProvider);

  // El toggle "Mostrar zonas dibujadas" activa la pseudo-capa 'zona_custom'.
  // Sin él, las zonas no se muestran independientemente del tipo real.
  final showAllCustom = activeLayers.contains('zona_custom');

  return userPolygons.where((p) {
    if (!showAllCustom && !activeLayers.contains(p.zona.layerKey)) return false;
    // Si hay filtro por tipo de peligro activo, aplica solo a zonas de seguridad
    // (las únicas que llevan p.zona.tipoPeligro). El resto pasa siempre.
    if (activeCats.isNotEmpty && p.zona.tipoPeligro != null) {
      if (!activeCats.contains(p.zona.tipoPeligro)) return false;
    }
    if (dateLimit != null && _isTransient(p.zona.tipo)) {
      final d = DateTime.tryParse(p.zona.fecha);
      if (d != null && d.isBefore(dateLimit)) return false;
    }
    return true;
  }).toList();
});

// ── Plan Regulador ────────────────────────────────────────────────────────────

class PlanReguladorEditsNotifier extends Notifier<Map<String, List<LatLng>>> {
  static const _storageKey = 'sigespu_plan_regulador_edits_v1';

  @override
  Map<String, List<LatLng>> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = map.map((k, v) {
        final pts = (v as List).map((p) {
          final m = p as Map<String, dynamic>;
          return LatLng(
            (m['lat'] as num).toDouble(),
            (m['lng'] as num).toDouble(),
          );
        }).toList();
        return MapEntry(k, pts);
      });
    } catch (_) {
      // Si el JSON está corrupto, ignoramos: state se queda vacío.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = state.map((k, v) => MapEntry(
            k,
            v.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
          ));
      await prefs.setString(_storageKey, jsonEncode(encoded));
    } catch (_) {}
  }

  void setSector(String code, List<LatLng> points) {
    state = {...state, code: points};
    _persist();
  }

  void clearSector(String code) {
    final next = Map<String, List<LatLng>>.from(state)..remove(code);
    state = next;
    _persist();
  }
}

final planReguladorEditsProvider = NotifierProvider<
    PlanReguladorEditsNotifier, Map<String, List<LatLng>>>(
  PlanReguladorEditsNotifier.new,
);

final planReguladorPolygonsProvider = Provider<List<Polygon>>((ref) {
  final edits = ref.watch(planReguladorEditsProvider);
  final isDrawing = ref.watch(isDrawingModeProvider);
  final target = ref.watch(drawingTargetProvider);
  return PlanReguladorLayer.buildPolygons(
    edits: edits,
    hiddenCode: isDrawing ? target : null,
  );
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

final scrapingFilteredOrgProvider =
    StateProvider<List<DatoOrganizacion>>((ref) => kOrganizaciones);

// Página actual del scraping (los 20 registros visibles en pantalla).
// Usado por el PDF export para exportar solo lo que está en pantalla.
final scrapingPagedPatenteProvider =
    StateProvider<List<DatoPatente>>((ref) => const []);

final scrapingPagedPermisoProvider =
    StateProvider<List<DatoPermiso>>((ref) => const []);

final scrapingPagedOrgProvider =
    StateProvider<List<DatoOrganizacion>>((ref) => const []);

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

// ── Providers memoizados (evitan recomputaciones por gesto/rebuild) ──────────

/// HeatMapDataSource memoizado: solo se reconstruye cuando cambia allElements.
///
/// Antes se reconstruía en cada `build()` del MapScreen, lo que incluía cada
/// frame del gesto de paneo.
class _CachedHeatMapDataSource extends HeatMapDataSource {
  final List<WeightedLatLng> _data;
  _CachedHeatMapDataSource(this._data);

  @override
  List<WeightedLatLng> getData(LatLngBounds bounds, double zoom) => _data;
}

final heatmapDataSourceProvider = Provider<HeatMapDataSource>((ref) {
  final all = ref.watch(allElementsProvider);
  // El mapa de calor es filtrable por tipo y rango de fechas (CLAUDE.md §8),
  // igual que las capas de marcadores.
  final dangerFilter = ref.watch(dangerFilterProvider);
  final dateLimit = ref.watch(dateLimitProvider);

  final data = <WeightedLatLng>[];
  for (final e in all) {
    final isZona = e.tipo == 'zona_peligro';
    if (!isZona && !e.tipo.startsWith('reporte_')) continue;

    // Filtro de fecha: solo a elementos transitorios (reportes/incidentes).
    if (dateLimit != null && _isTransient(e.tipo)) {
      final d = DateTime.tryParse(e.fecha);
      if (d != null && d.isBefore(dateLimit)) continue;
    }
    // Filtro por tipo de peligro: aplica a las zonas de peligro.
    if (isZona && dangerFilter != 'all' && e.tipoPeligro != dangerFilter) {
      continue;
    }

    // Peso por nivel de riesgo/severidad (1-5 normalizado a 0.2-1.0), CLAUDE.md §8.
    data.add(WeightedLatLng(
      e.latLng,
      ((e.nivel ?? 3) * 0.2).clamp(0.2, 1.0),
    ));
  }
  return _CachedHeatMapDataSource(data);
});

/// Entidades del syncQueueTable que representan elementos del mapa.
/// Activities, reports y demás viven en sus propios providers de "pending".
const _kElementSyncEntidades = ['punto_interes', 'zona_peligro'];

/// Stream reactivo de IDs con entries pendientes en el syncQueueTable.
/// Cuando el SyncService confirma la subida al backend, elimina el row de
/// la cola y este stream emite el set sin ese id → la UI re-construye sin
/// el badge "Pendiente sync".
final _pendingSyncIdsStreamProvider = StreamProvider<Set<String>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.syncQueueTable)
    ..where((t) => t.entidad.isIn(_kElementSyncEntidades));
  return query
      .watch()
      .map((rows) => {for (final r in rows) r.entidadId});
});

/// Set de IDs de elementos pendientes de sincronizar con el backend.
/// Lee del syncQueueTable (fuente de verdad), no del cache local — así un
/// elemento creado y sincronizado deja de aparecer como "Pendiente sync".
final pendingElementIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(_pendingSyncIdsStreamProvider).value ?? const {};
});

/// Geometrías parseadas de una capa personalizada (markers/polygons/polylines).
///
/// Parsear el GeoJSON con cientos/miles de features es caro. Esta familia
/// memoiza el resultado por id de capa: solo se re-ejecuta cuando cambia el
/// GeoJSON crudo (cambio de bounds) o los metadatos de la capa.
typedef CapaGeometries = ({
  List<({double lat, double lng, int color})> points,
  List<({List<({double lat, double lng})> ring, int color, double opacidad})>
      polygons,
  List<({List<({double lat, double lng})> line, int color})> lines,
});

final capaParsedGeomsProvider =
    Provider.family<CapaGeometries?, String>((ref, capaId) {
  final fcAsync = ref.watch(capaGeoJsonProviderRef(capaId));
  final fc = fcAsync;
  if (fc == null) return null;

  final capa = ref.watch(_capaByIdProvider(capaId));
  if (capa == null) return null;

  final baseColorVal =
      int.tryParse(capa.color.replaceFirst('#', '0xFF')) ?? 0xFFFF5722;

  final points = <({double lat, double lng, int color})>[];
  final polygons =
      <({List<({double lat, double lng})> ring, int color, double opacidad})>[];
  final lines = <({List<({double lat, double lng})> line, int color})>[];

  final features = (fc['features'] as List).cast<Map<String, dynamic>>();
  for (final f in features) {
    final geom = f['geometry'] as Map<String, dynamic>?;
    if (geom == null) continue;
    final type = geom['type'] as String;
    final coords = geom['coordinates'];
    final props = f['properties'] as Map<String, dynamic>? ?? {};

    int colorVal = baseColorVal;
    if (props.containsKey('kml_color')) {
      final kml = props['kml_color'] as String;
      if (kml.length == 8) {
        final a = int.parse(kml.substring(0, 2), radix: 16);
        final b = int.parse(kml.substring(2, 4), radix: 16);
        final g = int.parse(kml.substring(4, 6), radix: 16);
        final r = int.parse(kml.substring(6, 8), radix: 16);
        colorVal = (a << 24) | (r << 16) | (g << 8) | b;
      }
    } else {
      // variación tonal por hash del id
      final seed = (f['id']?.toString().hashCode ?? 0) % 100;
      final lightnessShift = (seed - 50) / 330;
      // aproximación rápida: aclarar/oscurecer canales RGB
      final r = ((baseColorVal >> 16) & 0xFF).toDouble();
      final g = ((baseColorVal >> 8) & 0xFF).toDouble();
      final b = (baseColorVal & 0xFF).toDouble();
      final factor = 1.0 + lightnessShift.clamp(-0.4, 0.4);
      final nr = (r * factor).clamp(0, 255).toInt();
      final ng = (g * factor).clamp(0, 255).toInt();
      final nb = (b * factor).clamp(0, 255).toInt();
      colorVal = 0xFF000000 | (nr << 16) | (ng << 8) | nb;
    }

    if (type == 'Point') {
      final c = coords as List;
      points.add((
        lat: (c[1] as num).toDouble(),
        lng: (c[0] as num).toDouble(),
        color: colorVal,
      ));
    } else if (type == 'Polygon') {
      final rings = (coords as List).cast<List>();
      final ring = <({double lat, double lng})>[
        for (final c in rings.first.cast<List>())
          (lat: (c[1] as num).toDouble(), lng: (c[0] as num).toDouble()),
      ];
      polygons.add((ring: ring, color: colorVal, opacidad: capa.opacidad));
    } else if (type == 'MultiPolygon') {
      for (final polyCoords in (coords as List)) {
        final rings = (polyCoords as List).cast<List>();
        final ring = <({double lat, double lng})>[
          for (final c in rings.first.cast<List>())
            (lat: (c[1] as num).toDouble(), lng: (c[0] as num).toDouble()),
        ];
        polygons.add((ring: ring, color: colorVal, opacidad: capa.opacidad));
      }
    } else if (type == 'LineString') {
      final line = <({double lat, double lng})>[
        for (final c in (coords as List).cast<List>())
          (lat: (c[1] as num).toDouble(), lng: (c[0] as num).toDouble()),
      ];
      lines.add((line: line, color: colorVal));
    } else if (type == 'MultiLineString') {
      for (final lineCoords in (coords as List)) {
        final line = <({double lat, double lng})>[
          for (final c in (lineCoords as List).cast<List>())
            (lat: (c[1] as num).toDouble(), lng: (c[0] as num).toDouble()),
        ];
        lines.add((line: line, color: colorVal));
      }
    }
  }

  return (points: points, polygons: polygons, lines: lines);
});

// Helper: capa por id desde el provider async (resuelto)
final _capaByIdProvider =
    Provider.family<CapaPersonalizadaDto?, String>((ref, id) {
  return ref.watch(capasPersonalizadasProvider).maybeWhen(
        data: (list) {
          for (final c in list) {
            if (c.id == id) return c;
          }
          return null;
        },
        orElse: () => null,
      );
});

// Helper: GeoJSON crudo de una capa, resuelto. Devuelve null si aún no cargó.
final capaGeoJsonProviderRef =
    Provider.family<Map<String, dynamic>?, String>((ref, id) {
  return ref.watch(capaGeoJsonProvider(id)).maybeWhen(
        data: (v) => v,
        orElse: () => null,
      );
});
