import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/visor_provider.dart';

class PanelMapaBase extends ConsumerWidget {
  const PanelMapaBase({super.key});

  static const _bases = [
    (MapaBase.cartoVoyager, 'CartoDB\nVoyager', Icons.map),
    (MapaBase.osm, 'OpenStreet\nMap', Icons.terrain),
    (MapaBase.esriSatelite, 'Satélite\nEsri', Icons.satellite_alt),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(mapaBaseProvider);

    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
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
            'Galería de mapas base',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _bases.map((b) {
              final (base, label, icon) = b;
              final isActive = current == base;
              return GestureDetector(
                onTap: () => ref.read(mapaBaseProvider.notifier).set(base),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 64,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF00897B)
                            : const Color(0xFF2A2F35),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF00897B)
                              : Colors.white12,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isActive ? Colors.white : Colors.white38,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white38,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
