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

/// Construye un Polygon a partir de rings GeoJSON: ring[0]=exterior, ring[1..]=hoyos.
Polygon _polyFromRings(List rings, Color fill, Color border, double borderW) {
  return Polygon(
    points: _ring(rings[0] as List),
    holePointsList: rings.length > 1
        ? [for (var i = 1; i < rings.length; i++) _ring(rings[i] as List)]
        : null,
    color: fill,
    borderColor: border,
    borderStrokeWidth: borderW,
    isFilled: true,
  );
}

List<Polygon> _toPolygons(Map<String, dynamic> fc, Color fill, Color border, double borderW) {
  final polygons = <Polygon>[];
  for (final f in _features(fc)) {
    final geom = f['geometry'] as Map<String, dynamic>?;
    if (geom == null) continue;
    final type = geom['type'] as String;
    final coords = geom['coordinates'];
    if (type == 'Polygon') {
      polygons.add(_polyFromRings(coords as List, fill, border, borderW));
    } else if (type == 'MultiPolygon') {
      for (final poly in (coords as List)) {
        polygons.add(_polyFromRings(poly as List, fill, border, borderW));
      }
    }
  }
  return polygons;
}

Polyline _polyline(List coords, Color color, double width) => Polyline(
      points: _ring(coords),
      color: color,
      strokeWidth: width,
      strokeCap: StrokeCap.round,
      strokeJoin: StrokeJoin.round,
    );

List<Polyline> _toPolylines(Map<String, dynamic> fc, Color color, double width) {
  final lines = <Polyline>[];
  for (final f in _features(fc)) {
    final geom = f['geometry'] as Map<String, dynamic>?;
    if (geom == null) continue;
    final type = geom['type'] as String;
    final coords = geom['coordinates'];
    if (type == 'LineString') {
      lines.add(_polyline(coords as List, color, width));
    } else if (type == 'MultiLineString') {
      for (final seg in (coords as List)) {
        lines.add(_polyline(seg as List, color, width));
      }
    }
  }
  return lines;
}

// ── Colores exactos SENAPRED ──────────────────────────────────────────────────
// Tsunami — Layer 3 zona: fill RGB(230,0,0) 50% opacidad (SENAPRED transparency=50).
// Agregamos borde discreto del mismo rojo a 70% para que la zona no se vea como
// una mancha difusa sino con contorno definido.
const _tsunamiZonaFill   = Color.fromARGB(128, 230, 0, 0);
const _tsunamiZonaBorder = Color.fromARGB(178, 180, 0, 0);

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

/// Zona inundable tsunami — rojo semitransparente con borde definido.
final tsunamiZonaPolygonsProvider = Provider<List<Polygon>>((ref) =>
    ref.watch(tsunamiZonaProvider).whenOrNull(
      data: (fc) => _toPolygons(fc, _tsunamiZonaFill, _tsunamiZonaBorder, 1.2),
    ) ?? []);

/// Línea segura — verde RGB(112,168,0) (SENAPRED layer 2)
final tsunamiLimitePolylinesProvider = Provider<List<Polyline>>((ref) =>
    ref.watch(tsunamiLimiteProvider).whenOrNull(
      data: (fc) => _toPolylines(fc, _tsunamiLimiteColor, 2.5),
    ) ?? []);

