import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/map_config.dart';
import '../providers/visor_provider.dart';
import '../providers/map_providers.dart';

class PanelLeyenda extends ConsumerWidget {
  const PanelLeyenda({super.key});

  // Sub-leyendas para capas compuestas (tsunami, incendio, sismos).
  // Las capas atómicas se resuelven contra MapLayerConfig.layers.
  static const _tsunamiSubItems = <(String, Color, bool)>[
    ('Zona inundable',     Color.fromARGB(180, 230, 0, 0), false),
    ('Línea segura',       Color(0xFF70A800),               false),
    ('Vías de evacuación', Color(0xFF0070FF),               false),
    ('Punto de encuentro', Color(0xFF0070FF),               false),
  ];

  static const _incendioSubItems = <(String, Color)>[
    ('Bajo',     Color(0xFFA0C29B)),
    ('Medio',    Color(0xFFFAFA64)),
    ('Alto',     Color(0xFFFA8D34)),
    ('Muy alto', Color(0xFFE81014)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLayers = ref.watch(activeLayersProvider);
    final sismosVisible = ref.watch(sismosVisibleProvider);
    final customVisible = ref.watch(customLayersVisibleProvider);
    final capasAsync = ref.watch(capasPersonalizadasProvider);

    final items = <Widget>[];

    if (sismosVisible) {
      items.add(const _LegendSection('Sismos (magnitud)'));
      items.add(const _LegendDot(color: Color(0xFF43A047), label: 'Menor a 4.0'));
      items.add(const _LegendDot(color: Color(0xFFFDD835), label: '4.0 – 4.9'));
      items.add(const _LegendDot(color: Color(0xFFFF8F00), label: '5.0 – 5.9'));
      items.add(const _LegendDot(color: Color(0xFFE53935), label: 'Mayor a 6.0'));
    }

    // Tsunami: capa compuesta con 4 sub-leyendas
    if (activeLayers.contains('zona_tsunami')) {
      items.add(const _LegendSection('Zona de tsunami'));
      for (final (label, color, isSquare) in _tsunamiSubItems) {
        items.add(_LegendDot(color: color, label: label, isSquare: isSquare));
      }
    }

    // Incendio forestal: 4 niveles SENAPRED
    if (activeLayers.contains('zona_incendio')) {
      items.add(const _LegendSection('Riesgo de incendio'));
      for (final (label, color) in _incendioSubItems) {
        items.add(_LegendDot(color: color, label: label, isSquare: true));
      }
    }

    // Resto de capas atómicas: leemos directamente desde MapLayerConfig
    final compositeLayers = {'zona_tsunami', 'zona_incendio'};
    final atomicActive = activeLayers
        .where((k) => !compositeLayers.contains(k))
        .toList();
    if (atomicActive.isNotEmpty) {
      items.add(const _LegendSection('Capas activas'));
      for (final (key, label, color) in MapLayerConfig.layers) {
        if (atomicActive.contains(key)) {
          items.add(_LegendDot(color: color, label: label));
        }
      }
    }

    capasAsync.whenData((capas) {
      final visibleCustom = capas.where((c) => customVisible[c.id] ?? false).toList();
      if (visibleCustom.isNotEmpty) {
        items.add(const _LegendSection('Capas personalizadas'));
        for (final c in visibleCustom) {
          final colorVal =
              int.tryParse(c.color.replaceFirst('#', '0xFF')) ?? 0xFFFF5722;
          items.add(_LegendDot(
            color: Color(colorVal),
            label: c.nombre,
            isSquare: true,
          ));
        }
      }
    });

    if (items.isEmpty) {
      items.add(const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Sin capas activas',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ));
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2327),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leyenda',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendSection extends StatelessWidget {
  final String title;
  const _LegendSection(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 3),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isSquare;
  const _LegendDot({
    required this.color,
    required this.label,
    this.isSquare = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: isSquare ? BorderRadius.circular(2) : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
        ]),
      );
}
