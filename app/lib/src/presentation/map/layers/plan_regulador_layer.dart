import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/theme.dart';

class PlanReguladorLayer {
  static List<Polygon> buildPolygons({Map<String, List<LatLng>>? edits}) {
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
      final code = s['code'] as String;
      final points = edits != null && edits.containsKey(code)
          ? edits[code]!
          : (s['coords'] as List<List<double>>)
              .map((c) => LatLng(c[0], c[1]))
              .toList();
      
      final color = s['color'] as Color;

      return Polygon(
        points: points,
        color: color.withValues(alpha: 0.18),
        borderColor: AppTheme.amberWarning,
        borderStrokeWidth: 2,
        isFilled: true,
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

  static List<Marker> buildCentroidMarkers({
    Map<String, List<LatLng>>? edits,
    required void Function(Map<String, dynamic> sector, BuildContext context) onTap,
  }) {
    return _sectores.map((s) {
      final code = s['code'] as String;
      final List<LatLng> points;
      if (edits != null && edits.containsKey(code)) {
        points = edits[code]!;
      } else {
        final coords = s['coords'] as List;
        points = coords.map((c) => LatLng(c[0] as double, c[1] as double)).toList();
      }

      final lat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
      final lng = points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
      
      final labelWidth = code.length > 4 ? 90.0 : 72.0;
      return Marker(
        point: LatLng(lat, lng),
        width: labelWidth,
        height: 28,
        child: Builder(builder: (context) {
          return GestureDetector(
            onTap: () => onTap(s, context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.amberWarning, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.amberWarning,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.edit_outlined, size: 10, color: AppTheme.amberWarning),
                ],
              ),
            ),
          );
        }),
      );
    }).toList();
  }
}
