import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

List<LatLng> _ring(List coords) => coords
    .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
    .toList();

Future<Map<String, dynamic>> _loadGeojson(String assetPath) async {
  final raw = await rootBundle.loadString(assetPath);
  return jsonDecode(raw) as Map<String, dynamic>;
}

List<Map<String, dynamic>> _features(Map<String, dynamic> fc) =>
    (fc['features'] as List).cast<Map<String, dynamic>>();

List<Polygon> _toPolygons(Map<String, dynamic> fc, Color fill, Color border, double borderW) {
  final polygons = <Polygon>[];
  for (final f in _features(fc)) {
    final geom = f['geometry'] as Map<String, dynamic>?;
    if (geom == null) continue;
    final type = geom['type'] as String;
    final coords = geom['coordinates'];
    if (type == 'Polygon') {
      polygons.add(Polygon(
        points: _ring(coords[0] as List),
        color: fill,
        borderColor: border,
        borderStrokeWidth: borderW,
        isFilled: true,
      ));
    } else if (type == 'MultiPolygon') {
      for (final poly in (coords as List)) {
        polygons.add(Polygon(
          points: _ring(poly[0] as List),
          color: fill,
          borderColor: border,
          borderStrokeWidth: borderW,
          isFilled: true,
        ));
      }
    }
  }
  return polygons;
}

List<Polyline> _toPolylines(Map<String, dynamic> fc, Color color, double width) {
  final lines = <Polyline>[];
  for (final f in _features(fc)) {
    final geom = f['geometry'] as Map<String, dynamic>?;
    if (geom == null) continue;
    final type = geom['type'] as String;
    final coords = geom['coordinates'];
    if (type == 'LineString') {
      lines.add(Polyline(points: _ring(coords as List), color: color, strokeWidth: width));
    } else if (type == 'MultiLineString') {
      for (final seg in (coords as List)) {
        lines.add(Polyline(points: _ring(seg as List), color: color, strokeWidth: width));
      }
    }
  }
  return lines;
}

// ── Colores exactos SENAPRED ──────────────────────────────────────────────────
// Tsunami — Layer 3 zona: fill RGB(230,0,0) 50% opacidad (SENAPRED transparency=50), sin borde
const _tsunamiZonaFill   = Color.fromARGB(128, 230, 0, 0);
const _tsunamiZonaBorder = Colors.transparent;

// Tsunami — Layer 2 línea segura: RGB(112,168,0)
const _tsunamiLimiteColor = Color(0xFF70A800);

// Tsunami — Layer 1 vías: RGB(0,112,255)
const _tsunamiViasColor = Color(0xFF0070FF);

// Incendio — colores y clases exactas del renderer SENAPRED (classBreakInfos)
// Transparencia oficial: 70% → opacidad fill = 0.30
// gridcode=1 excluido del asset (Bajo cubre todo el territorio, sería ruido)
Color _incendioColor(int gridcode) {
  if (gridcode <= 2) return const Color(0xFFA0C29B); // Bajo  — RGB(160,194,155)
  if (gridcode <= 3) return const Color(0xFFFAFA64); // Medio — RGB(250,250,100)
  if (gridcode <= 4) return const Color(0xFFFA8D34); // Alto  — RGB(250,141,52)
  return const Color(0xFFE81014);                    // Muy alto — RGB(232,16,20)
}

// ── Providers de datos crudos ─────────────────────────────────────────────────

final tsunamiZonaProvider   = FutureProvider<Map<String, dynamic>>((ref) =>
    _loadGeojson('assets/amenazas/tsunami_zona_evacuacion.geojson'));

final tsunamiLimiteProvider  = FutureProvider<Map<String, dynamic>>((ref) =>
    _loadGeojson('assets/amenazas/tsunami_limite_evacuacion.geojson'));

final tsunamiViasProvider   = FutureProvider<Map<String, dynamic>>((ref) =>
    _loadGeojson('assets/amenazas/tsunami_vias_evacuacion.geojson'));

