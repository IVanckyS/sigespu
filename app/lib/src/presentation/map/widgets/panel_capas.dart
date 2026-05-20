import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/visor_provider.dart';
import '../providers/map_providers.dart';

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
    'infra': true,
    'seguridad': false,
    'incidentes': false,
    'cobertura': false,
    'amenazas': false,
    'personalizadas': true,
  };

  // (icon, color, label) per tipo
  static const _meta = <String, (IconData, Color, String)>{
    'centro_acopio':      (Icons.home_outlined,        Color(0xFFEA580C), 'Centro de acopio'),
    'sede_comunitaria':   (Icons.people_outline,       Color(0xFF16A34A), 'Sede comunitaria'),
    'infraestructura':    (Icons.domain,               Color(0xFFC2410C), 'Infraestructura'),
    'zona_peligro':       (Icons.shield,               Color(0xFFB91C1C), 'Zona de peligro'),
    'reporte_robo':       (Icons.warning_amber,        Color(0xFFEF4444), 'Robo'),
    'reporte_vandalismo': (Icons.science,              Color(0xFF7C3AED), 'Vandalismo'),
    'reporte_accidente':  (Icons.directions_car,       Color(0xFFEA580C), 'Accidente'),
    'arbol_caido':        (Icons.forest,               Color(0xFF16A34A), 'Árbol caído'),
    'poste_caido':        (Icons.bolt,                 Color(0xFFEA580C), 'Poste caído'),
    'sector_sin_luz':     (Icons.nightlight,           Color(0xFF78716C), 'Sector sin luz'),
    'cable_colgando':     (Icons.cable,                Color(0xFF78716C), 'Cable colgando'),
    'semaforo_dañado':    (Icons.traffic,              Color(0xFFEF4444), 'Semáforo dañado'),
    'socavon':            (Icons.warning,              Color(0xFF92400E), 'Socavón / Hoyo'),
    'fuga_agua':          (Icons.water_drop,           Color(0xFF0891B2), 'Fuga de agua'),
    'microbasural':       (Icons.delete_outline,       Color(0xFF92400E), 'Microbasural'),
    'patente':            (Icons.bookmark_border,      Color(0xFFD97706), 'Patente comercial'),
    'luminaria':          (Icons.lightbulb_outline,    Color(0xFFCA8A04), 'Luminaria'),
    'camara_cctv':        (Icons.videocam,             Color(0xFF7C3AED), 'Cámara CCTV'),
  };

  // 4 main categories: (stateKey, label, tipos)
  static const _groups = <(String, String, List<String>)>[
    ('infra', 'Infraestructura comunitaria',
      ['centro_acopio', 'sede_comunitaria', 'infraestructura']),
    ('seguridad', 'Seguridad pública',
      ['zona_peligro', 'reporte_robo', 'reporte_vandalismo', 'reporte_accidente']),
    ('incidentes', 'Incidentes urbanos',
      ['arbol_caido', 'poste_caido', 'sector_sin_luz', 'cable_colgando',
       'semaforo_dañado', 'socavon', 'fuga_agua', 'microbasural']),
    ('cobertura', 'Cobertura y fiscalización',
      ['patente', 'luminaria', 'camara_cctv']),
  ];

  void _toggleLayer(String tipo, Set<String> current) {
    final next = Set<String>.from(current);
    current.contains(tipo) ? next.remove(tipo) : next.add(tipo);
    ref.read(activeLayersProvider.notifier).state = next;
  }

  @override
  Widget build(BuildContext context) {
    final activeLayers = ref.watch(activeLayersProvider);
    final sismosVisible = ref.watch(sismosVisibleProvider);
    final capasAsync = ref.watch(capasPersonalizadasProvider);
    final customVisible = ref.watch(customLayersVisibleProvider);

    final amenazasActive = (sismosVisible ? 1 : 0) +
        (activeLayers.contains('plan_regulador') ? 1 : 0) +
        (activeLayers.contains('zona_tsunami') ? 1 : 0) +
        (activeLayers.contains('zona_incendio') ? 1 : 0);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2327),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(children: [
              const Text(
                'Capas del mapa',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    ref.read(activePanelProvider.notifier).state = VisorPanel.none,
                icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ]),
          ),
          const Divider(color: Colors.white12, height: 1),

          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 540),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ── 4 categorías principales ─────────────────────────────────
                  for (final (key, label, tipos) in _groups) ...[
                    _CategoryHeader(
                      label: label,
                      expanded: _expanded[key] ?? false,
                      activeCount: tipos.where((t) => activeLayers.contains(t)).length,
                      total: tipos.length,
                      onTap: () => setState(
                          () => _expanded[key] = !(_expanded[key] ?? false)),
                    ),
                    if (_expanded[key] == true)
                      for (final tipo in tipos)
                        _TypeRow(
                          meta: _meta[tipo]!,
                          isActive: activeLayers.contains(tipo),
                          onToggle: () => _toggleLayer(tipo, activeLayers),
                        ),
                  ],

                  // ── Amenazas y datos base ─────────────────────────────────────
                  _CategoryHeader(
                    label: 'Amenazas y datos base',
                    expanded: _expanded['amenazas'] ?? false,
                    activeCount: amenazasActive,
                    total: 4,
                    onTap: () => setState(
                        () => _expanded['amenazas'] = !(_expanded['amenazas'] ?? false)),
                  ),
                  if (_expanded['amenazas'] == true) ...[
                    _TypeRow(
                      meta: (Icons.sensors, const Color(0xFFE53935), 'Sismos recientes'),
                      isActive: sismosVisible,
                      onToggle: () => ref
                          .read(sismosVisibleProvider.notifier)
                          .state = !sismosVisible,
                    ),
                    _TypeRow(
                      meta: (Icons.map_outlined, const Color(0xFFCA8A04), 'Plan Regulador'),
                      isActive: activeLayers.contains('plan_regulador'),
                      onToggle: () => _toggleLayer('plan_regulador', activeLayers),
                    ),
                    _TypeRow(
                      meta: (Icons.waves, const Color(0xFF0891B2), 'Zonas de Tsunami'),
                      isActive: activeLayers.contains('zona_tsunami'),
                      onToggle: () => _toggleLayer('zona_tsunami', activeLayers),
                    ),
                    _TypeRow(
                      meta: (Icons.local_fire_department, const Color(0xFFDC2626), 'Riesgo de Incendio'),
                      isActive: activeLayers.contains('zona_incendio'),
                      onToggle: () => _toggleLayer('zona_incendio', activeLayers),
                    ),
                  ],

                  // ── Capas personalizadas ──────────────────────────────────────
                  _CategoryHeader(
                    label: 'Capas personalizadas',
                    expanded: _expanded['personalizadas'] ?? true,
                    activeCount: capasAsync.maybeWhen(
                      data: (capas) =>
                          capas.where((c) => customVisible[c.id] ?? false).length,
                      orElse: () => 0,
                    ),
                    total: capasAsync.maybeWhen(
                        data: (capas) => capas.length, orElse: () => 0),
                    onTap: () => setState(() =>
                        _expanded['personalizadas'] =
                            !(_expanded['personalizadas'] ?? true)),
                    trailing: widget.isDirector
                        ? IconButton(
                            onPressed: widget.onSubirCapa,
                            icon: const Icon(Icons.add, color: Colors.white54, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        : null,
                  ),
                  if (_expanded['personalizadas'] == true)
                    capasAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white38),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (capas) => capas.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text(
                                widget.isDirector
                                    ? 'Sin capas. Usa + para agregar.'
                                    : 'Sin capas personalizadas.',
                                style: const TextStyle(
                                    color: Colors.white30, fontSize: 11),
                              ),
                            )
                          : Column(
                              children: capas.map((c) {
                                final isActive = customVisible[c.id] ?? false;
                                final colorVal = int.tryParse(
                                        c.color.replaceFirst('#', '0xFF')) ??
                                    0xFFFF5722;
                                return _CustomRow(
                                  nombre: c.nombre,
                                  color: Color(colorVal),
                                  isActive: isActive,
                                  isDirector: widget.isDirector,
                                  onToggle: () {
                                    final next =
                                        Map<String, bool>.from(customVisible);
                                    next[c.id] = !isActive;
                                    ref
                                        .read(customLayersVisibleProvider
                                            .notifier)
                                        .state = next;
                                    if (!isActive) {
                                      ref
                                          .read(selectedCapaIdProvider.notifier)
                                          .state = c.id;
                                    } else if (ref.read(selectedCapaIdProvider) ==
                                        c.id) {
                                      ref
                                          .read(selectedCapaIdProvider.notifier)
                                          .state = null;
                                    }
                                  },
                                  onDelete: () =>
                                      _confirmDelete(c.id, c.nombre),
                                );
                              }).toList(),
                            ),
                    ),

                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ],
      ),
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
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final ok = await deleteCapa(ref, id);
              if (!mounted) return;
              if (ctx.mounted) Navigator.pop(ctx);
              if (!ok) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Error al eliminar la capa')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Category accordion header ─────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  final String label;
  final bool expanded;
  final int activeCount;
  final int total;
  final VoidCallback onTap;
  final Widget? trailing;

  const _CategoryHeader({
    required this.label,
    required this.expanded,
    required this.activeCount,
    required this.total,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final hasActive = activeCount > 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 9, 10, 9),
        child: Row(children: [
          Icon(
            expanded
                ? Icons.keyboard_arrow_down_rounded
                : Icons.keyboard_arrow_right_rounded,
            color: Colors.white38,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: hasActive
                  ? const Color(0xFFEA580C)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hasActive ? '$activeCount/$total' : '0/$total',
              style: TextStyle(
                color: hasActive ? Colors.white : Colors.white38,
                fontSize: 9,
                fontWeight: hasActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
        ]),
      ),
    );
  }
}

