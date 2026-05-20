import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../actividades_provider.dart';
import 'actividad_card.dart';

// ── Column config ─────────────────────────────────────────────────────────────

const _cols = [
  (
    estado: EstadoActividad.planificado,
    label: 'Planificado',
    bg: Color(0xFFF5F5F4),
    accent: Color(0xFFA8A29E),
    muted: false,
  ),
  (
    estado: EstadoActividad.enCurso,
    label: 'En curso',
    bg: Color(0xFFFFF7ED),
    accent: Color(0xFFEA580C),
    muted: false,
  ),
  (
    estado: EstadoActividad.completado,
    label: 'Completado',
    bg: Color(0xFFF0FDF4),
    accent: Color(0xFF16A34A),
    muted: false,
  ),
  (
    estado: EstadoActividad.archivado,
    label: 'Archivado',
    bg: Color(0xFFFAFAF9),
    accent: Color(0xFFA8A29E),
    muted: true,
  ),
];

// ── KanbanBoard ───────────────────────────────────────────────────────────────

class KanbanBoard extends ConsumerStatefulWidget {
  final ActividadMunicipal? highlightedActividad;
  final void Function(ActividadMunicipal) onCardTap;
  final void Function({EstadoActividad? estado}) onNuevaActividad;

  const KanbanBoard({
    super.key,
    required this.onCardTap,
    required this.onNuevaActividad,
    this.highlightedActividad,
  });