final tsunamiPuntosProvider = FutureProvider<Map<String, dynamic>>((ref) =>
    _loadGeojson('assets/amenazas/tsunami_puntos_encuentro.geojson'));

final incendioProvider      = FutureProvider<Map<String, dynamic>>((ref) =>
    _loadGeojson('assets/amenazas/incendio_forestal.geojson'));

// ── Providers de geometrías renderizables ─────────────────────────────────────

/// Zona inundable tsunami — rojo semitransparente, sin borde (Línea Segura lo provee)
final tsunamiZonaPolygonsProvider = Provider<List<Polygon>>((ref) =>
    ref.watch(tsunamiZonaProvider).whenOrNull(
      data: (fc) => _toPolygons(fc, _tsunamiZonaFill, _tsunamiZonaBorder, 0),
    ) ?? []);

/// Línea segura — verde RGB(112,168,0) (SENAPRED layer 2)
final tsunamiLimitePolylinesProvider = Provider<List<Polyline>>((ref) =>
    ref.watch(tsunamiLimiteProvider).whenOrNull(
      data: (fc) => _toPolylines(fc, _tsunamiLimiteColor, 2.0),
    ) ?? []);

/// Vías de evacuación — azul RGB(0,112,255) (SENAPRED layer 1)
final tsunamiViasPolylinesProvider = Provider<List<Polyline>>((ref) =>
    ref.watch(tsunamiViasProvider).whenOrNull(
      data: (fc) => _toPolylines(fc, _tsunamiViasColor, 2.5),
    ) ?? []);

/// Puntos de encuentro — marcadores (SENAPRED layer 0)
final tsunamiPuntosMarkersProvider = Provider<List<Marker>>((ref) {
  return ref.watch(tsunamiPuntosProvider).whenOrNull(
    data: (fc) {
      final markers = <Marker>[];
      for (final f in _features(fc)) {
        final geom = f['geometry'] as Map<String, dynamic>?;
        if (geom == null || geom['type'] != 'Point') continue;
        final c = geom['coordinates'] as List;
        final props = f['properties'] as Map<String, dynamic>? ?? {};
        final nombrePe = props['nombre_pe'] as String? ?? '';
        final sector = props['sector'] as String? ?? '';
        final nombre = nombrePe.isNotEmpty
            ? nombrePe
            : sector.isNotEmpty
                ? 'PE - $sector'
                : 'Punto de encuentro';
        markers.add(Marker(
          point: LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
          width: 30,
          height: 30,
          child: Tooltip(
            message: nombre,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0070FF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.people_alt, color: Colors.white, size: 15),
            ),
          ),
        ));
      }
      return markers;
    },
  ) ?? [];
});

/// Incendio forestal — polígonos por gridcode (class breaks SENAPRED)
final incendioPolygonsProvider = Provider<List<Polygon>>((ref) {
  return ref.watch(incendioProvider).whenOrNull(
    data: (fc) {
      final polygons = <Polygon>[];
      for (final f in _features(fc)) {
        final geom = f['geometry'] as Map<String, dynamic>?;
        if (geom == null) continue;
        final type = geom['type'] as String;
        final coords = geom['coordinates'];
        final props = f['properties'] as Map<String, dynamic>? ?? {};
        final gridcode = (props['gridcode'] as num?)?.toInt() ?? 1;
        final color = _incendioColor(gridcode);

        if (type == 'Polygon') {
          polygons.add(Polygon(
            points: _ring(coords[0] as List),
            color: color.withValues(alpha: 0.30),
            borderColor: Colors.transparent,
            borderStrokeWidth: 0,
            isFilled: true,
          ));
        } else if (type == 'MultiPolygon') {
          for (final poly in (coords as List)) {
            polygons.add(Polygon(
              points: _ring(poly[0] as List),
              color: color.withValues(alpha: 0.30),
              borderColor: Colors.transparent,
              borderStrokeWidth: 0,
              isFilled: true,
            ));
          }
        }
      }
      return polygons;
    },
  ) ?? [];
});
