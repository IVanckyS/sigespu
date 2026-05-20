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
      // Infraestructura comunitaria
      case 'centro_acopio':      return LucideIcons.home;
      case 'sede_comunitaria':   return LucideIcons.users;
      case 'infraestructura':    return LucideIcons.building;
      // Seguridad pública
      case 'zona_peligro':       return LucideIcons.shieldAlert;
      case 'reporte_robo':       return LucideIcons.alertTriangle;
      case 'reporte_vandalismo': return LucideIcons.flaskConical;
      case 'reporte_accidente':  return LucideIcons.car;
      // Incidentes urbanos
      case 'arbol_caido':        return LucideIcons.treePine;
      case 'poste_caido':        return LucideIcons.zap;
      case 'sector_sin_luz':     return LucideIcons.moon;
      case 'cable_colgando':     return LucideIcons.link;
      case 'semaforo_dañado':    return LucideIcons.alertOctagon;
      case 'socavon':            return LucideIcons.triangle;
      case 'fuga_agua':          return LucideIcons.droplet;
      case 'microbasural':       return LucideIcons.trash2;
      // Cobertura y fiscalización
      case 'patente':            return LucideIcons.bookmark;
      case 'luminaria':          return LucideIcons.lightbulb;
      case 'camara_cctv':        return LucideIcons.video;
      // Actividades municipales
      case 'actividad_reunion':       return LucideIcons.users;
      case 'actividad_operativo':     return LucideIcons.shield;
      case 'actividad_evento':        return LucideIcons.calendar;
      case 'actividad_capacitacion':  return LucideIcons.graduationCap;
      case 'actividad_municipal':     return LucideIcons.calendar;
      // Capas del sistema (sin marcador propio)
      case 'reporte':            return LucideIcons.alertTriangle;
      case 'plan_regulador':     return LucideIcons.map;
      case 'zona_tsunami':       return LucideIcons.waves;
      case 'zona_incendio':      return LucideIcons.flame;
      default:
        if (tipo.startsWith('reporte_')) return LucideIcons.alertTriangle;
        return LucideIcons.mapPin;
    }
  }

  static Color getColorForTipo(String tipo) {
    switch (tipo) {
      case 'centro_acopio': return AppTheme.orange600;
      case 'sede_comunitaria': return AppTheme.tSede;
      case 'infraestructura': return AppTheme.orange700;
      case 'zona_peligro': return AppTheme.redDanger;
      case 'patente': return AppTheme.amberWarning;
      case 'reporte_robo': return AppTheme.tRobo;
      case 'reporte_vandalismo': return AppTheme.tVandalismo;
      case 'reporte_accidente': return AppTheme.orange500;
      case 'luminaria': return AppTheme.tLuminaria;
      case 'camara_cctv': return AppTheme.tCamara;
      case 'arbol_caido': return AppTheme.tArbol;
      case 'poste_caido': return AppTheme.orange700;
      case 'sector_sin_luz': return AppTheme.tSinLuz;
      case 'cable_colgando': return AppTheme.orange600;
      case 'semaforo_dañado': return AppTheme.tRobo;
      case 'socavon': return AppTheme.tSocavon;
      case 'fuga_agua': return AppTheme.tAgua;
      case 'microbasural': return AppTheme.tBasural;
      // Actividades municipales: cada tipo con su color institucional
      case 'actividad_reunion':       return AppTheme.blue800;          // azul institucional
      case 'actividad_operativo':     return const Color(0xFFDC2626);    // rojo operativo
      case 'actividad_evento':        return const Color(0xFF7C3AED);    // morado eventos
      case 'actividad_capacitacion':  return AppTheme.greenSuccess;     // verde formación
      case 'actividad_municipal':     return const Color(0xFF7C3AED);    // fallback genérico
      default:
        if (tipo.startsWith('reporte_')) return AppTheme.redDanger;
        if (tipo.startsWith('actividad_')) return const Color(0xFF7C3AED);
        return AppTheme.stone600;
    }
  }
}
