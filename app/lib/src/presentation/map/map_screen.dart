import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared/shared.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../data/seed_data.dart';
import '../../data/providers.dart';
import 'layers/plan_regulador_layer.dart';
import 'layers/custom_markers.dart';
import 'widgets/add_element_modal.dart';
import 'widgets/element_detail_sheet.dart';
import 'widgets/zona_form_sheet.dart';
import 'widgets/plan_regulador_sheet.dart';
import 'widgets/barra_visor.dart';
import 'widgets/panel_capas.dart';
import 'widgets/panel_mapa_base.dart';
import 'widgets/panel_leyenda.dart';
import 'widgets/panel_imprimir.dart';
import 'screens/subir_capa_screen.dart';
import 'providers/visor_provider.dart';

// ── Providers de estado del mapa ──────────────────────────────────────────────

final activeLayersProvider = StateProvider<Set<String>>((ref) => {
  'centro_acopio', 'sede_comunitaria', 'zona_peligro', 'patente',
  'reporte', 'infraestructura', 'plan_regulador',
});

final isDrawingModeProvider = StateProvider<bool>((ref) => false);
final drawingPointsProvider = StateProvider<List<LatLng>>((ref) => []);
final drawingTargetProvider = StateProvider<String?>((ref) => null); // null = nueva zona, 'S-2', etc = sector PR
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
final dangerFilterProvider = StateProvider<String>((ref) => 'all');
final heatmapOnProvider = StateProvider<bool>((ref) => false);
final dateRangeProvider = StateProvider<String>((ref) => '30');
final mapCenterCoordsProvider = StateProvider<(double, double)>((ref) => (-37.0896, -73.1584));

final activeZoneCategoriesProvider = StateProvider<Set<String>>((ref) => {
  'Seguridad', 'Infraestructura', 'Vialidad', 'Comercio', 'Comunitario',
});

// Elementos creados por el usuario en esta sesión (en memoria)
final userElementsProvider = StateProvider<List<ElementoMapa>>((ref) => []);

// Todos los elementos: seed + usuario
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
    if (!activeLayers.contains(e.layerKey)) {
      return false;
    }

    // Si es una zona dibujada (está en userPolygons), filtrar por categoría de zona
    final isUserPolygon = userPolygons.any((p) => p.zona.id == e.id);
    if (isUserPolygon) {
      final cat = _mapTipoToCat(e.tipo);
      if (!activeZoneCats.contains(cat)) {
        return false;
      }
    }

    if (dateLimit != null) {
      final d = DateTime.tryParse(e.fecha);
      if (d != null && d.isBefore(dateLimit)) {
        return false;
      }
    }
    if (e.tipo == 'zona_peligro' &&
        dangerFilter != 'all' &&
        e.tipoPeligro != dangerFilter) {
      return false;
    }
    return true;
  }).toList();
});

// Polígonos dibujados por el usuario con su zona asociada
final userPolygonsProvider =
    StateProvider<List<({List<LatLng> points, ElementoMapa zona})>>((ref) => []);

// Formas personalizadas del Plan Regulador (sobreescriben las por defecto)
final planReguladorEditsProvider = StateProvider<Map<String, List<LatLng>>>((ref) => {});

final planReguladorPolygonsProvider = Provider<List<Polygon>>((ref) {
  final edits = ref.watch(planReguladorEditsProvider);
  return PlanReguladorLayer.buildPolygons(edits: edits);
});

final planReguladorMarkersProvider = Provider<List<Marker>>((ref) {
  final edits = ref.watch(planReguladorEditsProvider);
  return PlanReguladorLayer.buildCentroidMarkers(
    edits: edits,
    onTap: (sector, context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanReguladorSheet(sector: sector),
    ),
  );
});

