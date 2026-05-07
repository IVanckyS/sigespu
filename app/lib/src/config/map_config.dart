import 'package:flutter/material.dart';
import 'theme.dart';

/// Configuración estática de capas, filtros y tipos de elementos del mapa.
/// Fuente única de verdad para sidebar, panel de leyenda y modal de agregar.
class MapLayerConfig {
  // ── Capas del sistema (sidebar y leyenda) ────────────────────────────────────

  static const List<(String, String, Color)> layers = [
    ('centro_acopio',    'Centros de acopio',     Color(0xFFEA580C)),
    ('sede_comunitaria', 'Sedes comunitarias',     Color(0xFF16A34A)),
    ('zona_peligro',     'Zonas de peligro',       Color(0xFFB91C1C)),
    ('reporte',          'Reportes de seguridad',  Color(0xFFEF4444)),
    ('patente',          'Patentes comerciales',   Color(0xFFD97706)),
    ('infraestructura',  'Infraestructura',        Color(0xFF1E3A8A)),
    ('plan_regulador',   'Plan Regulador',         Color(0xFFCA8A04)),
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

  // ── Categorías de zonas dibujadas ────────────────────────────────────────────

  static const List<(String, Color)> zoneCategories = [
    ('Seguridad',       AppTheme.redDanger),
    ('Infraestructura', AppTheme.blue800),
    ('Vialidad',        AppTheme.orange500),
    ('Comercio',        AppTheme.amberWarning),
    ('Comunitario',     AppTheme.greenSuccess),
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
