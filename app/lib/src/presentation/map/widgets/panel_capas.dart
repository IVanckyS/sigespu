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
                    final groupName = entry.key;
                    final nativeWidgets = entry.value.map((l) {
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
                            ref.read(sismosVisibleProvider.notifier).state =
                                !sismosVisible;
                          } else {
                            final next = Set<String>.from(activeLayers);
                            isActive ? next.remove(key) : next.add(key);
                            ref.read(activeLayersProvider.notifier).state =
                                next;
                          }
                        },
                      );
                    }).toList();

                    return _buildGroup(
                      groupName,
                      [
                        ...nativeWidgets,
                        // Custom layers for this category
                        ...capasAsync.maybeWhen(
                          data: (capas) => capas
                              .where((c) => c.categoria == groupName)
                              .map((c) => _buildCustomRow(c, customVisible, ref)),
                          orElse: () => [],
                        ),
                      ],
                    );
                  }),

                  // Catch-all for "Personalizadas" or any category not in _nativeLayers
                  _buildGroup(
                    'Personalizadas',
                    capasAsync.maybeWhen(
                      data: (capas) => capas
                          .where((c) =>
                              !_nativeLayers.containsKey(c.categoria) ||
                              c.categoria == 'Personalizadas')
                          .map((c) => _buildCustomRow(c, customVisible, ref))
                          .toList(),
                      loading: () => [
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white38,
                          ),
                        )
                      ],
                      orElse: () => [],
                    ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomRow(dynamic c, Map<String, bool> customVisible, WidgetRef ref) {
    final isActive = customVisible[c.id] ?? c.visible;
    final colorVal = int.tryParse(c.color.replaceFirst('#', '0xFF')) ?? 0xFFFF5722;
    return _LayerRow(
      color: Color(colorVal),
      name: c.nombre,
      isActive: isActive,
      onToggle: () {
        final next = Map<String, bool>.from(customVisible);
        final newState = !isActive;
        next[c.id] = newState;
        ref.read(customLayersVisibleProvider.notifier).state = next;
        
        // Mark as selected for download if toggled ON
        if (newState) {
          ref.read(selectedCapaIdProvider.notifier).state = c.id;
        } else if (ref.read(selectedCapaIdProvider) == c.id) {
          ref.read(selectedCapaIdProvider.notifier).state = null;
        }
      },
      trailing: widget.isDirector
          ? IconButton(
              onPressed: () => _confirmDelete(c.id, c.nombre),
              icon: const Icon(Icons.delete_outline,
                  color: Colors.white30, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Eliminar capa',
            )
          : null,
    );
  }

  void _confirmDelete(String id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2327),
        title: const Text('Eliminar capa',
            style: TextStyle(color: Colors.white, fontSize: 14)),
        content: Text('¿Estás seguro de eliminar "$nombre"?',
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () async {
              final ok = await deleteCapa(ref, id);
              if (mounted) {
                Navigator.pop(ctx);
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al eliminar la capa')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(String title, List<Widget> rows, {Widget? trailing}) {
    return Column(children: [
      _buildGroupHeader(title, trailing: trailing),
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
  final Widget? trailing;

  const _LayerRow({
    required this.color,
    required this.name,
    required this.isActive,
    required this.onToggle,
    this.trailing,
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
          if (trailing != null) trailing!,
        ]),
      ),
    );
  }
}