/// Vías de evacuación — azul RGB(0,112,255) (SENAPRED layer 1)
final tsunamiViasPolylinesProvider = Provider<List<Polyline>>((ref) =>
    ref.watch(tsunamiViasProvider).whenOrNull(
      data: (fc) => _toPolylines(fc, _tsunamiViasColor, 3.0),
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

// ── Helpers de hatch (textura rayada) ────────────────────────────────────────
//
// Algoritmo scanline: para una recta de barrido (lng = lat + c) se intersecta
// con cada arista del polígono. Las intersecciones, ordenadas, definen pares
// dentro/fuera (regla par-impar). Conectando los pares se obtiene el rayado
// recortado al polígono.

List<Polyline> _hatchPolygon({
  required List<LatLng> outer,
  required List<List<LatLng>> holes,
  required Color color,
  required double strokeWidth,
  required double stepDeg,
}) {
  double minLat = double.infinity, maxLat = -double.infinity;
  double minLng = double.infinity, maxLng = -double.infinity;
  for (final p in outer) {
    if (p.latitude < minLat) minLat = p.latitude;
    if (p.latitude > maxLat) maxLat = p.latitude;
    if (p.longitude < minLng) minLng = p.longitude;
    if (p.longitude > maxLng) maxLng = p.longitude;
  }

  // Junta todos los anillos (exterior + hoyos) — la regla par-impar maneja
  // ambos: las intersecciones con el borde de un hoyo invierten la paridad y
  // crean automáticamente un "salto" en la línea de rayado.
  final allRings = <List<LatLng>>[outer, ...holes];

  final lines = <Polyline>[];

  // Diagonales lng = lat + c, c ∈ [minLng-maxLat, maxLng-minLat]
  final cMin = minLng - maxLat;
  final cMax = maxLng - minLat;
  for (double c = cMin; c <= cMax; c += stepDeg) {
    final hits = <LatLng>[];
    for (final ring in allRings) {
      for (int i = 0; i < ring.length; i++) {
        final a = ring[i];
        final b = ring[(i + 1) % ring.length];
        // Resuelve: a.lng + t*(b.lng-a.lng) = a.lat + t*(b.lat-a.lat) + c
        final denom = (b.longitude - a.longitude) - (b.latitude - a.latitude);
        if (denom.abs() < 1e-12) continue;
        final t = (a.latitude + c - a.longitude) / denom;
        if (t < 0 || t > 1) continue;
        hits.add(LatLng(
          a.latitude + t * (b.latitude - a.latitude),
          a.longitude + t * (b.longitude - a.longitude),
        ));
      }
    }
    if (hits.length < 2) continue;
    hits.sort((p1, p2) => p1.latitude.compareTo(p2.latitude));
    for (int i = 0; i + 1 < hits.length; i += 2) {
      lines.add(Polyline(
        points: [hits[i], hits[i + 1]],
        color: color,
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
      ));
    }
  }
  return lines;
}

/// Parsea rings de un Polygon GeoJSON a (exterior, hoyos).
({List<LatLng> outer, List<List<LatLng>> holes}) _ringsOf(List rings) {
  return (
    outer: _ring(rings[0] as List),
    holes: [
      for (var i = 1; i < rings.length; i++) _ring(rings[i] as List),
    ],
  );
}

/// Incendio forestal — polígonos por gridcode (class breaks SENAPRED).
/// Se ordena por gridcode ascendente para que los niveles altos se pinten sobre
/// los bajos (evita que "Muy alto" quede tapado por una mancha "Bajo" gigante).
final incendioPolygonsProvider = Provider<List<Polygon>>((ref) {
  return ref.watch(incendioProvider).whenOrNull(
    data: (fc) {
      final entries = <(int, Map<String, dynamic>)>[];
      for (final f in _features(fc)) {
        if (f['geometry'] == null) continue;
        final props = f['properties'] as Map<String, dynamic>? ?? {};
        final gc = (props['gridcode'] as num?)?.toInt() ?? 1;
        entries.add((gc, f));
      }
      entries.sort((a, b) => a.$1.compareTo(b.$1));

      final polygons = <Polygon>[];
      for (final (gridcode, f) in entries) {
        final geom = f['geometry'] as Map<String, dynamic>;
        final type = geom['type'] as String;
        final coords = geom['coordinates'];
        final baseColor = _incendioColor(gridcode);
        // Opacidad creciente con el nivel para que se distinga la estratificación.
        final fillAlpha = 0.30 + (gridcode - 2) * 0.07; // 2→0.30 .. 5→0.51
        final fill = baseColor.withValues(alpha: fillAlpha);
        final border = baseColor.withValues(alpha: 0.85);

        if (type == 'Polygon') {
          polygons.add(_polyFromRings(coords as List, fill, border, 0.8));
        } else if (type == 'MultiPolygon') {
          for (final poly in (coords as List)) {
            polygons.add(_polyFromRings(poly as List, fill, border, 0.8));
          }
        }
      }
      return polygons;
    },
  ) ?? [];
});

/// Textura de rayado diagonal para zonas de incendio ALTO y MUY ALTO.
/// Da sensación de "advertencia activa" sobre las zonas críticas.
final incendioHatchPolylinesProvider = Provider<List<Polyline>>((ref) {
  return ref.watch(incendioProvider).whenOrNull(
    data: (fc) {
      final lines = <Polyline>[];
      for (final f in _features(fc)) {
        if (f['geometry'] == null) continue;
        final props = f['properties'] as Map<String, dynamic>? ?? {};
        final gc = (props['gridcode'] as num?)?.toInt() ?? 1;
        if (gc < 4) continue; // Solo Alto y Muy alto llevan textura.

        // Espaciado fijo en grados; ≈ 90 m a la latitud de Lota.
        final step = gc >= 5 ? 0.00065 : 0.00090;
        final strokeW = gc >= 5 ? 1.1 : 0.9;
        final hatchColor = _incendioColor(gc).withValues(alpha: 0.55);

        final geom = f['geometry'] as Map<String, dynamic>;
        final type = geom['type'] as String;
        final coords = geom['coordinates'];

        void emit(List rings) {
          final r = _ringsOf(rings);
          lines.addAll(_hatchPolygon(
            outer: r.outer,
            holes: r.holes,
            color: hatchColor,
            strokeWidth: strokeW,
            stepDeg: step,
          ));
        }

        if (type == 'Polygon') {
          emit(coords as List);
        } else if (type == 'MultiPolygon') {
          for (final poly in (coords as List)) {
            emit(poly as List);
          }
        }
      }
      return lines;
    },
  ) ?? [];
});
