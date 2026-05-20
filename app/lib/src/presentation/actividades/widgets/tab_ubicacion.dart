import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared/shared.dart';

import '../actividades_provider.dart';

const _lotaCenter = LatLng(-37.0896, -73.1584);

class TabUbicacion extends ConsumerStatefulWidget {
  final ActividadMunicipal actividad;

  const TabUbicacion({super.key, required this.actividad});

  @override
  ConsumerState<TabUbicacion> createState() => _TabUbicacionState();
}

class _TabUbicacionState extends ConsumerState<TabUbicacion> {
  late final MapController _mapCtrl;
  bool _loadingGps = false;
  bool _markingMode = false;

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  // Usa la actividad más reciente del provider para reflejar actualizaciones GPS
  ActividadMunicipal get _actividad {
    final all = ref.read(actividadesProvider);
    return all.firstWhere((e) => e.id == widget.actividad.id,
        orElse: () => widget.actividad);
  }

  LatLng get _center {
    final a = _actividad;
    if (a.lat != null && a.lng != null) return LatLng(a.lat!, a.lng!);
    return _lotaCenter;
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (!_markingMode) return;
    setState(() => _markingMode = false);
    final updated = _actividad.copyWith(
      lat: point.latitude,
      lng: point.longitude,
      actualizadoEn: DateTime.now(),
    );
    ref.read(actividadesProvider.notifier).update(updated);
    _mapCtrl.move(point, 17);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ubicacion marcada: ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _usarUbicacionActual() async {
    setState(() => _loadingGps = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permiso de ubicación denegado por el navegador'),
            ),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final latLng = LatLng(pos.latitude, pos.longitude);
      // Guardar coordenadas en la actividad
      final updated = _actividad.copyWith(
        lat: pos.latitude,
        lng: pos.longitude,
        actualizadoEn: DateTime.now(),
      );
      ref.read(actividadesProvider.notifier).update(updated);
      _mapCtrl.move(latLng, 16);
    } on LocationServiceDisabledException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servicio de ubicación desactivado. Actívalo en la configuración del navegador.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la ubicación. Verifica los permisos del navegador.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa cambios en el provider para reflejar actualizaciones GPS en tiempo real
    final all = ref.watch(actividadesProvider);
    final a = all.firstWhere((e) => e.id == widget.actividad.id,
        orElse: () => widget.actividad);
    final hasCoords = a.lat != null && a.lng != null;
    final sinUbicacion =
        !hasCoords || a.direccion == null || a.direccion == 'Sin ubicación';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KV row: dirección + coords + sector (responsive)
          LayoutBuilder(builder: (context, constraints) {
            final narrow = constraints.maxWidth < 560;

            final direccion = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('Dirección / lugar'),
                const SizedBox(height: 6),
                _KV(
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 13,
                          color: sinUbicacion
                              ? const Color(0xFFA8A29E)
                              : const Color(0xFF78716C)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          a.direccion ?? 'Sin ubicación',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: sinUbicacion
                                ? const Color(0xFFA8A29E)
                                : const Color(0xFF1C1917),
                            fontStyle: sinUbicacion
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final coordenadas = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('Coordenadas'),
                const SizedBox(height: 6),
                _KV(
                  Text(
                    hasCoords
                        ? '${a.lat!.toStringAsFixed(5)}, ${a.lng!.toStringAsFixed(5)}'
                        : 'Sin coordenadas',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11.5,
                      color: hasCoords
                          ? const Color(0xFF1C1917)
                          : const Color(0xFFA8A29E),
                    ),
                  ),
                ),
              ],
            );

            final sector = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('Sector'),
                const SizedBox(height: 6),
                _KV(
                  Text(
                    a.sector ?? '—',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12.5,
                      color: const Color(0xFF1C1917),
                    ),
                  ),
                ),
              ],
            );

            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  direccion,
                  const SizedBox(height: 10),
                  coordenadas,
                  const SizedBox(height: 10),
                  sector,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: direccion),
                const SizedBox(width: 12),
                Expanded(flex: 4, child: coordenadas),
                const SizedBox(width: 12),
                SizedBox(width: 80, child: sector),
              ],
            );
          }),
          const SizedBox(height: 14),

          // Action row (Wrap para no desbordar en narrow)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _loadingGps ? null : _usarUbicacionActual,
                icon: _loadingGps
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.my_location, size: 13),
                label: const Text(
                  'Usar ubicación actual',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => _markingMode = !_markingMode),
                icon: const Icon(Icons.push_pin_outlined, size: 13),
                label: Text(
                  _markingMode ? 'Cancelar marcado' : 'Marcar en mapa',
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _markingMode
                      ? const Color(0xFFEA580C)
                      : const Color(0xFF44403C),
                  backgroundColor:
                      _markingMode ? const Color(0xFFFFF7ED) : null,
                  side: BorderSide(
                    color: _markingMode
                        ? const Color(0xFFEA580C)
                        : const Color(0xFFE7E5E4),
                    width: 1.5,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              _GpsConfidenceBadge(hasCoords: hasCoords),
            ],
          ),
          const SizedBox(height: 14),

          // Mini map
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE7E5E4)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: hasCoords ? 16.0 : 13.0,
                      onTap: _onMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        maxZoom: 19,
                        userAgentPackageName: 'cl.lota.sigespu',
                        retinaMode: RetinaMode.isHighDensity(context),
                        tileProvider: CancellableNetworkTileProvider(),
                      ),
                      if (hasCoords)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(a.lat!, a.lng!),
                              width: 32,
                              height: 40,
                              child: const _ActivityPin(),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // FAB controls (top-right)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Column(
                      children: [
                        _MapFab(
                          icon: Icons.add,
                          onTap: () => _mapCtrl.move(
                            _mapCtrl.camera.center,
                            _mapCtrl.camera.zoom + 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _MapFab(
                          icon: Icons.remove,
                          onTap: () => _mapCtrl.move(
                            _mapCtrl.camera.center,
                            _mapCtrl.camera.zoom - 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _MapFab(
                          icon: Icons.my_location_outlined,
                          onTap: () => _mapCtrl.move(
                              _center, hasCoords ? 16.0 : 13.0),
                        ),
                      ],
                    ),
                  ),

                  // Scale bar (bottom-left)
                  const Positioned(
                    left: 10,
                    bottom: 10,
                    child: _ScaleBar(),
                  ),

                  // Marking mode banner (IgnorePointer so taps reach the map)
                  if (_markingMode)
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 50,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA580C),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.touch_app,
                                  size: 14, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Toca el mapa para marcar la ubicacion',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // No coords overlay
                  if (!hasCoords && !_markingMode)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.04),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off_outlined,
                                size: 32, color: Color(0xFFA8A29E)),
                            SizedBox(height: 8),
                            Text(
                              'Sin coordenadas asignadas',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF78716C)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Usa "Ubicación actual" o "Marcar en mapa"',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFFA8A29E)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF78716C),
        letterSpacing: 0.06,
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final Widget child;
  const _KV(this.child);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF9),
        border: Border.all(color: const Color(0xFFE7E5E4)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: child,
    );
  }
}

class _GpsConfidenceBadge extends StatelessWidget {
  final bool hasCoords;
  const _GpsConfidenceBadge({required this.hasCoords});

  @override
  Widget build(BuildContext context) {
    if (hasCoords) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.gps_fixed, size: 11, color: Color(0xFF15803D)),
            const SizedBox(width: 4),
            Text(
              'GPS confirmado',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: const Color(0xFF15803D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gps_not_fixed, size: 11, color: Color(0xFFA8A29E)),
          const SizedBox(width: 4),
          Text(
            'Sin GPS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: const Color(0xFFA8A29E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityPin extends StatelessWidget {
  const _ActivityPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFEA580C),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.flag_outlined, size: 16, color: Colors.white),
        ),
        CustomPaint(size: const Size(8, 6), painter: _PinTailPainter()),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFEA580C));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapFab({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: 15, color: const Color(0xFF44403C)),
      ),
    );
  }
}

class _ScaleBar extends StatelessWidget {
  const _ScaleBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE7E5E4)),
      ),
      child: Text(
        '200 m',
        style:
            GoogleFonts.jetBrainsMono(fontSize: 9.5, color: const Color(0xFF44403C)),
      ),
    );
  }
}
