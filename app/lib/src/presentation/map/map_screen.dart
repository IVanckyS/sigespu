import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared/shared.dart';
import '../../config/constants.dart';
import '../../config/map_config.dart';
import '../../config/theme.dart';
import '../../data/providers.dart';
import '../../data/seed_data.dart';
import 'layers/plan_regulador_layer.dart';
import 'layers/custom_markers.dart';
import 'widgets/add_element_modal.dart';
import 'widgets/element_detail_sheet.dart';
import 'widgets/zona_form_sheet.dart';
import 'widgets/plan_regulador_sheet.dart';
import 'widgets/panel_capas.dart';
import 'widgets/panel_mapa_base.dart';
import 'widgets/panel_leyenda.dart';
import 'widgets/panel_imprimir.dart';
import 'screens/subir_capa_screen.dart';
import '../actividades/actividades_provider.dart';
import '../actividades/widgets/actividad_bottom_sheet.dart';
import 'providers/map_providers.dart';
import 'providers/visor_provider.dart';
import 'providers/amenazas_provider.dart';
import '../auth/auth_provider.dart';

// planReguladorMarkersProvider queda aquí: crea UI (PlanReguladorSheet) → evita dep circular
final planReguladorMarkersProvider = Provider<List<Marker>>((ref) {
  final edits = ref.watch(planReguladorEditsProvider);
  final isDrawing = ref.watch(isDrawingModeProvider);
  final target = ref.watch(drawingTargetProvider);
  return PlanReguladorLayer.buildCentroidMarkers(
    edits: edits,
    hiddenCode: isDrawing ? target : null,
    onTap: (sector, context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanReguladorSheet(sector: sector),
    ),
  );
});

