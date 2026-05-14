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
import '../actividades/actividades_provider.dart';
import 'providers/map_providers.dart';
import 'providers/visor_provider.dart';
import 'providers/amenazas_provider.dart';
import '../auth/auth_provider.dart';

// planReguladorMarkersProvider queda aquí: crea UI (PlanReguladorSheet) → evita dep circular
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
    final actividadesElems = activeLayers.contains('actividad_municipal')
        ? ref.watch(actividadesLayerElementsProvider)
        : <ElementoMapa>[];

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

    // Actividades municipales
    for (final e in actividadesElems) {
      markers.add(CustomMarkers.buildMarker(
        point: e.latLng,
        icon: CustomMarkers.getIconForTipo('actividad_municipal'),
        color: const Color(0xFF7C3AED),
        isPending: false,
      ));
    }

    // Reportes guardados localmente (filtrar por tipo específico activo)
    if (activeLayers.any((k) => k.startsWith('reporte_'))) {
      reportesAsync.whenData((reportes) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return Scaffold(
          backgroundColor: Colors.transparent,
          drawer: isMobile ? const Drawer(child: _MapSidebar()) : null,
          body: Row(
      children: [
        // ── Sidebar ──────────────────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: collapsed ? 0 : 280,
          child: collapsed ? const SizedBox.shrink() : const _MapSidebar(),
        ),

        // ── Botón toggle siempre visible en el borde ──────────────────────
        _SidebarToggleBtn(
          collapsed: collapsed,
          onTap: () => ref.read(sidebarCollapsedProvider.notifier).state = !collapsed,
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

                      // Actualizar límites para filtrado espacial (lazy loading)
                      final bounds = camera.bounds;
                      if (bounds != null) {
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
                          tileProvider: CancellableNetworkTileProvider(),
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
                    if (activeLayers.contains('zona_tsunami')) ...[
                      PolygonLayer(polygons: ref.watch(tsunamiZonaPolygonsProvider)),
                      PolylineLayer(polylines: ref.watch(tsunamiLimitePolylinesProvider)),
                      PolylineLayer(polylines: ref.watch(tsunamiViasPolylinesProvider)),
                      MarkerLayer(markers: ref.watch(tsunamiPuntosMarkersProvider)),
                    ],
                    if (activeLayers.contains('zona_incendio'))
                      PolygonLayer(polygons: ref.watch(incendioPolygonsProvider)),
                    if (isDrawing && drawingPoints.length >= 3)
                      PolygonLayer(polygons: [
                        Polygon(
                          points: drawingPoints,
                          color: AppTheme.redDanger.withValues(alpha: 0.25),
                          borderColor: AppTheme.redDanger,
                          borderStrokeWidth: 2,
                          isFilled: true,
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
                            isFilled: true,
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
                                capas.where((c) => customVisible[c.id] ?? false).toList();
                            if (visibleCapas.isEmpty) return const SizedBox.shrink();
                            return Stack(
                              children: visibleCapas.map((capa) {
                                final baseColorVal =
                                    int.tryParse(capa.color.replaceFirst('#', '0xFF')) ??
                                        0xFFFF5722;
                                final baseColor = Color(baseColorVal);
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
                                      final props = f['properties'] as Map<String, dynamic>? ?? {};
                                      
                                      // Determinar color de la feature (graduación)
                                      Color featureColor = baseColor;
                                      
                                      if (props.containsKey('kml_color')) {
                                        // KML: aabbggrr -> ARGB
                                        final kml = props['kml_color'] as String;
                                        if (kml.length == 8) {
                                          final a = int.parse(kml.substring(0, 2), radix: 16);
                                          final b = int.parse(kml.substring(2, 4), radix: 16);
                                          final g = int.parse(kml.substring(4, 6), radix: 16);
                                          final r = int.parse(kml.substring(6, 8), radix: 16);
                                          featureColor = Color.fromARGB(a, r, g, b);
                                        }
                                      } else {
                                        // Generar variación tonal basada en el nombre o ID si no hay color específico
                                        final seed = (f['id']?.toString().hashCode ?? 0) % 100;
                                        final hsl = HSLColor.fromColor(baseColor);
                                        // Variar luminosidad +/- 15%
                                        featureColor = hsl.withLightness((hsl.lightness + (seed - 50) / 330).clamp(0.1, 0.9)).toColor();
                                      }

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
                                              color: featureColor,
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
                                          color: featureColor.withValues(alpha: capa.opacidad),
                                          borderColor: featureColor,
                                          borderStrokeWidth: 1.5,
                                          isFilled: true,
                                        ));
                                      } else if (type == 'MultiPolygon') {
                                        for (final polyCoords in (coords as List)) {
                                          final rings = (polyCoords as List).cast<List>();
                                          final pts = rings.first
                                              .cast<List>()
                                              .map((c) => LatLng(
                                                  (c[1] as num).toDouble(),
                                                  (c[0] as num).toDouble()))
                                              .toList();
                                          polygons.add(Polygon(
                                            points: pts,
                                            color: featureColor.withValues(alpha: capa.opacidad),
                                            borderColor: featureColor,
                                            borderStrokeWidth: 1.5,
                                            isFilled: true,
                                          ));
                                        }
                                      } else if (type == 'LineString') {
                                        final pts = (coords as List)
                                            .cast<List>()
                                            .map((c) => LatLng(
                                                (c[1] as num).toDouble(),
                                                (c[0] as num).toDouble()))
                                            .toList();
                                        polylines.add(Polyline(
                                          points: pts,
                                          color: featureColor,
                                          strokeWidth: 2.5,
                                        ));
                                      } else if (type == 'MultiLineString') {
                                        for (final lineCoords in (coords as List)) {
                                          final pts = (lineCoords as List)
                                              .cast<List>()
                                              .map((c) => LatLng(
                                                  (c[1] as num).toDouble(),
                                                  (c[0] as num).toDouble()))
                                              .toList();
                                          polylines.add(Polyline(
                                            points: pts,
                                            color: featureColor,
                                            strokeWidth: 2.5,
                                          ));
                                        }
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
                  left: 16,
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
                          isDirector: r.watch(authProvider).user?['nivel_acceso'] == 'director',
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

class _MapSidebar extends ConsumerStatefulWidget {
  const _MapSidebar();

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
    final categories = ref.watch(customZonaCategoriesProvider);
    final activeCategories = ref.watch(activeZonaCategoriesProvider);
    final sismosVisible = ref.watch(sismosVisibleProvider);
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
        // ── Branding header ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF7ED),
            border: Border(
              bottom: BorderSide(color: Color(0xFFFED7AA)),
              left: BorderSide(color: AppTheme.orange600, width: 4),
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: AppTheme.orange600,
                    borderRadius: BorderRadius.circular(4)),
                child: const Text('SIGESPU',
                    style: TextStyle(
                        color: Colors.white, fontSize: 9,
                        fontWeight: FontWeight.w800, letterSpacing: 0.6)),
              ),
              const SizedBox(width: 8),
              const Text('Lota, Biobío',
                  style: TextStyle(
                      color: AppTheme.orange700, fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 5),
            const Text('Sistema de Información Geoespacial\nde Seguridad Pública',
                style: TextStyle(
                    color: AppTheme.stone700, fontSize: 10.5,
                    height: 1.4, fontWeight: FontWeight.w500)),
            const SizedBox(height: 3),
            const Text('Dirección de Seguridad Pública',
                style: TextStyle(color: AppTheme.stone500, fontSize: 9.5)),
          ]),
        ),

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
              name: 'Todas las zonas ✏',
              color: const Color(0xFF7C3AED),
              isActive: activeLayers.contains('zona_custom'),
              count: polygons.length,
              onTap: () => _toggleLayer('zona_custom'),
              trailing: polygons.isNotEmpty
                  ? GestureDetector(
                      onTap: () =>
                          setState(() => _zonasExpanded = !_zonasExpanded),
                      child: Icon(
                          _zonasExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 16, color: AppTheme.stone400),
                    )
                  : null,
            ),
            if (_zonasExpanded && categories.isNotEmpty)
              ...categories.map((cat) {
                final catCount =
                    polygons.where((p) => p.zona.tipo == cat).length;
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _LayerToggle(
                    layerKey: cat,
                    name: cat,
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.7),
                    isActive: activeCategories.contains(cat),
                    count: catCount,
                    onTap: () {
                      final next = Set<String>.from(activeCategories);
                      activeCategories.contains(cat)
                          ? next.remove(cat)
                          : next.add(cat);
                      ref
                          .read(activeZonaCategoriesProvider.notifier)
                          .state = next;
                    },
                  ),
                );
              }),

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
  final Widget? trailing;

  const _LayerToggle({
    required this.layerKey, required this.name, required this.color,
    required this.isActive, required this.count, required this.onTap,
    this.trailing,
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
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
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