final filteredUserPolygonsProvider = Provider<List<({List<LatLng> points, ElementoMapa zona})>>((ref) {
  final activeLayers = ref.watch(activeLayersProvider);
  final activeZoneCats = ref.watch(activeZoneCategoriesProvider);
  final userPolygons = ref.watch(userPolygonsProvider);
  final dateLimit = ref.watch(dateLimitProvider);

  return userPolygons.where((p) {
    // Filtrar por capa (la mayoría son 'zona_peligro' o 'infraestructura')
    if (!activeLayers.contains(p.zona.layerKey)) return false;

    // Filtrar por categoría de zona
    final cat = _mapTipoToCat(p.zona.tipo);
    if (!activeZoneCats.contains(cat)) return false;

    // Filtrar por fecha
    if (dateLimit != null) {
      final d = DateTime.tryParse(p.zona.fecha);
      if (d != null && d.isBefore(dateLimit)) return false;
    }

    return true;
  }).toList();
});

String _mapTipoToCat(String tipo) {
  if (tipo == 'zona_peligro' || tipo.startsWith('reporte_')) return 'Seguridad';
  if (tipo == 'infraestructura' || tipo == 'luminaria' || tipo == 'camara') return 'Infraestructura';
  if (tipo == 'reporte_accidente' || tipo == 'vialidad') return 'Vialidad';
  if (tipo == 'patente') return 'Comercio';
  if (tipo == 'sede_comunitaria' || tipo == 'centro_acopio') return 'Comunitario';
  return 'Seguridad';
}

// Observaciones de funcionarios por sector del Plan Regulador
final planReguladorObsProvider = StateProvider<Map<String, String>>((ref) => {});

// Atribución de observaciones del Plan Regulador
final planReguladorAttrProvider = StateProvider<Map<String, String>>((ref) => {});

// MapController compartido para acceso desde el FAB de GPS
final mapControllerProvider = Provider<MapController>((ref) => MapController());

