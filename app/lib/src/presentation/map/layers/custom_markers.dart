import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomMarkers {
  static Marker buildMarker({
    required LatLng point,
    required IconData icon,
    required Color color,
    bool isPending = false,
    VoidCallback? onTap,
  }) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle, // Simplified shape for mockup
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            if (isPending)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppTheme.amberWarning,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      '!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static IconData getIconForTipo(String tipo) {
    switch (tipo) {
      case 'centro_acopio': return LucideIcons.store;
      case 'sede_comunitaria': return LucideIcons.home;
      case 'infraestructura': return LucideIcons.building;
      case 'reporte_robo': return LucideIcons.alertTriangle;
      case 'reporte_vandalismo': return LucideIcons.alertCircle;
      case 'reporte_accidente': return LucideIcons.car;
      case 'zona_peligro': return LucideIcons.shieldAlert;
      case 'patente': return LucideIcons.briefcase;
      case 'luminaria': return LucideIcons.lightbulb;
      case 'camara_cctv': return LucideIcons.camera;
      case 'arbol_caido': return LucideIcons.treePine;
      case 'poste_caido': return LucideIcons.zap;
      case 'sector_sin_luz': return LucideIcons.moon;
      case 'cable_colgando': return LucideIcons.link;
      case 'semaforo_dañado': return LucideIcons.alertOctagon;
      case 'socavon': return LucideIcons.triangle;
      case 'fuga_agua': return LucideIcons.droplet;
      case 'microbasural': return LucideIcons.trash2;
      default: return LucideIcons.mapPin;
    }
  }

  static Color getColorForTipo(String tipo) {
    if (tipo.startsWith('reporte_')) return AppTheme.redDanger;
    switch (tipo) {
      case 'centro_acopio': return AppTheme.orange600;
      case 'sede_comunitaria': return AppTheme.greenSuccess;
      case 'infraestructura': return AppTheme.blue800;
      case 'zona_peligro': return AppTheme.redDanger;
      case 'patente': return AppTheme.amberWarning;
      case 'luminaria': return Colors.yellow.shade700;
      case 'camara_cctv': return Colors.purple.shade600;
      case 'arbol_caido': return Colors.green.shade800;
      case 'poste_caido': return AppTheme.orange600;
      case 'sector_sin_luz': return AppTheme.stone800;
      case 'cable_colgando': return AppTheme.orange700;
      case 'semaforo_dañado': return AppTheme.redDanger;
      case 'socavon': return Colors.brown.shade700;
      case 'fuga_agua': return Colors.blue.shade600;
      case 'microbasural': return Colors.brown.shade800;
      default: return AppTheme.stone600;
    }
  }
}
