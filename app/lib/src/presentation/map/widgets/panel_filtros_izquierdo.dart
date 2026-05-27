import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared/shared.dart';
import '../../../config/theme.dart';
import '../../actividades/actividades_provider.dart';
import '../providers/map_providers.dart';

class PanelFiltrosIzquierdo extends ConsumerStatefulWidget {
  const PanelFiltrosIzquierdo({super.key});

  @override
  ConsumerState<PanelFiltrosIzquierdo> createState() =>
      _PanelFiltrosIzquierdoState();
}

class _PanelFiltrosIzquierdoState
    extends ConsumerState<PanelFiltrosIzquierdo> {
  bool _collapsed = false;
  bool _zonasExpanded = false;

  static const _kWidth = 272.0;
  static const _kCollapsed = 44.0;
  static const _kBg = Color(0xFF1E2327);

  static const _grupos = <(String, List<String>)>[
    ('SEGURIDAD PÚBLICA',
        ['zona_peligro', 'reporte_robo', 'reporte_vandalismo', 'reporte_accidente']),
    ('INFRAESTRUCTURA',
        ['centro_acopio', 'sede_comunitaria', 'infraestructura']),
    ('INCIDENTES URBANOS',
        ['arbol_caido', 'poste_caido', 'sector_sin_luz', 'cable_colgando',
         'semaforo_dañado', 'socavon', 'fuga_agua', 'microbasural']),
    ('DATOS MUNICIPALES',
        ['patente', 'luminaria', 'camara_cctv', 'plan_regulador']),
  ];

  static const _tipoLabels = <String, String>{
    'zona_peligro': 'Zona de peligro', 'reporte_robo': 'Robo',
    'reporte_vandalismo': 'Vandalismo', 'reporte_accidente': 'Accidente',
    'centro_acopio': 'Centro de acopio', 'sede_comunitaria': 'Sede comunitaria',
    'infraestructura': 'Infraestructura', 'arbol_caido': 'Árbol caído',
    'poste_caido': 'Poste caído', 'sector_sin_luz': 'Sin luz',
    'cable_colgando': 'Cable colgando', 'semaforo_dañado': 'Semáforo',
    'socavon': 'Socavón', 'fuga_agua': 'Fuga agua', 'microbasural': 'Microbasural',
    'patente': 'Patentes', 'luminaria': 'Luminaria',
    'camara_cctv': 'Cámara CCTV', 'plan_regulador': 'Plan Regulador',
  };

  static const _tipoColors = <String, Color>{
    'zona_peligro': Color(0xFFB91C1C), 'reporte_robo': Color(0xFFEF4444),
    'reporte_vandalismo': Color(0xFF7C3AED), 'reporte_accidente': Color(0xFFEA580C),
    'centro_acopio': Color(0xFFEA580C), 'sede_comunitaria': Color(0xFF16A34A),
    'infraestructura': Color(0xFFC2410C), 'arbol_caido': Color(0xFF16A34A),
    'poste_caido': Color(0xFFEA580C), 'sector_sin_luz': Color(0xFF78716C),
    'cable_colgando': Color(0xFF78716C), 'semaforo_dañado': Color(0xFFEF4444),
    'socavon': Color(0xFF92400E), 'fuga_agua': Color(0xFF0891B2),
    'microbasural': Color(0xFF92400E), 'patente': Color(0xFFD97706),
    'luminaria': Color(0xFFCA8A04), 'camara_cctv': Color(0xFF7C3AED),
    'plan_regulador': Color(0xFFCA8A04),
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _collapsed ? _kCollapsed : _kWidth,
      child: _collapsed ? _buildRail() : _buildPanel(),
    );
  }

  Widget _buildRail() {
    return Container(
      color: _kBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _PanelBtn(
            icon: Icons.chevron_right,
            tooltip: 'Expandir panel',
            onTap: () => setState(() => _collapsed = false),
          ),
          const SizedBox(height: 8),
          const _PanelBtn(icon: Icons.layers_outlined, tooltip: 'Capas'),
          const _PanelBtn(icon: Icons.view_kanban_outlined, tooltip: 'Actividades'),
          const _PanelBtn(icon: Icons.filter_alt_outlined, tooltip: 'Filtros'),
        ],
      ),
    );
  }

  Widget _buildPanel() {
    return Container(
      color: _kBg,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              children: [
                _buildActividadesBlock(),
                const SizedBox(height: 10),
                _buildCapasBlock(),
                const SizedBox(height: 10),
                _buildZonasDibujadasBlock(),
                const SizedBox(height: 10),
                _buildFiltrosBlock(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      child: Row(
        children: [
          const Icon(Icons.layers_outlined, size: 16, color: Color(0xFFEA580C)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Capas & Filtros',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          _PanelBtn(
            icon: Icons.chevron_left,
            tooltip: 'Colapsar',
            onTap: () => setState(() => _collapsed = true),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadesBlock() {
    final actividades = ref.watch(actividadesProvider);
    final total = actividades.length;
    final completadas =
        actividades.where((a) => a.estado == EstadoActividad.completado).length;
    final pct = total > 0 ? (completadas / total * 100).round() : 0;

    final sectorCounts = <String, int>{};
    for (final a in actividades) {
      if (a.sector != null) {
        sectorCounts[a.sector!] = (sectorCounts[a.sector!] ?? 0) + 1;
      }
    }
    final topSectores = (sectorCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(4)
        .toList();
    final maxCount = topSectores.isEmpty ? 1 : topSectores.first.value;

    return _PanelBlock(
      title: 'COBERTURA · ACTIVIDADES',
      titleColor: const Color(0xFFEA580C),
      child: Column(
        children: [
          Row(children: [
            _StatChip(label: 'Total', value: '$total',
                valueColor: const Color(0xFFFB923C)),
            const SizedBox(width: 8),
            _StatChip(label: 'Completadas', value: '$pct%',
                valueColor: const Color(0xFF4ADE80),
                bg: const Color(0x2215803D)),
          ]),
          const SizedBox(height: 8),
          const _SectionLabel('TOP SECTORES'),
          const SizedBox(height: 4),
          ...topSectores.map((e) => _SectorBar(
                name: e.key,
                count: e.value,
                maxCount: maxCount,
              )),
        ],
      ),
    );
  }

  Widget _buildCapasBlock() {
    final activeLayers = ref.watch(activeLayersProvider);
    final counts = ref.watch(layerCountsProvider);

    return _PanelBlock(
      title: 'CAPAS DEL SISTEMA',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _grupos.expand((grupo) {
          final (groupLabel, tipos) = grupo;
          return [
            _SectionLabel(groupLabel),
            const SizedBox(height: 3),
            ...tipos.map((tipo) {
              final active = activeLayers.contains(tipo);
              final color = _tipoColors[tipo] ?? AppTheme.stone400;
              final label = _tipoLabels[tipo] ?? tipo;
              final count = counts[tipo] ?? 0;
              return _LayerRow(
                color: color,
                label: label,
                count: count,
                active: active,
                onToggle: (v) {
                  ref.read(activeLayersProvider.notifier).toggle(tipo);
                },
              );
            }),
            const SizedBox(height: 6),
          ];
        }).toList(),
      ),
    );
  }

  Widget _buildZonasDibujadasBlock() {
    final polygons = ref.watch(userPolygonsProvider);
    final categories = ref.watch(customZonaCategoriesProvider);
    final activeCategories = ref.watch(activeZonaCategoriesProvider);
    final activeLayers = ref.watch(activeLayersProvider);
    final allActive = activeLayers.contains('zona_custom');

    return _PanelBlock(
      title: 'ZONAS DIBUJADAS',
      child: Column(
        children: [
          _LayerRow(
            color: const Color(0xFF7C3AED),
            label: 'Todas las zonas ✏',
            count: polygons.length,
            active: allActive,
            onToggle: (v) {
              ref.read(activeLayersProvider.notifier).toggle('zona_custom');
            },
            trailing: polygons.isNotEmpty
                ? GestureDetector(
                    onTap: () =>
                        setState(() => _zonasExpanded = !_zonasExpanded),
                    child: Icon(
                      _zonasExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 16,
                      color: const Color(0xFFA8A29E),
                    ),
                  )
                : null,
          ),
          if (_zonasExpanded && categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                children: categories.map((cat) {
                  final active = activeCategories.contains(cat);
                  final count = polygons
                      .where((p) => p.zona.tipo == cat)
                      .length;
                  return _LayerRow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.7),
                    label: cat,
                    count: count,
                    active: active,
                    onToggle: (v) {
                      final next = Set<String>.from(activeCategories);
                      v ? next.add(cat) : next.remove(cat);
                      ref
                          .read(activeZonaCategoriesProvider.notifier)
                          .state = next;
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFiltrosBlock() {
    final danger = ref.watch(dangerFilterProvider);
    final dateRange = ref.watch(dateRangeProvider);

    return _PanelBlock(
      title: 'FILTROS',
      child: Column(
        children: [
          _FilterRow(
            label: 'Nivel de peligro',
            value: danger == 'all' ? 'Todos' : danger,
            items: const [
              ('all', 'Todos'),
              ('drogas', 'Drogas'),
              ('robos', 'Robos'),
              ('vandalismo', 'Vandalismo'),
              ('sin_iluminacion', 'Sin iluminación'),
            ],
            onChanged: (v) =>
                ref.read(dangerFilterProvider.notifier).state = v,
          ),
          const SizedBox(height: 6),
          _FilterRow(
            label: 'Rango de fechas',
            value: _dateLabel(dateRange),
            items: const [
              ('all', 'Todos'),
              ('7', 'Últimos 7 días'),
              ('30', 'Últimos 30 días'),
              ('90', 'Últimos 90 días'),
            ],
            onChanged: (v) =>
                ref.read(dateRangeProvider.notifier).state = v,
          ),
        ],
      ),
    );
  }

  String _dateLabel(String v) {
    const m = {'all': 'Todos', '7': '7 días', '30': '30 días', '90': '90 días'};
    return m[v] ?? v;
  }
}

class _PanelBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  const _PanelBtn({required this.icon, required this.tooltip, this.onTap});

  @override
  State<_PanelBtn> createState() => _PanelBtnState();
}

class _PanelBtnState extends State<_PanelBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _pressed
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, size: 18, color: const Color(0xFFA8A29E)),
          ),
        ),
      ),
    );
  }
}

class _PanelBlock extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Widget child;
  const _PanelBlock({
    required this.title,
    required this.child,
    this.titleColor = const Color(0xFF78716C),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF292524),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: titleColor,
              letterSpacing: 0.06,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF57534E),
              letterSpacing: 0.05),
        ),
      );
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color? bg;
  const _StatChip(
      {required this.label,
      required this.value,
      required this.valueColor,
      this.bg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bg ?? Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                    height: 1)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 9, color: Color(0xFF78716C))),
          ],
        ),
      ),
    );
  }
}