// ── MapScreen ─────────────────────────────────────────────────────────────────

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final activeLayers = ref.watch(activeLayersProvider);
    final isDrawing = ref.watch(isDrawingModeProvider);
    final drawingPoints = ref.watch(drawingPointsProvider);
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final heatmapOn = ref.watch(heatmapOnProvider);
    final reportesAsync = ref.watch(reportesStreamProvider);
    final allElems = ref.watch(allElementsProvider);
    final elementos = ref.watch(filteredElementsProvider);
    final filteredUserPolygons = ref.watch(filteredUserPolygonsProvider);
    final mapCtrl = ref.watch(mapControllerProvider);

    final userElements = ref.watch(userElementsProvider);
    final List<Marker> markers = elementos.map((e) {
      final isPending = userElements.any((u) => u.id == e.id);
      return CustomMarkers.buildMarker(
        point: e.latLng,
        icon: CustomMarkers.getIconForTipo(e.tipo),
        color: CustomMarkers.getColorForTipo(e.tipo),
        isPending: isPending,
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ElementDetailSheet(elemento: e, isPending: isPending),
        ),
      );
    }).toList();

    // Reportes guardados localmente
    if (activeLayers.contains('reporte')) {
      reportesAsync.whenData((reportes) {
        for (final r in reportes) {
          markers.add(CustomMarkers.buildMarker(
            point: LatLng(r.lat, r.lng),
            icon: CustomMarkers.getIconForTipo('reporte_${r.tipo}'),
            color: CustomMarkers.getColorForTipo('reporte_${r.tipo}'),
            isPending: true,
          ));
        }
      });
    }

    if (isDrawing) {
      for (final p in drawingPoints) {
        markers.add(Marker(
          point: p, width: 12, height: 12,
          child: Container(decoration: const BoxDecoration(color: AppTheme.blue800, shape: BoxShape.circle)),
        ));
      }
    }

    return Row(
      children: [
        // ── Sidebar ──────────────────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: collapsed ? 0 : 280,
          child: collapsed
              ? const SizedBox.shrink()
              : _MapSidebar(activeLayers: activeLayers, ref: ref),
        ),

        // ── Mapa ─────────────────────────────────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              RepaintBoundary(
                key: _mapKey,
                child: FlutterMap(
                  mapController: mapCtrl,
                  options: MapOptions(
                    initialCenter: AppConstants.lotaCenter,
                    initialZoom: AppConstants.lotaDefaultZoom,
                    maxZoom: 19.0,
                    onTap: (_, point) {
                      if (isDrawing) {
                        ref.read(drawingPointsProvider.notifier).update((s) => [...s, point]);
                      }
                    },
                    onPositionChanged: (camera, hasGesture) {
                      final c = camera.center;
                      if (c != null) {
                        ref.read(mapCenterCoordsProvider.notifier).state =
                            (c.latitude, c.longitude);
                      }
                    },
                  ),
                  children: [
                    Consumer(
                      builder: (ctx, r, _) {
                        final base = r.watch(mapaBaseProvider);
                        final url = mapaBaseUrls[base]!;
                        final subs = mapaBaseSubdomains[base]!;
                        return TileLayer(
                          urlTemplate: url,
                          subdomains: subs,
                          userAgentPackageName: 'cl.lota.sigespu',
                        );
                      },
                    ),
                    if (heatmapOn)
                      HeatMapLayer(
                        heatMapDataSource: _buildHeatMapDataSource(allElems),
                        heatMapOptions: HeatMapOptions(
                          radius: 35,
                          blurFactor: 0.25,
                          gradient: {
                            0.2: Colors.orange,
                            0.4: Colors.orange,
                            0.6: Colors.orange,
                            0.8: Colors.deepOrange,
                            1.0: Colors.deepOrange,
                          },
                        ),
                      ),
                    if (activeLayers.contains('plan_regulador')) ...[
                      PolygonLayer(polygons: ref.watch(planReguladorPolygonsProvider)),
                      MarkerLayer(
                        markers: ref.watch(planReguladorMarkersProvider),
                      ),
                    ],
                    if (isDrawing && drawingPoints.length >= 3)
                      PolygonLayer(polygons: [
                        Polygon(
                          points: drawingPoints,
                          color: AppTheme.redDanger.withValues(alpha: 0.25),
                          borderColor: AppTheme.redDanger,
                          borderStrokeWidth: 2,
                        ),
                      ]),
                    if (filteredUserPolygons.isNotEmpty)
                      PolygonLayer(
                        polygons: filteredUserPolygons.map((p) {
                          final color = CustomMarkers.getColorForTipo(p.zona.tipo);
                          return Polygon(
                            points: p.points,
                            color: color.withValues(alpha: 0.2),
                            borderColor: color,
                            borderStrokeWidth: 2,
                          );
                        }).toList(),
                      ),
                    MarkerLayer(markers: markers),
                    // Sismos layer
                    Consumer(
                      builder: (ctx, r, _) {
                        final visible = r.watch(sismosVisibleProvider);
                        if (!visible) return const SizedBox.shrink();
                        return r.watch(sismosProvider).when(
                          data: (sismos) => MarkerLayer(
                            markers: sismos.map((s) {
                              final color = s.magnitude >= 6.0
                                  ? const Color(0xFFE53935)
                                  : s.magnitude >= 5.0
                                      ? const Color(0xFFFF8F00)
                                      : s.magnitude >= 4.0
                                          ? const Color(0xFFFDD835)
                                          : const Color(0xFF43A047);
                              final radius = (s.magnitude * 4).clamp(8.0, 30.0);
                              return Marker(
                                point: LatLng(s.latitude, s.longitude),
                                width: radius * 2,
                                height: radius * 2,
                                child: GestureDetector(
                                  onTap: () => _showSismoPopup(ctx, s),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.85),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        s.magnitude.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
                    // Custom layers
                    Consumer(
                      builder: (ctx, r, _) {
                        final capasAsync = r.watch(capasPersonalizadasProvider);
                        final customVisible = r.watch(customLayersVisibleProvider);
                        return capasAsync.when(
                          data: (capas) {
                            final visibleCapas =
                                capas.where((c) => customVisible[c.id] ?? c.visible).toList();
                            if (visibleCapas.isEmpty) return const SizedBox.shrink();
                            return Stack(
                              children: visibleCapas.map((capa) {
                                final colorVal =
                                    int.tryParse(capa.color.replaceFirst('#', '0xFF')) ??
                                        0xFFFF5722;
                                final color = Color(colorVal);
                                return r.watch(capaGeoJsonProvider(capa.id)).when(
                                  data: (fc) {
                                    if (fc == null) return const SizedBox.shrink();
                                    final features =
                                        (fc['features'] as List).cast<Map<String, dynamic>>();
                                    final markers = <Marker>[];
                                    final polygons = <Polygon>[];
                                    final polylines = <Polyline>[];
                                    for (final f in features) {
                                      final geom = f['geometry'] as Map<String, dynamic>?;
                                      if (geom == null) continue;
                                      final type = geom['type'] as String;
                                      final coords = geom['coordinates'];
                                      if (type == 'Point') {
                                        final c = coords as List;
                                        markers.add(Marker(
                                          point: LatLng(
                                              (c[1] as num).toDouble(),
                                              (c[0] as num).toDouble()),
                                          width: 20,
                                          height: 20,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border:
                                                  Border.all(color: Colors.white, width: 1.5),
                                            ),
                                          ),
                                        ));
                                      } else if (type == 'Polygon') {
                                        final rings = (coords as List).cast<List>();
                                        final pts = rings.first
                                            .cast<List>()
                                            .map((c) => LatLng(
                                                (c[1] as num).toDouble(),
                                                (c[0] as num).toDouble()))
                                            .toList();
                                        polygons.add(Polygon(
                                          points: pts,
                                          color: color.withValues(alpha: capa.opacidad),
                                          borderColor: color,
                                          borderStrokeWidth: 2,
                                        ));
                                      } else if (type == 'LineString') {
                                        final pts = (coords as List)
                                            .cast<List>()
                                            .map((c) => LatLng(
                                                (c[1] as num).toDouble(),
                                                (c[0] as num).toDouble()))
                                            .toList();
                                        polylines.add(Polyline(
                                          points: pts,
                                          color: color,
                                          strokeWidth: 2.5,
                                        ));
                                      }
                                    }
                                    return Stack(children: [
                                      if (polygons.isNotEmpty) PolygonLayer(polygons: polygons),
                                      if (polylines.isNotEmpty)
                                        PolylineLayer(polylines: polylines),
                                      if (markers.isNotEmpty) MarkerLayer(markers: markers),
                                    ]);
                                  },
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Toggle sidebar btn
              Positioned(
                top: 16,
                left: collapsed ? 16 : 244,
                child: _SidebarToggleBtn(
                  collapsed: collapsed,
                  onTap: () => ref.read(sidebarCollapsedProvider.notifier).state = !collapsed,
                ),
              ),

              // Draw hint panel
              if (isDrawing)
                Positioned(
                  top: 16,
                  left: 0, right: 0,
                  child: Center(child: _DrawHintPanel(
                    pointCount: drawingPoints.length,
                    onFinish: drawingPoints.length >= 3
                        ? () => _showGuardarZona(context, ref, drawingPoints)
                        : null,
                    onCancel: () {
                      ref.read(isDrawingModeProvider.notifier).state = false;
                      ref.read(drawingPointsProvider.notifier).state = [];
                    },
                  )),
                ),

              // Info panel top-left
              if (!isDrawing)
                Positioned(
                  top: 16,
                  left: collapsed ? 64 : 16,
                  child: Consumer(
                    builder: (ctx, r, _) {
                      final coords = r.watch(mapCenterCoordsProvider);
                      final count = r.watch(filteredElementsProvider).length;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.stone200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Text(
                            'Lota, Biobío',
                            style: TextStyle(fontSize: 12, color: AppTheme.stone600),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${coords.$1.toStringAsFixed(4)}, ${coords.$2.toStringAsFixed(4)} Grados',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.stone900,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.orange100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count elementos',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.orange700,
                              ),
                            ),
                          ),
                        ]),
                      );
                    },
                  ),
                ),

              // Legend bottom-left
              const Positioned(
                bottom: 24,
                left: 16,
                child: _LegendPanel(),
              ),

              // BarraVisor — bottom center
              const Positioned(
                bottom: 96,
                left: 0,
                right: 0,
                child: Center(child: BarraVisor()),
              ),

              // Visor panels
              Consumer(
                builder: (ctx, r, _) {
                  final panel = r.watch(activePanelProvider);
                  if (panel == VisorPanel.none) return const SizedBox.shrink();
                  return Positioned(
                    bottom: 150,
                    left: 16,
                    child: switch (panel) {
                      VisorPanel.capas => PanelCapas(
                          isDirector: false, // TODO(sprint-3): read from auth provider
                          onSubirCapa: () => showModalBottomSheet(
                            context: ctx,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const SubirCapaScreen(),
                          ),
                        ),
                      VisorPanel.mapaBase => const PanelMapaBase(),
                      VisorPanel.leyenda => const PanelLeyenda(),
                      VisorPanel.imprimir => PanelImprimir(mapKey: _mapKey),
                      VisorPanel.none => const SizedBox.shrink(),
                    },
                  );
                },
              ),

              // FABs bottom-right
              Positioned(
                bottom: 24, right: 16,
                child: _FabGroup(
                  isDrawing: isDrawing,
                  canFinish: drawingPoints.length >= 3,
                  ref: ref,
                  context: context,
                  drawingPoints: drawingPoints,
                  mapController: mapCtrl,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  HeatMapDataSource _buildHeatMapDataSource(List<ElementoMapa> allElems) {
    final dataList = allElems
        .where((e) => e.tipo.startsWith('reporte_') || e.tipo == 'zona_peligro')
        .map((e) => WeightedLatLng(
              e.latLng,
              e.tipo == 'zona_peligro'
                  ? ((e.nivel ?? 3) * 0.2).clamp(0.2, 1.0)
                  : 0.7,
            ))
        .toList();
    return _ListHeatMapDataSource(dataList);
  }

  void _showSismoPopup(BuildContext ctx, SismoDto s) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E2327),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sismo M${s.magnitude.toStringAsFixed(1)} ${s.magType ?? ''}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (s.place != null)
              Text(s.place!,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              'Fecha: ${s.timeUtc.toLocal()}',
              style:
                  const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            if (s.depthKm != null)
              Text(
                'Profundidad: ${s.depthKm!.toStringAsFixed(1)} km',
                style: const TextStyle(
                    color: Colors.white54, fontSize: 12),
              ),
            if (s.tsunami == 1)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Row(children: [
                  Icon(Icons.warning, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Posible alerta de tsunami',
                    style: TextStyle(
                        color: Colors.amber, fontSize: 12),
                  ),
                ]),
              ),
            if (s.urlUsgs != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Ver en USGS: ${s.urlUsgs}',
                  style: const TextStyle(
                      color: Color(0xFF00897B), fontSize: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void _showGuardarZona(BuildContext context, WidgetRef ref, List<LatLng> points) {
  final target = ref.read(drawingTargetProvider);

  if (target != null) {
    // Es una edición del Plan Regulador
    ref.read(planReguladorEditsProvider.notifier).update((m) => {...m, target: points});
    ref.read(isDrawingModeProvider.notifier).state = false;
    ref.read(drawingPointsProvider.notifier).state = [];
    ref.read(drawingTargetProvider.notifier).state = null;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contorno del Plan Regulador actualizado'),
        backgroundColor: AppTheme.amberWarning,
      ),
    );
    return;
  }

  // Es una nueva zona
  ref.read(isDrawingModeProvider.notifier).state = false;
  ref.read(drawingPointsProvider.notifier).state = [];
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ZonaFormSheet(points: points),
  );
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _MapSidebar extends StatelessWidget {
  final Set<String> activeLayers;
  final WidgetRef ref;
  const _MapSidebar({required this.activeLayers, required this.ref});

  static const _layers = [
    ('centro_acopio', 'Centros de acopio', Color(0xFFEA580C)),
    ('sede_comunitaria', 'Sedes comunitarias', Color(0xFF16A34A)),
    ('zona_peligro', 'Zonas de peligro', Color(0xFFB91C1C)),
    ('reporte', 'Reportes de seguridad', Color(0xFFEF4444)),
    ('patente', 'Patentes comerciales', Color(0xFFD97706)),
    ('infraestructura', 'Infraestructura', Color(0xFF1E3A8A)),
    ('plan_regulador', 'Plan Regulador', Color(0xFFCA8A04)),
  ];

  static const _dangerFilters = [
    ('all', 'Todos'),
    ('drogas', 'Tráfico drogas'),
    ('robos', 'Robos'),
    ('vivienda_ilegal', 'Vivienda ilegal'),
    ('vandalismo', 'Vandalismo'),
    ('riña', 'Riñas'),
  ];

  @override
  Widget build(BuildContext context) {
    final dangerFilter = ref.watch(dangerFilterProvider);
    final heatmapOn = ref.watch(heatmapOnProvider);
    final dateRange = ref.watch(dateRangeProvider);
    final activeCount = activeLayers.length;

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppTheme.stone200)),
      ),
      child: Column(
        children: [
          // Branding Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
            decoration: const BoxDecoration(
              color: AppTheme.stone900,
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SIGESPU LOTA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'I. MUNICIPALIDAD DE LOTA',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppTheme.stone500,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Sección capas
                _SectionHeader('Capas del sistema', '$activeCount/${_layers.length}'),
                ...(() {
                  final counts = <String, int>{};
                  for (final e in kElementosSeed) {
                    counts[e.layerKey] = (counts[e.layerKey] ?? 0) + 1;
                  }
                  return _layers.map((l) {
                    final (key, name, color) = l;
                    final isActive = activeLayers.contains(key);
                    final count = counts[key] ?? 0;
                    return _LayerToggle(
                      layerKey: key, name: name, color: color,
                      isActive: isActive, count: count,
                      onTap: () {
                        final next = Set<String>.from(activeLayers);
                        isActive ? next.remove(key) : next.add(key);
                        ref.read(activeLayersProvider.notifier).state = next;
                      },
                    );
                  });
                })(),

                const Divider(height: 1, color: AppTheme.stone100),

                // Tipos de peligro
                const _SectionHeader('Tipos de peligro', null),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Wrap(
                    spacing: 6, runSpacing: 6,
                    children: _dangerFilters.map((f) {
                      final (key, label) = f;
                      final isActive = dangerFilter == key;
                      return GestureDetector(
                        onTap: () => ref.read(dangerFilterProvider.notifier).state = key,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? AppTheme.orange600 : AppTheme.stone100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(label, style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500,
                            color: isActive ? Colors.white : AppTheme.stone600,
                          )),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const Divider(height: 1, color: AppTheme.stone100),

                // Filtros de Zonas dibujadas
                const _SectionHeader('Categorías de Zonas', null),
                ...(() {
                  final activeCats = ref.watch(activeZoneCategoriesProvider);
                  const cats = [
                    ('Seguridad', AppTheme.redDanger),
                    ('Infraestructura', AppTheme.blue800),
                    ('Vialidad', AppTheme.orange500),
                    ('Comercio', AppTheme.amberWarning),
                    ('Comunitario', AppTheme.greenSuccess),
                  ];
                  return cats.map((c) {
                    final (name, color) = c;
                    final isActive = activeCats.contains(name);
                    return _ZoneCatToggle(
                      name: name,
                      color: color,
                      isActive: isActive,
                      onTap: () {
                        final next = Set<String>.from(activeCats);
                        isActive ? next.remove(name) : next.add(name);
                        ref.read(activeZoneCategoriesProvider.notifier).state = next;
                      },
                    );
                  });
                })(),

                const Divider(height: 1, color: AppTheme.stone100),

                // Mapa de calor
                const _SectionHeader('Mapa de calor', null),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: GestureDetector(
                    onTap: () => ref.read(heatmapOnProvider.notifier).state = !heatmapOn,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.stone50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.stone200),
                      ),
                      child: Row(children: [
                        const Icon(Icons.blur_on, size: 16, color: AppTheme.orange600),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Densidad de reportes', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppTheme.stone800))),
                        Switch(
                          value: heatmapOn,
                          onChanged: (v) => ref.read(heatmapOnProvider.notifier).state = v,
                          activeTrackColor: AppTheme.orange600,
                          activeThumbColor: Colors.white,
                          inactiveTrackColor: AppTheme.stone300,
                          inactiveThumbColor: Colors.white,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ]),
                    ),
                  ),
                ),

                const Divider(height: 1, color: AppTheme.stone100),

                // Rango de fechas
                const _SectionHeader('Rango de fechas', null),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: dateRange,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.stone200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.stone200)),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 11.5, color: AppTheme.stone800),
                    items: const [
                      DropdownMenuItem(value: '7', child: Text('Últimos 7 días')),
                      DropdownMenuItem(value: '30', child: Text('Últimos 30 días')),
                      DropdownMenuItem(value: '90', child: Text('Últimos 90 días')),
                      DropdownMenuItem(value: '365', child: Text('Último año')),
                      DropdownMenuItem(value: 'all', child: Text('Histórico completo')),
                    ],
                    onChanged: (v) { if (v != null) ref.read(dateRangeProvider.notifier).state = v; },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares del mapa ───────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  const _SectionHeader(this.title, this.trailing);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.stone500, letterSpacing: 0.8)),
        if (trailing != null) ...[
          const Spacer(),
          Text(trailing!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.stone400)),
        ],
      ]),
    );
  }
}

class _LayerToggle extends StatelessWidget {
  final String layerKey;
  final String name;
  final Color color;
  final bool isActive;
  final int count;
  final VoidCallback onTap;

  const _LayerToggle({
    required this.layerKey, required this.name, required this.color,
    required this.isActive, required this.count, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isActive ? AppTheme.orange50 : Colors.transparent,
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Icon(Icons.circle, size: 10, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppTheme.stone800))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFED7AA) : AppTheme.stone100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: isActive ? AppTheme.orange700 : AppTheme.stone500)),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28, height: 16,
            child: Switch(
              value: isActive, onChanged: (_) => onTap(),
              activeTrackColor: AppTheme.orange600,
              activeThumbColor: Colors.white,
              inactiveTrackColor: AppTheme.stone300,
              inactiveThumbColor: Colors.white,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ]),
      ),
    );
  }
}

