import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared/shared.dart';

import '../actividades_provider.dart';
import 'tab_acta.dart';
import 'tab_datos.dart';
import 'tab_ubicacion.dart';

class ActividadBottomSheet extends ConsumerStatefulWidget {
  final ActividadMunicipal actividad;
  final VoidCallback onClose;

  const ActividadBottomSheet({
    super.key,
    required this.actividad,
    required this.onClose,
  });

  @override
  ConsumerState<ActividadBottomSheet> createState() => _ActividadBottomSheetState();
}

class _ActividadBottomSheetState extends ConsumerState<ActividadBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmarEliminar(
      BuildContext ctx, WidgetRef ref, ActividadMunicipal a) async {
    final titulo = a.titulo.length > 60
        ? '${a.titulo.substring(0, 60)}…'
        : a.titulo;
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dlg) => AlertDialog(
        title: const Text('Eliminar actividad',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          '¿Eliminar "$titulo"?\n\nEsta acción no se puede deshacer.',
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(actividadesProvider.notifier).delete(a.id);
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa el provider para reflejar cambios en vivo (GPS, estado, etc.)
    final actividades = ref.watch(actividadesProvider);
    final a = actividades.firstWhere(
      (e) => e.id == widget.actividad.id,
      orElse: () => widget.actividad,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x28000000), blurRadius: 24, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb + action buttons row
                Row(
                  children: [
                    const Icon(Icons.view_kanban_outlined,
                        size: 14, color: Color(0xFF78716C)),
                    const SizedBox(width: 6),
                    const Text(
                      'Detalle',
                      style: TextStyle(fontSize: 12, color: Color(0xFF78716C)),
                    ),
                    const SizedBox(width: 6),
                    const Text('·', style: TextStyle(color: Color(0xFFD6D3D1))),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDD5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        a.id,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10.5,
                          color: const Color(0xFFC2410C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: _HeaderBtn(
                        label: 'Mover a · ${_nextEstadoLabel(a.estado)}',
                        icon: Icons.arrow_forward_outlined,
                        onTap: () {
                          ref.read(actividadesProvider.notifier)
                              .updateEstado(a.id, _nextEstado(a.estado));
                          widget.onClose();
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    _HeaderBtn(
                      label: a.estado == EstadoActividad.archivado
                          ? 'Desarchivar'
                          : 'Archivar',
                      icon: a.estado == EstadoActividad.archivado
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                      onTap: () {
                        final next = a.estado == EstadoActividad.archivado
                            ? EstadoActividad.planificado
                            : EstadoActividad.archivado;
                        ref.read(actividadesProvider.notifier)
                            .updateEstado(a.id, next);
                        widget.onClose();
                      },
                    ),
                    const SizedBox(width: 6),
                    _HeaderBtn(
                      label: '',
                      icon: Icons.delete_outline,
                      danger: true,
                      onTap: () => _confirmarEliminar(context, ref, a),
                    ),
                    const SizedBox(width: 6),
                    _HeaderBtn(
                      label: '',
                      icon: Icons.share_outlined,
                      onTap: () {
                        final tipo = switch (a.tipo) {
                          TipoActividad.reunion => 'Reunión',
                          TipoActividad.operativo => 'Operativo',
                          TipoActividad.evento => 'Evento',
                          TipoActividad.capacitacion => 'Capacitación',
                        };
                        final estado = switch (a.estado) {
                          EstadoActividad.planificado => 'Planificado',
                          EstadoActividad.enCurso => 'En curso',
                          EstadoActividad.completado => 'Completado',
                          EstadoActividad.archivado => 'Archivado',
                        };
                        final fecha =
                            '${a.fechaInicio.day.toString().padLeft(2, '0')}/${a.fechaInicio.month.toString().padLeft(2, '0')}/${a.fechaInicio.year}';
                        final lines = [
                          '📋 ${a.titulo}',
                          'Tipo: $tipo · Estado: $estado',
                          'Fecha: $fecha',
                          if (a.sector != null) 'Sector: ${a.sector}',
                          if (a.direccion != null) 'Dirección: ${a.direccion}',
                          'ID: ${a.id}',
                          '— SIGESPU Lota · Dirección de Seguridad Pública',
                        ];
                        Clipboard.setData(
                            ClipboardData(text: lines.join('\n')));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Resumen copiado al portapapeles'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.close,
                            size: 15, color: Color(0xFF57534E)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  a.titulo,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1917),
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tab bar
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE7E5E4))),
            ),
            child: TabBar(
              controller: _tabCtrl,
              tabs: const [
                Tab(text: 'Datos generales'),
                Tab(text: 'Acta'),
                Tab(text: 'Ubicación'),
              ],
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              labelColor: const Color(0xFFEA580C),
              unselectedLabelColor: const Color(0xFF78716C),
              indicatorColor: const Color(0xFFEA580C),
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.tab,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              dividerColor: Colors.transparent,
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                TabDatos(actividad: a),
                TabActa(actividad: a),
                TabUbicacion(actividad: a),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _nextEstadoLabel(EstadoActividad e) => switch (e) {
      EstadoActividad.planificado => 'En curso',
      EstadoActividad.enCurso => 'Completado',
      EstadoActividad.completado => 'Archivado',
      EstadoActividad.archivado => 'Planificado',
    };

EstadoActividad _nextEstado(EstadoActividad e) => switch (e) {
      EstadoActividad.planificado => EstadoActividad.enCurso,
      EstadoActividad.enCurso => EstadoActividad.completado,
      EstadoActividad.completado => EstadoActividad.archivado,
      EstadoActividad.archivado => EstadoActividad.planificado,
    };

class _HeaderBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  const _HeaderBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: label.isEmpty ? 6 : 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: danger ? const Color(0xFFFEF2F2) : null,
          border: Border.all(
            color: danger ? const Color(0xFFFCA5A5) : const Color(0xFFE7E5E4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label.isNotEmpty) ...[
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: danger
                      ? const Color(0xFFB91C1C)
                      : const Color(0xFF44403C),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(icon,
                size: 13,
                color: danger
                    ? const Color(0xFFB91C1C)
                    : const Color(0xFF78716C)),
          ],
        ),
      ),
    );
  }
}