// ── MapScreen ─────────────────────────────────────────────────────────────────

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapKey = GlobalKey();
  Timer? _coordDebounce;

  @override
  void dispose() {
    _coordDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeLayers = ref.watch(activeLayersProvider);
    final isDrawing = ref.watch(isDrawingModeProvider);
    final drawingPoints = ref.watch(drawingPointsProvider);
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final mapCtrl = ref.watch(mapControllerProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return Scaffold(
          backgroundColor: Colors.transparent,
          drawer: isMobile ? const Drawer(child: _MapSidebar(closeOnAction: true)) : null,
          body: Row(
      children: [
        // ── Sidebar (solo desktop) ────────────────────────────────────────
        if (!isMobile) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: collapsed ? 0 : 280,
            child: collapsed ? const SizedBox.shrink() : const _MapSidebar(),
          ),
          _SidebarToggleBtn(
            collapsed: collapsed,
            onTap: () => ref.read(sidebarCollapsedProvider.notifier).state = !collapsed,
          ),
        ],

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
                        return;
                      }
                      // Hit-test: ¿el tap cayó dentro de una zona dibujada?
                      // Se busca el polígono más pequeño que contiene el punto
                      // (mejora UX cuando hay zonas anidadas).
                      // ref.read es correcto aquí: solo necesitamos el valor actual
                      // en el momento del tap, no suscribirnos a cambios.
                      final polygons = ref.read(filteredUserPolygonsProvider);
                      final candidates = polygons
                          .where((p) => _pointInPolygon(point, p.points))
                          .toList()
                        ..sort((a, b) =>
                            _polygonBboxArea(a.points).compareTo(_polygonBboxArea(b.points)));
                      if (candidates.isNotEmpty) {
                        final hit = candidates.first;
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ElementDetailSheet(
                            elemento: hit.zona,
                            isPending: ref
                                .read(pendingElementIdsProvider)
                                .contains(hit.zona.id),
                          ),
                        );
                      }
                    },
                    onPositionChanged: (camera, hasGesture) {
                      final c = camera.center;
                      // Debounce coordinate display updates to ~4fps during
                      // gestures — avoids rebuilding the info panel 60×/s.
                      if (hasGesture) {
                        _coordDebounce?.cancel();
                        _coordDebounce = Timer(
                          const Duration(milliseconds: 120),
                          () => ref.read(mapCenterCoordsProvider.notifier).state =
                              (c.latitude, c.longitude),
                        );
                      } else {
                        ref.read(mapCenterCoordsProvider.notifier).state =
                            (c.latitude, c.longitude);
                      }

                      // Actualizar límites para filtrado espacial (lazy loading)
                      final bounds = camera.visibleBounds;
                      final next = <double>[
                        bounds.west,
                        bounds.south,
                        bounds.east,
                        bounds.north
                      ];

                      // Solo actualizamos si el cambio es significativo (ej. > 0.005 grados)
                      final current = ref.read(mapBoundsProvider);
                      bool significant = current == null;
                      if (current != null) {
                        for (int i = 0; i < 4; i++) {
                          if ((current[i] - next[i]).abs() > 0.005) {
                            significant = true;
                            break;
                          }
                        }
                      }

                      if (significant) {
                        ref.read(mapBoundsProvider.notifier).state = next;
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
                          retinaMode: RetinaMode.isHighDensity(ctx),
                          tileProvider: CancellableNetworkTileProvider(),
                        );
                      },
                    ),
                    const _HeatmapMapLayer(),
                    if (activeLayers.contains('plan_regulador')) ...[
                      PolygonLayer(polygons: ref.watch(planReguladorPolygonsProvider)),
                      MarkerLayer(
                        markers: ref.watch(planReguladorMarkersProvider),
                      ),
                    ],
                    if (activeLayers.contains('zona_tsunami')) ...[
                      PolygonLayer(polygons: ref.watch(tsunamiZonaPolygonsProvider)),
                      PolylineLayer(polylines: ref.watch(tsunamiLimitePolylinesProvider)),
                      PolylineLayer(polylines: ref.watch(tsunamiViasPolylinesProvider)),
                      MarkerLayer(markers: ref.watch(tsunamiPuntosMarkersProvider)),
                    ],
                    if (activeLayers.contains('zona_incendio')) ...[
                      PolygonLayer(polygons: ref.watch(incendioPolygonsProvider)),
                      PolylineLayer(polylines: ref.watch(incendioHatchPolylinesProvider)),
                    ],
                    if (isDrawing && drawingPoints.length >= 2)
                      PolylineLayer(polylines: [
                        Polyline(
                          points: [...drawingPoints, drawingPoints.first],
                          color: AppTheme.orange600,
                          strokeWidth: 2.5,
                        ),
                      ]),
                    if (isDrawing && drawingPoints.length >= 3)
                      PolygonLayer(polygons: [
                        Polygon(
                          points: drawingPoints,
                          color: AppTheme.orange600.withValues(alpha: 0.15),
                          borderColor: Colors.transparent,
                          borderStrokeWidth: 0,
                          isFilled: true,
                        ),
                      ]),
                    const _UserPolygonsLayer(),
                    const _ElementMarkersLayer(),
                    const _ActividadesMarkersLayer(),
                    const _ReportesMarkersLayer(),
                    const _UserLocationLayer(),
                    if (isDrawing && drawingPoints.isNotEmpty)
                      MarkerLayer(
                        markers: [
                          for (var i = 0; i < drawingPoints.length; i++)
                            Marker(
                              point: drawingPoints[i],
                              width: 22,
                              height: 22,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.orange600,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.orange700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    // Sismos layer
                    const _SismosMapLayer(),
                    // Custom layers
                    const _CustomLayersMapLayer(),
                  ],
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
                    onUndo: () {
                      final current = ref.read(drawingPointsProvider);
                      if (current.isEmpty) return;
                      ref.read(drawingPointsProvider.notifier).state =
                          current.sublist(0, current.length - 1);
                    },
                    onCancel: () {
                      ref.read(isDrawingModeProvider.notifier).state = false;
                      ref.read(drawingPointsProvider.notifier).state = [];
                      ref.read(drawingTargetProvider.notifier).state = null;
                    },
                  )),
                ),

              // Info panel top-left
              if (!isDrawing)
                Positioned(
                  top: isMobile ? 12 : 16,
                  left: isMobile ? 58 : 16,
                  child: RepaintBoundary(child: Consumer(
                    builder: (ctx, r, _) {
                      final coords = r.watch(mapCenterCoordsProvider);
                      final count = r.watch(filteredElementsProvider).length;
                      if (isMobile) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.stone200),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(
                              '${coords.$1.toStringAsFixed(3)}, ${coords.$2.toStringAsFixed(3)}',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppTheme.stone800),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(color: AppTheme.orange100, borderRadius: BorderRadius.circular(8)),
                              child: Text('$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.orange700)),
                            ),
                          ]),
                        );
                      }
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
                  )),  // Consumer + RepaintBoundary
                ),

              // Visor panels
              Consumer(
                builder: (ctx, r, _) {
                  final panel = r.watch(activePanelProvider);
                  if (panel == VisorPanel.none) return const SizedBox.shrink();
                  final panelWidget = switch (panel) {
                    VisorPanel.capas => PanelCapas(
                        isDirector: r.watch(authProvider).user?['nivel_acceso'] == 'director',
                        onSubirCapa: () => showModalBottomSheet(
                          context: ctx,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const SubirCapaScreen(),
                        ),
                      ),
                    VisorPanel.mapaBase  => const PanelMapaBase(),
                    VisorPanel.leyenda   => const PanelLeyenda(),
                    VisorPanel.imprimir  => PanelImprimir(mapKey: _mapKey),
                    VisorPanel.none      => const SizedBox.shrink(),
                  };
                  return Positioned(
                    bottom: isMobile ? 80 : 150,
                    left: 16,
                    child: _PanelWithClose(
                      onClose: () => r.read(activePanelProvider.notifier).state = VisorPanel.none,
                      child: panelWidget,
                    ),
                  );
                },
              ),

              // Mobile drawer trigger
              Builder(
                builder: (ctx) {
                  final w = MediaQuery.of(ctx).size.width;
                  if (w >= 768) return const SizedBox.shrink();
                  return Positioned(
                    top: 12,
                    left: 12,
                    child: Material(
                      color: const Color(0xFF1E2327),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.layers_outlined, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
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
          ),  // end body Row
        );    // end Scaffold
      },      // end LayoutBuilder builder
    );        // end LayoutBuilder
  }

}