class _SidebarToggleBtn extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onTap;
  const _SidebarToggleBtn({required this.collapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.stone200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2)],
        ),
        child: Icon(
          collapsed ? Icons.chevron_right : Icons.chevron_left,
          size: 20, color: AppTheme.stone700,
        ),
      ),
    );
  }
}

class _DrawHintPanel extends StatelessWidget {
  final int pointCount;
  final VoidCallback? onFinish;
  final VoidCallback onCancel;
  const _DrawHintPanel({required this.pointCount, this.onFinish, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.orange600,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.edit, size: 16, color: Colors.white),
        const SizedBox(width: 10),
        const Text('Toca el mapa para agregar vértices', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(10)),
          child: Text('$pointCount pts', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onFinish,
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.orange700,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Cerrar figura', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: const BorderSide(color: Colors.white38),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Cancelar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}


class _LegendPanel extends StatelessWidget {
  const _LegendPanel();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Color(0xFF1E3A8A), 'Infraestructura'),
      (Color(0xFF16A34A), 'Sede comunitaria'),
      (Color(0xFFEA580C), 'Centro de acopio'),
      (Color(0xFFB91C1C), 'Zona de peligro'),
      (Color(0xFFD97706), 'Patente comercial'),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('LEYENDA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.stone500, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          ...items.map((item) {
            final (color, label) = item;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 11.5, color: AppTheme.stone700)),
              ]),
            );
          }),
        ],
      ),
    );
  }
}

