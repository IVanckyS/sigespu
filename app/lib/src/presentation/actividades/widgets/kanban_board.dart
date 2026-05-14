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

class KanbanBoard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final filtradas = ref.watch(actividadesFiltadasProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F5F4), Color(0xFFFAFAF9)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _cols.map((col) {
            final items = filtradas.where((a) => a.estado == col.estado).toList();
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: col.estado == EstadoActividad.archivado ? 0 : 12,
                ),
                child: _KanbanColumn(
                  label: col.label,
                  bg: col.bg,
                  accent: col.accent,
                  muted: col.muted,
                  items: items,
                  estado: col.estado,
                  highlightedId: highlightedActividad?.id,
                  onCardTap: onCardTap,
                  onNuevaActividad: () => onNuevaActividad(estado: col.estado),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── KanbanColumn ──────────────────────────────────────────────────────────────

class _KanbanColumn extends ConsumerWidget {
  final String label;
  final Color bg;
  final Color accent;
  final bool muted;
  final List<ActividadMunicipal> items;
  final EstadoActividad estado;
  final String? highlightedId;
  final void Function(ActividadMunicipal) onCardTap;
  final VoidCallback onNuevaActividad;

  const _KanbanColumn({
    required this.label,
    required this.bg,
    required this.accent,
    required this.muted,
    required this.items,
    required this.estado,
    required this.onCardTap,
    required this.onNuevaActividad,
    this.highlightedId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Opacity(
      opacity: muted ? 0.92 : 1.0,
      child: Container(
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
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isDragOver ? accent.withValues(alpha: 0.06) : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      children: [
                        ...items.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Draggable<ActividadMunicipal>(
                            data: a,
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
                        )),

                        // Dashed "add" button
                        _DashedAddBtn(onTap: onNuevaActividad),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