// ── Individual layer row with icon badge + toggle ─────────────────────────────

class _TypeRow extends StatelessWidget {
  final (IconData, Color, String) meta;
  final bool isActive;
  final VoidCallback onToggle;

  const _TypeRow({
    required this.meta,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = meta;
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 5, 8, 5),
        child: Row(children: [
          // Colored icon badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isActive ? 0.22 : 0.07),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: isActive
                    ? color.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 15,
              color: isActive ? color : Colors.white30,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
          // Compact switch
          Transform.scale(
            scale: 0.72,
            child: Switch(
              value: isActive,
              onChanged: (_) => onToggle(),
              thumbColor: WidgetStateProperty.resolveWith((s) =>
                  s.contains(WidgetState.selected) ? color : Colors.white30),
              trackColor: WidgetStateProperty.resolveWith((s) =>
                  s.contains(WidgetState.selected)
                      ? color.withValues(alpha: 0.28)
                      : Colors.white.withValues(alpha: 0.1)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Custom (uploaded) layer row ───────────────────────────────────────────────

class _CustomRow extends StatelessWidget {
  final String nombre;
  final Color color;
  final bool isActive;
  final bool isDirector;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _CustomRow({
    required this.nombre,
    required this.color,
    required this.isActive,
    required this.isDirector,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 5, 8, 5),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isActive ? 0.22 : 0.07),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: isActive
                    ? color.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.layers_outlined,
              size: 15,
              color: isActive ? color : Colors.white30,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              nombre,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isDirector)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline,
                  color: Colors.white24, size: 15),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Eliminar capa',
            ),
          Transform.scale(
            scale: 0.72,
            child: Switch(
              value: isActive,
              onChanged: (_) => onToggle(),
              thumbColor: WidgetStateProperty.resolveWith((s) =>
                  s.contains(WidgetState.selected) ? color : Colors.white30),
              trackColor: WidgetStateProperty.resolveWith((s) =>
                  s.contains(WidgetState.selected)
                      ? color.withValues(alpha: 0.28)
                      : Colors.white.withValues(alpha: 0.1)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ]),
      ),
    );
  }
}