// ── Panel close wrapper ───────────────────────────────────────────────────────

class _PanelWithClose extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;
  const _PanelWithClose({required this.child, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -10,
          right: -10,
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2327),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Capas extraídas (const widgets) ──────────────────────────────────────────
// Estos widgets se construyen como `const` desde el árbol del mapa. Flutter
// short-circuit-ea el rebuild cuando el parent se reconstruye: solo se
// reconstruyen cuando cambian sus propios providers.

class _HeatmapMapLayer extends ConsumerWidget {
  const _HeatmapMapLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(heatmapOnProvider)) return const SizedBox.shrink();
    final dataSource = ref.watch(heatmapDataSourceProvider);
    return HeatMapLayer(
      heatMapDataSource: dataSource,
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
    );
  }
}

/// Polígonos dibujados por el usuario (zonas personalizadas).
/// Extraído como ConsumerWidget para que cambios en [filteredUserPolygonsProvider]
/// (por filtro de fecha, categoría, etc.) no hagan rebuild de [_MapScreenState].
class _UserPolygonsLayer extends ConsumerWidget {
  const _UserPolygonsLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final polygons = ref.watch(filteredUserPolygonsProvider);
    if (polygons.isEmpty) return const SizedBox.shrink();
    return PolygonLayer(
      polygons: polygons.map((p) {
        final color = CustomMarkers.getColorForTipo(p.zona.tipo);
        return Polygon(
          points: p.points,
          color: color.withValues(alpha: 0.2),
          borderColor: color,
          borderStrokeWidth: 2,
          isFilled: true,
        );
      }).toList(),
    );
  }
}

class _ElementMarkersLayer extends ConsumerWidget {
  const _ElementMarkersLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elementos = ref.watch(filteredElementsProvider);
    final pendingIds = ref.watch(pendingElementIdsProvider);

    final markers = <Marker>[
      for (final e in elementos)
        CustomMarkers.buildMarker(
          point: e.latLng,
          icon: CustomMarkers.getIconForTipo(e.tipo),
          color: CustomMarkers.getColorForTipo(e.tipo),
          isPending: pendingIds.contains(e.id),
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ElementDetailSheet(
              elemento: e,
              isPending: pendingIds.contains(e.id),
            ),
          ),
        ),
    ];
    return MarkerLayer(markers: markers);
  }
}

class _ActividadesMarkersLayer extends ConsumerWidget {
  const _ActividadesMarkersLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLayers = ref.watch(activeLayersProvider);
    if (!activeLayers.contains('actividad_municipal')) {
      return const SizedBox.shrink();
    }
    final elems = ref.watch(actividadesLayerElementsProvider);
    final actividades = ref.watch(actividadesProvider);
    final actividadById = {for (final a in actividades) a.id: a};
    return MarkerLayer(
      markers: [
        for (final e in elems)
          CustomMarkers.buildMarker(
            point: e.latLng,
            icon: CustomMarkers.getIconForTipo(e.tipo),
            color: CustomMarkers.getColorForTipo(e.tipo),
            isPending: false,
            onTap: () {
              final actividad = actividadById[e.id];
              if (actividad == null) return;
              _openActividadDetail(context, actividad);
            },
          ),
      ],
    );
  }
}

void _openActividadDetail(BuildContext context, ActividadMunicipal a) {
  final isMobile = MediaQuery.sizeOf(context).width < 768;
  if (isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.sizeOf(ctx).height * 0.92,
        child: ActividadBottomSheet(
          actividad: a,
          onClose: () => Navigator.pop(ctx),
        ),
      ),
    );
  } else {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960, maxHeight: 640),
          child: ActividadBottomSheet(
            actividad: a,
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }
}

