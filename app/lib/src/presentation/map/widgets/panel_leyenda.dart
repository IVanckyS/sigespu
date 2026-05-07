import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/visor_provider.dart';
import '../providers/map_providers.dart';

class PanelLeyenda extends ConsumerWidget {
  const PanelLeyenda({super.key});

  static const _layerLegends = <String, (String, Color)>{
    'centro_acopio': ('Centro de acopio', Color(0xFFEA580C)),
    'sede_comunitaria': ('Sede comunitaria', Color(0xFF16A34A)),
    'zona_peligro': ('Zona de peligro', Color(0xFFB91C1C)),
    'reporte': ('Reporte seguridad', Color(0xFFEF4444)),
    'patente': ('Patente comercial', Color(0xFFD97706)),
    'infraestructura': ('Infraestructura', Color(0xFF1E3A8A)),
    'plan_regulador': ('Plan Regulador', Color(0xFFCA8A04)),
  };

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

    for (final key in activeLayers) {
      final entry = _layerLegends[key];
      if (entry != null) {
        final (label, color) = entry;
        items.add(_LegendDot(color: color, label: label));
      }
    }

    capasAsync.whenData((capas) {
      for (final c in capas) {
        if (customVisible[c.id] ?? c.visible) {
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

    return Container(
      width: 220,
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
          ...items,
        ],
      ),
    );
  }
}

class _LegendSection extends StatelessWidget {
  final String title;
  const _LegendSection(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 2),
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