class _SectorBar extends StatelessWidget {
  final String name;
  final int count;
  final int maxCount;
  const _SectorBar(
      {required this.name, required this.count, required this.maxCount});

  @override
  Widget build(BuildContext context) {
    final pct = maxCount > 0 ? count / maxCount : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(
          width: 90,
          child: Text(name,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFFD6D3D1)),
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFF44403C),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFEA580C)),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('$count',
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFB923C))),
      ]),
    );
  }
}

class _LayerRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final bool active;
  final ValueChanged<bool> onToggle;
  final Widget? trailing;
  const _LayerRow({
    required this.color,
    required this.label,
    required this.count,
    required this.active,
    required this.onToggle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFFE7E5E4)),
              overflow: TextOverflow.ellipsis),
        ),
        Text('$count',
            style:
                const TextStyle(fontSize: 10, color: Color(0xFF57534E))),
        const SizedBox(width: 6),
        SizedBox(
          width: 32,
          height: 18,
          child: Switch(
            value: active,
            onChanged: onToggle,
            activeThumbColor: color,
            trackColor: WidgetStateProperty.resolveWith((s) =>
                s.contains(WidgetState.selected)
                    ? color.withValues(alpha: 0.4)
                    : const Color(0xFF44403C)),
            thumbColor: WidgetStateProperty.resolveWith((s) =>
                s.contains(WidgetState.selected)
                    ? Colors.white
                    : const Color(0xFF78716C)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 2), trailing!],
      ]),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String label;
  final String value;
  final List<(String, String)> items;
  final ValueChanged<String> onChanged;
  const _FilterRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFFE7E5E4)))),
      GestureDetector(
        onTapDown: (details) async {
          final RenderBox box =
              context.findRenderObject()! as RenderBox;
          final Offset offset = box.localToGlobal(Offset.zero);
          final result = await showMenu<String>(
            context: context,
            position: RelativeRect.fromLTRB(
              offset.dx + box.size.width - 160,
              offset.dy + box.size.height + 4,
              offset.dx + box.size.width,
              offset.dy + 300,
            ),
            items: items
                .map((i) => PopupMenuItem(value: i.$1, child: Text(i.$2)))
                .toList(),
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            color: const Color(0xFF292524),
          );
          if (result != null) onChanged(result);
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2327),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFFEA580C),
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 3),
            const Icon(Icons.expand_more,
                size: 12, color: Color(0xFF78716C)),
          ]),
        ),
      ),
    ]);
  }
}