/// Marker dedicado a la posición GPS del propio usuario.
/// Diseño estilo Google Maps: halo translúcido + punto sólido con borde
/// blanco. Distinto del resto de markers (que son círculos con icono).
/// Solo se renderiza cuando [userLocationProvider] tiene un valor — es decir,
/// después de que el usuario tocó el botón "Mi ubicación" al menos una vez.
class _UserLocationLayer extends ConsumerWidget {
  const _UserLocationLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(userLocationProvider);
    if (loc == null) return const SizedBox.shrink();
    return MarkerLayer(
      markers: [
        Marker(
          point: loc,
          width: 36,
          height: 36,
          child: const IgnorePointer(child: _UserLocationDot()),
        ),
      ],
    );
  }
}

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  static const _blue = Color(0xFF2563EB); // azul Google Maps-like

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Halo translúcido exterior
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
        ),
        // Punto sólido interior con borde blanco
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportesMarkersLayer extends ConsumerWidget {
  const _ReportesMarkersLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLayers = ref.watch(activeLayersProvider);
    if (!activeLayers.any((k) => k.startsWith('reporte_'))) {
      return const SizedBox.shrink();
    }
    final reportesAsync = ref.watch(reportesStreamProvider);
    return reportesAsync.maybeWhen(
      data: (reportes) {
        final markers = <Marker>[];
        for (final r in reportes) {
          final key = 'reporte_${r.tipo}';
          if (!activeLayers.contains(key)) continue;
          markers.add(CustomMarkers.buildMarker(
            point: LatLng(r.lat, r.lng),
            icon: CustomMarkers.getIconForTipo(key),
            color: CustomMarkers.getColorForTipo(key),
            isPending: true,
          ));
        }
        return MarkerLayer(markers: markers);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _CustomLayersMapLayer extends ConsumerWidget {
  const _CustomLayersMapLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capasAsync = ref.watch(capasPersonalizadasProvider);
    final customVisible = ref.watch(customLayersVisibleProvider);
    return capasAsync.maybeWhen(
      data: (capas) {
        final visibleIds = [
          for (final c in capas)
            if (customVisible[c.id] ?? false) c.id,
        ];
        if (visibleIds.isEmpty) return const SizedBox.shrink();
        return Stack(
          children: [
            for (final id in visibleIds)
              _CapaGeometriesLayer(key: ValueKey('capa_$id'), capaId: id),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _CapaGeometriesLayer extends ConsumerWidget {
  final String capaId;
  const _CapaGeometriesLayer({super.key, required this.capaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geoms = ref.watch(capaParsedGeomsProvider(capaId));
    if (geoms == null) return const SizedBox.shrink();

    final polygons = <Polygon>[
      for (final p in geoms.polygons)
        Polygon(
          points: [for (final pt in p.ring) LatLng(pt.lat, pt.lng)],
          color: Color(p.color).withValues(alpha: p.opacidad),
          borderColor: Color(p.color),
          borderStrokeWidth: 1.5,
          isFilled: true,
        ),
    ];
    final polylines = <Polyline>[
      for (final l in geoms.lines)
        Polyline(
          points: [for (final pt in l.line) LatLng(pt.lat, pt.lng)],
          color: Color(l.color),
          strokeWidth: 2.5,
        ),
    ];
    final markers = <Marker>[
      for (final p in geoms.points)
        Marker(
          point: LatLng(p.lat, p.lng),
          width: 20,
          height: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Color(p.color),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
    ];

    return Stack(children: [
      if (polygons.isNotEmpty) PolygonLayer(polygons: polygons),
      if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
      if (markers.isNotEmpty) MarkerLayer(markers: markers),
    ]);
  }
}

class _SismosMapLayer extends ConsumerWidget {
  const _SismosMapLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(sismosVisibleProvider)) return const SizedBox.shrink();
    return ref.watch(sismosProvider).when(
          data: (sismos) => MarkerLayer(
            markers: [
              for (final s in sismos)
                Marker(
                  point: LatLng(s.latitude, s.longitude),
                  width: ((s.magnitude * 4).clamp(8.0, 30.0)) * 2,
                  height: ((s.magnitude * 4).clamp(8.0, 30.0)) * 2,
                  child: _SismoMarker(sismo: s),
                ),
            ],
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
  }
}

class _SismoMarker extends StatelessWidget {
  final SismoDto sismo;
  const _SismoMarker({required this.sismo});

  @override
  Widget build(BuildContext context) {
    final s = sismo;
    final color = s.magnitude >= 6.0
        ? const Color(0xFFE53935)
        : s.magnitude >= 5.0
            ? const Color(0xFFFF8F00)
            : s.magnitude >= 4.0
                ? const Color(0xFFFDD835)
                : const Color(0xFF43A047);
    return GestureDetector(
      onTap: () => _showSismoPopup(context, s),
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
    );
  }
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
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            'Fecha: ${s.timeUtc.toLocal()}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (s.depthKm != null)
            Text(
              'Profundidad: ${s.depthKm!.toStringAsFixed(1)} km',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          if (s.tsunami == 1)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Row(children: [
                Icon(Icons.warning, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  'Posible alerta de tsunami',
                  style: TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ]),
            ),
          if (s.urlUsgs != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Ver en USGS: ${s.urlUsgs}',
                style: const TextStyle(color: Color(0xFF00897B), fontSize: 11),
              ),
            ),
        ],
      ),
    ),
  );
}

void _showGuardarZona(BuildContext context, WidgetRef ref, List<LatLng> points) {
  final target = ref.read(drawingTargetProvider);

  if (target != null) {
    // Es una edición del Plan Regulador → persiste en SharedPreferences
    ref.read(planReguladorEditsProvider.notifier).setSector(target, points);
    ref.read(isDrawingModeProvider.notifier).state = false;
    ref.read(drawingPointsProvider.notifier).state = [];
    ref.read(drawingTargetProvider.notifier).state = null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contorno de $target actualizado y guardado'),
        backgroundColor: AppTheme.greenSuccess,
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

class _MapSidebar extends ConsumerStatefulWidget {
  final bool closeOnAction;
  const _MapSidebar({this.closeOnAction = false});

  @override
  ConsumerState<_MapSidebar> createState() => _MapSidebarState();
}

class _MapSidebarState extends ConsumerState<_MapSidebar> {
  final _expanded = <String, bool>{
    'seguridad': true,
    'infra': true,
    'incidentes': false,
    'cobertura': false,
    'amenazas': false,
    'actividades': true,
  };
  bool _zonasExpanded = false;

  static const _dangerFilters = MapLayerConfig.dangerFilters;

  static const _groups = <(String, String, List<String>)>[
    ('seguridad', 'Seguridad pública',
        ['zona_peligro', 'reporte_robo', 'reporte_vandalismo', 'reporte_accidente']),
    ('infra', 'Infraestructura',
        ['centro_acopio', 'sede_comunitaria', 'infraestructura']),
    ('incidentes', 'Incidentes urbanos',
        ['arbol_caido', 'poste_caido', 'sector_sin_luz', 'cable_colgando',
         'semaforo_dañado', 'socavon', 'fuga_agua', 'microbasural']),
    ('cobertura', 'Cobertura y fiscalización',
        ['patente', 'luminaria', 'camara_cctv']),
    ('amenazas', 'Amenazas y datos base',
        ['plan_regulador', 'zona_tsunami', 'zona_incendio']),
  ];

  void _toggleLayer(String tipo) {
    final current = ref.read(activeLayersProvider);
    final next = Set<String>.from(current);
    current.contains(tipo) ? next.remove(tipo) : next.add(tipo);
    ref.read(activeLayersProvider.notifier).state = next;
  }

  static Color _colorFor(String tipo) => MapLayerConfig.layers
      .firstWhere((l) => l.$1 == tipo,
          orElse: () => (tipo, tipo, AppTheme.stone400))
      .$3;

  static String _labelFor(String tipo) => MapLayerConfig.layers
      .firstWhere((l) => l.$1 == tipo,
          orElse: () => (tipo, tipo, AppTheme.stone400))
      .$2;

  @override
  Widget build(BuildContext context) {
    final activeLayers = ref.watch(activeLayersProvider);
    final counts = ref.watch(layerCountsProvider);
    final actividadesElems = ref.watch(actividadesLayerElementsProvider);
    final allActividades = ref.watch(actividadesProvider);
    final dangerFilter = ref.watch(dangerFilterProvider);
    final heatmapOn = ref.watch(heatmapOnProvider);
    final dateRange = ref.watch(dateRangeProvider);
    final polygons = ref.watch(userPolygonsProvider);
    final activeCategories = ref.watch(activeZonaCategoriesProvider);
    final sismosVisible = ref.watch(sismosVisibleProvider);
    final activePanel = ref.watch(activePanelProvider);
    final activeCount = activeLayers.length;
    const totalLayers = 22;

    final totalAct = allActividades.length;
    final completadas = allActividades
        .where((a) => a.estado == EstadoActividad.completado)
        .length;
    final pct = totalAct > 0 ? (completadas / totalAct * 100).round() : 0;
    final sectorMap = <String, int>{};
    for (final a in allActividades) {
      if (a.sector != null) {
        sectorMap[a.sector!] = (sectorMap[a.sector!] ?? 0) + 1;
      }
    }
    final topSectores = (sectorMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .toList();
    final maxS = topSectores.isEmpty ? 1 : topSectores.first.value;

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppTheme.stone200)),
      ),
      child: Column(children: [
        Expanded(
          child: ListView(padding: EdgeInsets.zero, children: [

            // ── COBERTURA · ACTIVIDADES ────────────────────────────────────
            if (totalAct > 0) ...[
              const _SectionHeader('Cobertura · Actividades', null),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Column(children: [
                  Row(children: [
                    _StatBadge(label: 'Total', value: '$totalAct',
                        color: AppTheme.orange600),
                    const SizedBox(width: 8),
                    _StatBadge(label: 'Completadas', value: '$pct%',
                        color: const Color(0xFF15803D)),
                  ]),
                  const SizedBox(height: 8),
                  ...topSectores.map((e) {
                    final pctBar = maxS > 0 ? e.value / maxS : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(children: [
                        SizedBox(
                          width: 80,
                          child: Text(e.key,
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.stone600),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: pctBar.clamp(0.0, 1.0),
                              backgroundColor: AppTheme.stone100,
                              valueColor: const AlwaysStoppedAnimation(
                                  AppTheme.orange600),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('${e.value}',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600,
                                color: AppTheme.orange700)),
                      ]),
                    );
                  }),
                ]),
              ),
              const Divider(height: 1, color: AppTheme.stone100),
            ],

            // ── CAPAS DEL SISTEMA ──────────────────────────────────────────
            _SectionHeader('Capas del sistema', '$activeCount/$totalLayers'),
            for (final (key, label, tipos) in _groups) ...[
              _AccordionHeader(
                label: label,
                expanded: _expanded[key] ?? false,
                activeCount:
                    tipos.where((t) => activeLayers.contains(t)).length +
                    (key == 'amenazas' && sismosVisible ? 1 : 0),
                total: tipos.length + (key == 'amenazas' ? 1 : 0),
                onTap: () => setState(
                    () => _expanded[key] = !(_expanded[key] ?? false)),
              ),
              if (_expanded[key] == true) ...[
                if (key == 'amenazas')
                  _LayerToggle(
                    layerKey: 'sismos',
                    name: 'Sismos recientes',
                    color: const Color(0xFFE53935),
                    isActive: sismosVisible,
                    count: 0,
                    onTap: () => ref
                        .read(sismosVisibleProvider.notifier)
                        .state = !sismosVisible,
                  ),
                for (final tipo in tipos)
                  _LayerToggle(
                    layerKey: tipo,
                    name: _labelFor(tipo),
                    color: _colorFor(tipo),
                    isActive: activeLayers.contains(tipo),
                    count: counts[tipo] ?? 0,
                    onTap: () => _toggleLayer(tipo),
                  ),
              ],
            ],
            // Actividades como grupo propio
            _AccordionHeader(
              label: 'Actividades municipales',
              expanded: _expanded['actividades'] ?? true,
              activeCount: activeLayers.contains('actividad_municipal') ? 1 : 0,
              total: 1,
              onTap: () => setState(() =>
                  _expanded['actividades'] =
                      !(_expanded['actividades'] ?? true)),
            ),
            if (_expanded['actividades'] == true)
              _LayerToggle(
                layerKey: 'actividad_municipal',
                name: 'Actividades',
                color: const Color(0xFF7C3AED),
                isActive: activeLayers.contains('actividad_municipal'),
                count: actividadesElems.length,
                onTap: () => _toggleLayer('actividad_municipal'),
              ),

            const Divider(height: 1, color: AppTheme.stone100),

            // ── ZONAS DIBUJADAS ────────────────────────────────────────────
            _SectionHeader('Zonas dibujadas', '${polygons.length}'),
            _LayerToggle(
              layerKey: 'zona_custom',
              name: 'Mostrar zonas dibujadas',
              color: const Color(0xFF7C3AED),
              isActive: activeLayers.contains('zona_custom'),
              count: polygons.length,
              onTap: () => _toggleLayer('zona_custom'),
            ),
            _ZonaTipoDropdown(
              expanded: _zonasExpanded,
              activeCategories: activeCategories,
              polygons: polygons,
              onToggleExpanded: () =>
                  setState(() => _zonasExpanded = !_zonasExpanded),
              onToggleTipo: (key) {
                final next = Set<String>.from(activeCategories);
                next.contains(key) ? next.remove(key) : next.add(key);
                ref.read(activeZonaCategoriesProvider.notifier).state = next;
              },
              onClear: () => ref
                  .read(activeZonaCategoriesProvider.notifier)
                  .state = {},
            ),

            const Divider(height: 1, color: AppTheme.stone100),

            // ── TIPOS DE PELIGRO ───────────────────────────────────────────
            const _SectionHeader('Tipos de peligro', null),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Wrap(
                spacing: 6, runSpacing: 6,
                children: _dangerFilters.map((f) {
                  final (key, label) = f;
                  final isActive = dangerFilter == key;
                  return GestureDetector(
                    onTap: () =>
                        ref.read(dangerFilterProvider.notifier).state = key,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.orange600
                            : AppTheme.stone100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(label,
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w500,
                              color: isActive
                                  ? Colors.white
                                  : AppTheme.stone600)),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Divider(height: 1, color: AppTheme.stone100),

            // ── MAPA DE CALOR ──────────────────────────────────────────────
            const _SectionHeader('Mapa de calor', null),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: GestureDetector(
                onTap: () =>
                    ref.read(heatmapOnProvider.notifier).state = !heatmapOn,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.stone50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.stone200),
                  ),
                  child: Row(children: [
                    const Icon(Icons.blur_on, size: 16, color: AppTheme.orange600),
                    const SizedBox(width: 8),
                    const Expanded(
                        child: Text('Densidad de reportes',
                            style: TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w500,
                                color: AppTheme.stone800))),
                    Switch(
                      value: heatmapOn,
                      onChanged: (v) =>
                          ref.read(heatmapOnProvider.notifier).state = v,
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

            // ── RANGO DE FECHAS ────────────────────────────────────────────
            const _SectionHeader('Rango de fechas', null),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: dateRange,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide:
                          const BorderSide(color: AppTheme.stone200)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide:
                          const BorderSide(color: AppTheme.stone200)),
                  isDense: true,
                ),
                style: const TextStyle(
                    fontSize: 11.5, color: AppTheme.stone800),
                items: const [
                  DropdownMenuItem(value: '7', child: Text('Últimos 7 días')),
                  DropdownMenuItem(
                      value: '30', child: Text('Últimos 30 días')),
                  DropdownMenuItem(
                      value: '90', child: Text('Últimos 90 días')),
                  DropdownMenuItem(
                      value: '365', child: Text('Último año')),
                  DropdownMenuItem(
                      value: 'all', child: Text('Histórico completo')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref.read(dateRangeProvider.notifier).state = v;
                  }
                },
              ),
            ),

            const Divider(height: 1, color: AppTheme.stone100),

            // ── HERRAMIENTAS ───────────────────────────────────────────────
            const _SectionHeader('Herramientas', null),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(children: [
                _ToolTile(
                  icon: Icons.map_outlined,
                  label: 'Mapa base',
                  color: AppTheme.orange600,
                  isActive: activePanel == VisorPanel.mapaBase,
                  onTap: () {
                    if (widget.closeOnAction) Navigator.of(context).pop();
                    ref.read(activePanelProvider.notifier).state =
                        activePanel == VisorPanel.mapaBase
                            ? VisorPanel.none
                            : VisorPanel.mapaBase;
                  },
                ),
                const SizedBox(height: 6),
                _ToolTile(
                  icon: Icons.print_outlined,
                  label: 'Imprimir / Exportar',
                  color: const Color(0xFF1E88E5),
                  isActive: activePanel == VisorPanel.imprimir,
                  onTap: () {
                    if (widget.closeOnAction) Navigator.of(context).pop();
                    ref.read(activePanelProvider.notifier).state =
                        activePanel == VisorPanel.imprimir
                            ? VisorPanel.none
                            : VisorPanel.imprimir;
                  },
                ),
                const SizedBox(height: 6),
                _ToolTile(
                  icon: Icons.legend_toggle,
                  label: 'Leyenda de capas',
                  color: const Color(0xFF757575),
                  isActive: activePanel == VisorPanel.leyenda,
                  onTap: () {
                    if (widget.closeOnAction) Navigator.of(context).pop();
                    ref.read(activePanelProvider.notifier).state =
                        activePanel == VisorPanel.leyenda
                            ? VisorPanel.none
                            : VisorPanel.leyenda;
                  },
                ),
                const SizedBox(height: 6),
                _ToolTile(
                  icon: Icons.upload_file_outlined,
                  label: 'Capas personalizadas',
                  color: const Color(0xFF2E7D32),
                  isActive: activePanel == VisorPanel.capas,
                  onTap: () {
                    if (widget.closeOnAction) Navigator.of(context).pop();
                    ref.read(activePanelProvider.notifier).state =
                        activePanel == VisorPanel.capas
                            ? VisorPanel.none
                            : VisorPanel.capas;
                  },
                ),
              ]),
            ),
          ]),
        ),
      ]),
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

class _AccordionHeader extends StatelessWidget {
  final String label;
  final bool expanded;
  final int activeCount;
  final int total;
  final VoidCallback onTap;

  const _AccordionHeader({
    required this.label, required this.expanded,
    required this.activeCount, required this.total, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasActive = activeCount > 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(children: [
          Icon(
            expanded
                ? Icons.keyboard_arrow_down_rounded
                : Icons.keyboard_arrow_right_rounded,
            size: 15, color: AppTheme.stone400,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: hasActive ? AppTheme.stone800 : AppTheme.stone600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: hasActive
                  ? const Color(0xFFFED7AA)
                  : AppTheme.stone100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hasActive ? '$activeCount/$total' : '0/$total',
              style: TextStyle(
                  fontSize: 9.5,
                  fontWeight:
                      hasActive ? FontWeight.w700 : FontWeight.w400,
                  color: hasActive
                      ? AppTheme.orange700
                      : AppTheme.stone400),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBadge(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 9.5, color: AppTheme.stone500)),
        ]),
      ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isActive ? AppTheme.orange50 : Colors.transparent,
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(CustomMarkers.getIconForTipo(layerKey),
                size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w500,
                    color: isActive ? AppTheme.stone900 : AppTheme.stone700)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFED7AA) : AppTheme.stone100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: TextStyle(
                    fontSize: 10.5, fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppTheme.orange700
                        : AppTheme.stone500)),
          ),
          const SizedBox(width: 6),
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

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolTile({
    required this.icon, required this.label, required this.color,
    required this.isActive, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : AppTheme.stone50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? color.withValues(alpha: 0.3) : AppTheme.stone200),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: isActive ? color : AppTheme.stone500),
          const SizedBox(width: 10),
          Expanded(child: Text(label,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500,
                  color: isActive ? color : AppTheme.stone700))),
          if (isActive)
            Container(width: 6, height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
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
      child: Tooltip(
        message: collapsed ? 'Abrir panel de capas' : 'Cerrar panel de capas',
        child: Container(
          width: 20,
          height: double.infinity,
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              right: BorderSide(color: AppTheme.stone200),
              left: BorderSide(color: AppTheme.stone200),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              collapsed ? Icons.chevron_right : Icons.chevron_left,
              size: 16,
              color: AppTheme.stone500,
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawHintPanel extends StatelessWidget {
  final int pointCount;
  final VoidCallback? onFinish;
  final VoidCallback? onUndo;
  final VoidCallback onCancel;
  const _DrawHintPanel({
    required this.pointCount,
    this.onFinish,
    this.onUndo,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.orange600,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.edit, size: 16, color: Colors.white),
        const SizedBox(width: 8),
        const Text('Toca el mapa para agregar vértices',
            style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(10)),
          child: Text('$pointCount pts',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: pointCount > 0 ? onUndo : null,
          tooltip: 'Deshacer último vértice',
          icon: const Icon(Icons.undo, size: 16),
          color: Colors.white,
          disabledColor: Colors.white38,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
        const SizedBox(width: 2),
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
            ref.read(drawingTargetProvider.notifier).state = null;
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
        onPressed: () => _centerOnGps(context, ref, mapController),
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

  Future<void> _centerOnGps(
      BuildContext ctx, WidgetRef ref, MapController mapCtrl) async {
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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 6));
      final latLng = LatLng(pos.latitude, pos.longitude);
      ref.read(userLocationProvider.notifier).state = latLng;
      mapCtrl.move(latLng, 17.0);
    } catch (_) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener la ubicación')),
        );
      }
    }
  }
}

// ── Hit-testing de polígonos ──────────────────────────────────────────────────

/// Ray casting clásico: cuenta intersecciones de un rayo horizontal desde
/// [point] con las aristas del polígono. Impar = dentro, par = fuera.
bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
  if (polygon.length < 3) return false;
  final x = point.longitude;
  final y = point.latitude;
  bool inside = false;
  for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final xi = polygon[i].longitude, yi = polygon[i].latitude;
    final xj = polygon[j].longitude, yj = polygon[j].latitude;
    final intersect = ((yi > y) != (yj > y)) &&
        (x < (xj - xi) * (y - yi) / ((yj - yi) == 0 ? 1e-12 : (yj - yi)) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

/// Área del bbox del polígono (grados²). Sirve para priorizar polígonos
/// pequeños cuando hay anidados.
double _polygonBboxArea(List<LatLng> polygon) {
  double minLat = double.infinity, maxLat = -double.infinity;
  double minLng = double.infinity, maxLng = -double.infinity;
  for (final p in polygon) {
    if (p.latitude < minLat) minLat = p.latitude;
    if (p.latitude > maxLat) maxLat = p.latitude;
    if (p.longitude < minLng) minLng = p.longitude;
    if (p.longitude > maxLng) maxLng = p.longitude;
  }
  return (maxLat - minLat) * (maxLng - minLng);
}

// ── Dropdown de tipo de peligro para zonas dibujadas ──────────────────────────

class _ZonaTipoDropdown extends StatelessWidget {
  final bool expanded;
  final Set<String> activeCategories;
  final List<({List<LatLng> points, ElementoMapa zona})> polygons;
  final VoidCallback onToggleExpanded;
  final void Function(String key) onToggleTipo;
  final VoidCallback onClear;

  const _ZonaTipoDropdown({
    required this.expanded,
    required this.activeCategories,
    required this.polygons,
    required this.onToggleExpanded,
    required this.onToggleTipo,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    const tipos = MapLayerConfig.tiposPeligro;
    final activeLabel = activeCategories.isEmpty
        ? 'Todos los tipos'
        : '${activeCategories.length} seleccionados';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: InkWell(
          onTap: onToggleExpanded,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppTheme.stone50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.stone200),
            ),
            child: Row(children: [
              const Icon(Icons.filter_alt_outlined,
                  size: 14, color: AppTheme.stone500),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Filtrar por tipo · $activeLabel',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: AppTheme.stone800),
                ),
              ),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                size: 18, color: AppTheme.stone500,
              ),
            ]),
          ),
        ),
      ),
      if (expanded) ...[
        for (final (key, label) in tipos)
          _ZonaTipoRow(
            label: label,
            count: polygons.where((p) => p.zona.tipoPeligro == key).length,
            selected: activeCategories.contains(key),
            onTap: () => onToggleTipo(key),
          ),
        if (activeCategories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 8),
            child: GestureDetector(
              onTap: onClear,
              child: const Text(
                'Limpiar filtro',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppTheme.orange700,
                    decoration: TextDecoration.underline),
              ),
            ),
          ),
      ],
    ]);
  }
}

class _ZonaTipoRow extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _ZonaTipoRow({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 6, 16, 6),
        child: Row(children: [
          Icon(
            selected ? Icons.check_box : Icons.check_box_outline_blank,
            size: 16,
            color: selected ? AppTheme.orange600 : AppTheme.stone400,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppTheme.stone900 : AppTheme.stone700,
              ),
            ),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.stone100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: AppTheme.stone600),
              ),
            ),
        ]),
      ),
    );
  }
}