  @override
  ConsumerState<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends ConsumerState<KanbanBoard> {
  int _activeColIndex = 1; // En curso por defecto

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F5F4), Color(0xFFFAFAF9)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          if (isMobile) {
            return _MobileKanbanView(
              activeIndex: _activeColIndex,
              onTabChange: (i) => setState(() => _activeColIndex = i),
              highlightedId: widget.highlightedActividad?.id,
              onCardTap: widget.onCardTap,
              onNuevaActividad: widget.onNuevaActividad,
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _cols.map((col) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: col.estado == EstadoActividad.archivado ? 0 : 12,
                    ),
                    child: _KanbanColumn(
                      key: ValueKey('kcol_${col.estado.name}'),
                      label: col.label,
                      bg: col.bg,
                      accent: col.accent,
                      muted: col.muted,
                      estado: col.estado,
                      highlightedId: widget.highlightedActividad?.id,
                      onCardTap: widget.onCardTap,
                      onNuevaActividad: () =>
                          widget.onNuevaActividad(estado: col.estado),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

// ── Mobile kanban view ────────────────────────────────────────────────────────

class _MobileKanbanView extends ConsumerWidget {
  final int activeIndex;
  final ValueChanged<int> onTabChange;
  final String? highlightedId;
  final void Function(ActividadMunicipal) onCardTap;
  final void Function({EstadoActividad? estado}) onNuevaActividad;

  const _MobileKanbanView({
    required this.activeIndex,
    required this.onTabChange,
    required this.highlightedId,
    required this.onCardTap,
    required this.onNuevaActividad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final col = _cols[activeIndex];
    final items = ref.watch(actividadesFiltradasPorEstadoProvider(col.estado));
    final counts = _cols
        .map((c) =>
            ref.watch(actividadesFiltradasPorEstadoProvider(c.estado)).length)
        .toList();

    return Column(
      children: [
        // ── Tab bar ──────────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: List.generate(_cols.length, (i) {
                  final c = _cols[i];
                  final active = i == activeIndex;
                  return GestureDetector(
                    onTap: () => onTabChange(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: active ? c.accent : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          c.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            color: active
                                ? c.accent
                                : const Color(0xFF78716C),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: active
                                ? c.accent.withValues(alpha: 0.12)
                                : const Color(0xFFF5F5F4),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${counts[i]}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? c.accent
                                  : const Color(0xFF78716C),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  );
                }),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0x14000000)),
          ]),
        ),

        // ── Cards list ───────────────────────────────────────────────────────
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.inbox_outlined,
                        size: 40, color: Color(0xFFD6D3D1)),
                    const SizedBox(height: 12),
                    Text(
                      'Sin actividades en ${col.label.toLowerCase()}',
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF78716C)),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => onNuevaActividad(estado: col.estado),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: col.accent),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Agregar actividad',
                          style: TextStyle(
                            fontSize: 13,
                            color: col.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: items.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == items.length) {
                      return _DashedAddBtn(
                        onTap: () => onNuevaActividad(estado: col.estado),
                      );
                    }
                    final a = items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ActividadCard(
                        actividad: a,
                        highlighted: highlightedId == a.id,
                        muted: col.muted,
                        onTap: () => onCardTap(a),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── KanbanColumn ──────────────────────────────────────────────────────────────

class _KanbanColumn extends ConsumerWidget {
  final String label;
  final Color bg;
  final Color accent;
  final bool muted;
  final EstadoActividad estado;
  final String? highlightedId;
  final void Function(ActividadMunicipal) onCardTap;
  final VoidCallback onNuevaActividad;

  const _KanbanColumn({
    super.key,
    required this.label,
    required this.bg,
    required this.accent,
    required this.muted,
    required this.estado,
    required this.onCardTap,
    required this.onNuevaActividad,
    this.highlightedId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(actividadesFiltradasPorEstadoProvider(estado));
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E5E4)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              border: Border(left: BorderSide(color: accent, width: 3)),
            ),
            child: Row(
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF292524),
                    letterSpacing: 0.06,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE7E5E4)),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF57534E),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const Spacer(),
                _IconBtn(Icons.add, onTap: onNuevaActividad),
                const SizedBox(width: 2),
                if (estado == EstadoActividad.archivado && items.isNotEmpty)
                  _IconBtn(
                    Icons.delete_sweep_outlined,
                    onTap: () => _confirmarLimpiarArchivados(context, ref, items.length),
                  )
                else
                  _IconBtn(Icons.more_horiz, onTap: () {}),
              ],
            ),
          ),

          // Cards
          Expanded(
            child: DragTarget<ActividadMunicipal>(
              onAcceptWithDetails: (details) {
                final estadoLabel = switch (estado) {
                  EstadoActividad.planificado => 'Planificado',
                  EstadoActividad.enCurso => 'En curso',
                  EstadoActividad.completado => 'Completado',
                  EstadoActividad.archivado => 'Archivado',
                };
                ref.read(actividadesProvider.notifier).updateEstado(
                  details.data.id,
                  estado,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${details.data.titulo.length > 40 ? '${details.data.titulo.substring(0, 40)}…' : details.data.titulo} → $estadoLabel · por director@lota.cl',
                    ),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onWillAcceptWithDetails: (details) => details.data.estado != estado,
              builder: (context, candidateData, rejectedData) {
                final isDragOver = candidateData.isNotEmpty;
                return _ColumnList(
                  items: items,
                  isDragOver: isDragOver,
                  accent: accent,
                  muted: muted,
                  highlightedId: highlightedId,
                  onCardTap: onCardTap,
                  onNuevaActividad: onNuevaActividad,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Aísla el repintado del fondo "drag-over" del rebuild de los items —
// solo el AnimatedContainer reacciona a candidateData; ListView.builder
// recicla las tarjetas y no se reconstruye al cambiar el hover state.
class _ColumnList extends StatelessWidget {
  final List<ActividadMunicipal> items;
  final bool isDragOver;
  final Color accent;
  final bool muted;
  final String? highlightedId;
  final void Function(ActividadMunicipal) onCardTap;
  final VoidCallback onNuevaActividad;

  const _ColumnList({
    required this.items,
    required this.isDragOver,
    required this.accent,
    required this.muted,
    required this.highlightedId,
    required this.onCardTap,
    required this.onNuevaActividad,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isDragOver ? accent.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        itemCount: items.length + 1,
        itemBuilder: (ctx, i) {
          if (i == items.length) {
            return _DashedAddBtn(onTap: onNuevaActividad);
          }
          final a = items[i];
          return Padding(
            key: ValueKey('actcard_${a.id}'),
            padding: const EdgeInsets.only(bottom: 8),
            child: Draggable<ActividadMunicipal>(
              data: a,
              dragAnchorStrategy: pointerDragAnchorStrategy,
              feedback: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: 260,
                  child: ActividadCard(
                    actividad: a,
                    onTap: () {},
                    highlighted: true,
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.35,
                child: ActividadCard(
                  actividad: a,
                  onTap: () {},
                ),
              ),
              child: ActividadCard(
                actividad: a,
                highlighted: highlightedId == a.id,
                muted: muted,
                onTap: () => onCardTap(a),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Pequeños helpers ──────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn(this.icon, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 14, color: const Color(0xFF78716C)),
      ),
    );
  }
}

class _DashedAddBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _DashedAddBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD6D3D1), style: BorderStyle.solid, width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 13, color: Color(0xFF78716C)),
            SizedBox(width: 6),
            Text(
              'Agregar actividad',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Color(0xFF78716C)),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmarLimpiarArchivados(
    BuildContext context, WidgetRef ref, int count) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dlg) => AlertDialog(
      title: const Text('Limpiar archivados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Text(
        'Se eliminarán $count actividad${count == 1 ? '' : 'es'} archivada${count == 1 ? '' : 's'} permanentemente.\n\nEsta acción no se puede deshacer.',
        style: const TextStyle(fontSize: 13, color: Color(0xFF44403C)),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dlg, false),
            child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () => Navigator.pop(dlg, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB91C1C),
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('Eliminar $count'),
        ),
      ],
    ),
  );
  if (confirm == true) {
    ref.read(actividadesProvider.notifier).clearArchivados();
  }
}
