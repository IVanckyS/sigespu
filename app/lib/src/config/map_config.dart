import 'package:flutter/material.dart';

/// Configuración estática de capas, filtros y tipos de elementos del mapa.
/// Fuente única de verdad para sidebar, panel de leyenda y modal de agregar.
class MapLayerConfig {
  // ── Capas del sistema (sidebar y leyenda) ────────────────────────────────────

  static const List<(String, String, Color)> layers = [
    // Infraestructura comunitaria
    ('centro_acopio',      'Centros de acopio',      Color(0xFFEA580C)),
    ('sede_comunitaria',   'Sedes comunitarias',      Color(0xFF16A34A)),
    ('infraestructura',    'Infraestructura',         Color(0xFF1E3A8A)),
    // Seguridad pública
    ('zona_peligro',       'Zona de peligro',         Color(0xFFB91C1C)),
    ('reporte_robo',       'Robo',                    Color(0xFFEF4444)),
    ('reporte_vandalismo', 'Vandalismo',              Color(0xFF7C3AED)),
    ('reporte_accidente',  'Accidente',               Color(0xFFEA580C)),
    // Incidentes urbanos
    ('arbol_caido',        'Árbol caído',             Color(0xFF16A34A)),
    ('poste_caido',        'Poste caído',             Color(0xFFEA580C)),
    ('sector_sin_luz',     'Sector sin luz',          Color(0xFF78716C)),
    ('cable_colgando',     'Cable colgando',          Color(0xFF78716C)),
    ('semaforo_dañado',    'Semáforo dañado',         Color(0xFFEF4444)),
    ('socavon',            'Socavón / Hoyo',          Color(0xFF92400E)),
    ('fuga_agua',          'Fuga de agua',            Color(0xFF0891B2)),
    ('microbasural',       'Microbasural',            Color(0xFF92400E)),
    // Cobertura y fiscalización
    ('patente',            'Patentes comerciales',    Color(0xFFD97706)),
    ('luminaria',          'Luminaria',               Color(0xFFCA8A04)),
    ('camara_cctv',        'Cámara CCTV',             Color(0xFF7C3AED)),
    // Amenazas y datos base
    ('plan_regulador',     'Plan Regulador',          Color(0xFFCA8A04)),
    ('zona_tsunami',       'Zonas de Tsunami',        Color(0xFF0891B2)),
    ('zona_incendio',      'Riesgo de Incendio',      Color(0xFFDC2626)),
    ('actividad_municipal','Actividades',              Color(0xFF7C3AED)),
  ];

  // ── Filtros de tipo de peligro ────────────────────────────────────────────────

  static const List<(String, String)> dangerFilters = [
    ('all',             'Todos'),
    ('drogas',          'Tráfico drogas'),
    ('robos',           'Robos'),
    ('vivienda_ilegal', 'Vivienda ilegal'),
    ('vandalismo',      'Vandalismo'),
    ('riña',            'Riñas'),
  ];

  // ── Grupos de tipos de elementos (modal agregar) ─────────────────────────────

  static const List<(String, List<String>)> elementGroups = [
    (
      'Infraestructura comunitaria',
      ['centro_acopio', 'sede_comunitaria', 'infraestructura'],
    ),
    (
      'Seguridad pública',
      ['zona_peligro', 'reporte_robo', 'reporte_vandalismo', 'reporte_accidente'],
    ),
    (
      'Incidentes urbanos',
      [
        'arbol_caido', 'poste_caido', 'sector_sin_luz', 'cable_colgando',
        'semaforo_dañado', 'socavon', 'fuga_agua', 'microbasural',
      ],
    ),
    (
      'Cobertura y fiscalización',
      ['patente', 'luminaria', 'camara_cctv'],
    ),
  ];

  // ── Tipos de peligro (formulario zona_peligro) ───────────────────────────────

  static const List<(String, String)> tiposPeligro = [
    ('drogas',          'Tráfico drogas'),
    ('robos',           'Robos'),
    ('vivienda_ilegal', 'Vivienda ilegal'),
    ('vandalismo',      'Vandalismo'),
    ('riña',            'Riñas'),
    ('sin_iluminacion', 'Sin iluminación'),
    ('microbasural',    'Microbasural'),
    ('otro',            'Otro'),
  ];

  // ── Horarios críticos ────────────────────────────────────────────────────────

  static const List<String> horarios = [
    '24/7',
    'Nocturno (22:00-06:00)',
    'Tarde/Noche',
    'Fines de semana',
    'Días hábiles',
  ];
}
