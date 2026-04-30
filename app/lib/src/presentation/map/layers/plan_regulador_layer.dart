import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/theme.dart';

class PlanReguladorLayer {
  static List<Polygon> buildPolygons() {
    // Datos sacados de la maqueta
    final sectores = [
      {
        'code': 'S-2',
        'name': 'Residencial Los Aromos',
        'color': const Color(0xFF86EFAC),
        'coords': [[-37.0850,-73.1690],[-37.0820,-73.1670],[-37.0820,-73.1620],[-37.0850,-73.1610],[-37.0870,-73.1640],[-37.0850,-73.1690]]
      },
      {
        'code': 'S-3',
        'name': 'Mixto Los Aromos',
        'color': const Color(0xFFFDE68A),
        'coords': [[-37.0820,-73.1620],[-37.0820,-73.1670],[-37.0790,-73.1660],[-37.0785,-73.1615],[-37.0820,-73.1620]]
      },
      {
        'code': 'S-4',
        'name': 'Equipamiento',
        'color': const Color(0xFFBFDBFE),
        'coords': [[-37.0785,-73.1615],[-37.0790,-73.1660],[-37.0760,-73.1655],[-37.0755,-73.1610],[-37.0785,-73.1615]]
      },
      {
        'code': 'S-5',
        'name': 'Vivienda Periférica',
        'color': const Color(0xFFC7D2FE),
        'coords': [[-37.0755,-73.1610],[-37.0760,-73.1655],[-37.0720,-73.1640],[-37.0715,-73.1600],[-37.0755,-73.1610]]
      },
      {
        'code': 'Centro',
        'name': 'Centro Histórico Lota',
        'color': const Color(0xFFFED7AA),
        'coords': [[-37.1010,-73.1570],[-37.0980,-73.1530],[-37.0950,-73.1560],[-37.0970,-73.1600],[-37.1010,-73.1570]]
      }
    ];

    return sectores.map((s) {
      final points = (s['coords'] as List<List<double>>)
          .map((c) => LatLng(c[0], c[1]))
          .toList();
      
      final color = s['color'] as Color;

      return Polygon(
        points: points,
        color: color.withValues(alpha: 0.18),
        borderColor: AppTheme.amberWarning,
        borderStrokeWidth: 2,
      );
    }).toList();
  }

  // Datos de sectores con nombre y coords (reflejando buildPolygons)
  static const _sectores = [
    {'code': 'S-2', 'name': 'Residencial Los Aromos',
     'coords': [[-37.0850,-73.1690],[-37.0820,-73.1670],[-37.0820,-73.1620],[-37.0850,-73.1610],[-37.0870,-73.1640],[-37.0850,-73.1690]]},
    {'code': 'S-3', 'name': 'Mixto Los Aromos',
     'coords': [[-37.0820,-73.1620],[-37.0820,-73.1670],[-37.0790,-73.1660],[-37.0785,-73.1615],[-37.0820,-73.1620]]},
    {'code': 'S-4', 'name': 'Equipamiento',
     'coords': [[-37.0785,-73.1615],[-37.0790,-73.1660],[-37.0760,-73.1655],[-37.0755,-73.1610],[-37.0785,-73.1615]]},
    {'code': 'S-5', 'name': 'Vivienda Periférica',
     'coords': [[-37.0755,-73.1610],[-37.0760,-73.1655],[-37.0720,-73.1640],[-37.0715,-73.1600],[-37.0755,-73.1610]]},
    {'code': 'Centro', 'name': 'Centro Histórico Lota',
     'coords': [[-37.1010,-73.1570],[-37.0980,-73.1530],[-37.0950,-73.1560],[-37.0970,-73.1600],[-37.1010,-73.1570]]},
  ];

  static List<Marker> buildCentroidMarkers(
      void Function(Map<String, dynamic> sector) onTap) {
    return _sectores.map((s) {
      final coords = s['coords'] as List;
      final lat = coords.map((c) => (c as List)[0] as double).reduce((a, b) => a + b) / coords.length;
      final lng = coords.map((c) => (c as List)[1] as double).reduce((a, b) => a + b) / coords.length;
      return Marker(
        point: LatLng(lat, lng),
        width: 80, height: 80,
        child: GestureDetector(
          onTap: () => onTap(s),
          child: const SizedBox(width: 80, height: 80), // transparente
        ),
      );
    }).toList();
  }
}