class _ZoneCatToggle extends StatelessWidget {
  final String name;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _ZoneCatToggle({
    required this.name,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(children: [
          Checkbox(
            value: isActive,
            onChanged: (_) => onTap(),
            activeColor: AppTheme.orange600,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 12, color: AppTheme.stone700)),
        ]),
      ),
    );
  }
}

// ── HeatMap Data Source implementation ────────────────────────────────────────

class _ListHeatMapDataSource extends HeatMapDataSource {
  final List<WeightedLatLng> data;
  _ListHeatMapDataSource(this.data);

  @override
  List<WeightedLatLng> getData(LatLngBounds bounds, double zoom) => data;
}

// ── FAB Group ─────────────────────────────────────────────────────────────────

class _FabGroup extends StatelessWidget {
  final bool isDrawing;
  final bool canFinish;
  final WidgetRef ref;
  final BuildContext context;
  final List<LatLng> drawingPoints;
  final MapController mapController;

  const _FabGroup({
    required this.isDrawing, required this.canFinish,
    required this.ref, required this.context, required this.drawingPoints,
    required this.mapController,
  });

  @override
  Widget build(BuildContext buildContext) {
    if (isDrawing) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        FloatingActionButton.extended(
          heroTag: 'cancel_draw',
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.stone900,
          onPressed: () {
            ref.read(isDrawingModeProvider.notifier).state = false;
            ref.read(drawingPointsProvider.notifier).state = [];
          },
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Cancelar'),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          heroTag: 'save_draw',
          backgroundColor: canFinish ? AppTheme.redDanger : AppTheme.stone400,
          foregroundColor: Colors.white,
          onPressed: canFinish
              ? () => _showGuardarZona(context, ref, drawingPoints)
              : null,
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Guardar Zona'),
        ),
      ]);
    }

    return Column(mainAxisSize: MainAxisSize.min, children: [
      FloatingActionButton(
        heroTag: 'draw',
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.stone700,
        onPressed: () {
          ref.read(isDrawingModeProvider.notifier).state = true;
          ref.read(drawingPointsProvider.notifier).state = [];
        },
        child: const Icon(Icons.edit_outlined),
      ),
      const SizedBox(height: 10),
      FloatingActionButton(
        heroTag: 'gps',
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.stone700,
        onPressed: () => _centerOnGps(context, mapController),
        child: const Icon(Icons.my_location),
      ),
      const SizedBox(height: 10),
      FloatingActionButton(
        heroTag: 'add',
        backgroundColor: AppTheme.orange600,
        foregroundColor: Colors.white,
        onPressed: () => _showAddModal(context, ref),
        child: const Icon(Icons.add, size: 28),
      ),
    ]);
  }

  void _showAddModal(BuildContext ctx, WidgetRef r) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddElementModal(),
    );
  }

  Future<void> _centerOnGps(BuildContext ctx, MapController mapCtrl) async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Permiso de ubicación denegado permanentemente'),
            ),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 6));
      mapCtrl.move(LatLng(pos.latitude, pos.longitude), 17.0);
    } catch (_) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener la ubicación')),
        );
      }
    }
  }
}
