import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/visor_provider.dart';
import '../map_screen.dart' show activeLayersProvider;

class PanelCapas extends ConsumerStatefulWidget {
  final bool isDirector;
  final VoidCallback onSubirCapa;

  const PanelCapas({
    super.key,
    required this.isDirector,
    required this.onSubirCapa,
  });

  @override
  ConsumerState<PanelCapas> createState() => _PanelCapasState();
}

class _PanelCapasState extends ConsumerState<PanelCapas> {
  final _expanded = <String, bool>{
    'Amenazas': true,
    'Infraestructura': false,
    'Seguridad': false,
    'Municipal': false,
    'Personalizadas': true,
  };

  static const _nativeLayers = {
    'Amenazas': [
      ('sismos', 'Sismos recientes', Color(0xFFE53935)),
    ],
    'Infraestructura': [
      ('infraestructura', 'Infraestructura pública', Color(0xFF1E3A8A)),
      ('sede_comunitaria', 'Sedes comunitarias', Color(0xFF16A34A)),
      ('centro_acopio', 'Centros de acopio', Color(0xFFEA580C)),
    ],
    'Seguridad': [
      ('zona_peligro', 'Zonas de peligro', Color(0xFFB91C1C)),
      ('reporte', 'Reportes seguridad', Color(0xFFEF4444)),
    ],
    'Municipal': [
      ('plan_regulador', 'Plan Regulador', Color(0xFFCA8A04)),
      ('patente', 'Patentes comerciales', Color(0xFFD97706)),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final activeLayers = ref.watch(activeLayersProvider);
    final sismosVisible = ref.watch(sismosVisibleProvider);
    final capasAsync = ref.watch(capasPersonalizadasProvider);
    final customVisible = ref.watch(customLayersVisibleProvider);

    return Container(
      width: 280,
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
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(children: [
              const Text(
                'Lista de capas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => ref
                    .read(activePanelProvider.notifier)
                    .state = VisorPanel.none,
                icon: const Icon(Icons.close,
                    color: Colors.white54, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ]),
          ),
          const Divider(color: Colors.white12, height: 1),

          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Native layer groups
                  ..._nativeLayers.entries.map((entry) {
                    return _buildGroup(
                      entry.key,
                      entry.value.map((l) {
                        final (key, name, color) = l;
                        final isActive = key == 'sismos'
                            ? sismosVisible
                            : activeLayers.contains(key);
                        return _LayerRow(
                          color: color,
                          name: name,
                          isActive: isActive,
                          onToggle: () {
                            if (key == 'sismos') {
                              ref
                                  .read(sismosVisibleProvider.notifier)
                                  .state = !sismosVisible;
                            } else {
                              final next =
                                  Set<String>.from(activeLayers);
                              isActive
                                  ? next.remove(key)
                                  : next.add(key);
                              ref
                                  .read(activeLayersProvider.notifier)
                                  .state = next;
                            }
                          },
                        );
                      }).toList(),
                    );
                  }),

                  // Custom layers section
                  _buildGroupHeader(
                    'Personalizadas',
                    trailing: widget.isDirector
                        ? IconButton(
                            onPressed: widget.onSubirCapa,
                            icon: const Icon(Icons.add,
                                color: Colors.white54, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        : null,
                  ),
                  if (_expanded['Personalizadas'] == true)
                    capasAsync.when(
                      data: (capas) => Column(
                        children: capas.map((c) {
                          final isActive =
                              customVisible[c.id] ?? c.visible;
                          final colorVal = int.tryParse(
                                  c.color.replaceFirst('#', '0xFF')) ??
                              0xFFFF5722;
                          return _LayerRow(
                            color: Color(colorVal),
                            name: c.nombre,
                            isActive: isActive,
                            onToggle: () {
                              final next =
                                  Map<int, bool>.from(customVisible);
                              next[c.id] = !isActive;
                              ref
                                  .read(customLayersVisibleProvider
                                      .notifier)
                                  .state = next;
                            },
                          );
                        }).toList(),
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white38,
                        ),
                      ),
                      error: (_, __) => const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Error al cargar capas',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(String title, List<Widget> rows) {
    return Column(children: [
      _buildGroupHeader(title),
      if (_expanded[title] == true) ...rows,
    ]);
  }

  Widget _buildGroupHeader(String title, {Widget? trailing}) {
    return InkWell(
      onTap: () => setState(
          () => _expanded[title] = !(_expanded[title] ?? false)),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Icon(
            _expanded[title] == true
                ? Icons.keyboard_arrow_down
                : Icons.keyboard_arrow_right,
            color: Colors.white38,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ]),
      ),
    );
  }
}

class _LayerRow extends StatelessWidget {
  final Color color;
  final String name;
  final bool isActive;
  final VoidCallback onToggle;

  const _LayerRow({
    required this.color,
    required this.name,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(children: [
          Checkbox(
            value: isActive,
            onChanged: (_) => onToggle(),
            activeColor: color,
            checkColor: Colors.white,
            side: const BorderSide(color: Colors.white38),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
