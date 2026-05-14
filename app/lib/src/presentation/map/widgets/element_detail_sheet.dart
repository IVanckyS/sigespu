import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/theme.dart';
import '../../../data/seed_data.dart';
import '../providers/map_providers.dart';
import 'edit_element_sheet.dart';
import '../../../data/sync/sync_provider.dart';

class ElementDetailSheet extends ConsumerWidget {
  final ElementoMapa elemento;
  final bool isPending;

  const ElementDetailSheet({
    super.key,
    required this.elemento,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all elements to reflect live changes (overrides or deletions)
    final allElements = ref.watch(allElementsProvider);
    final el = allElements.firstWhere(
      (e) => e.id == elemento.id, 
      orElse: () => elemento
    );

    // Si el elemento ha sido borrado, cerramos el sheet (caso de borde al borrar)
    final isDeleted = ref.watch(deletedElementIdsProvider).contains(el.id) && 
                      !ref.watch(userElementsProvider).any((e) => e.id == el.id);
    
    if (isDeleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    final tipoColor = colorParaTipo(el.tipo);
    final tipoLabel = nombreParaTipo(el.tipo);
    final estadoColor = colorParaEstado(el.estado);
    final estadoBg = bgParaEstado(el.estado);

    // Buscar si es una zona dibujada
    final userPolygons = ref.watch(userPolygonsProvider);
    final existingPolygon = userPolygons.cast<({List<LatLng> points, ElementoMapa zona})?>().firstWhere(
      (p) => p?.zona.id == el.id,
      orElse: () => null,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.stone300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges de tipo y estado
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tipoColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(tipoLabel,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tipoColor)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: estadoBg, borderRadius: BorderRadius.circular(6)),
                    child: Text(_labelEstado(el.estado, el.tipo),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: estadoColor)),
                  ),
                  if (isPending) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.orange100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Pendiente sync',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.orange700)),
                    ),
                  ],
                ]),
                const SizedBox(height: 10),

                // Nombre
                Text(el.nombre,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.stone900)),
                const SizedBox(height: 4),
                Text('${el.direccion} · ${el.sector}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.stone500)),

                // Campos condicionales
                if (el.tipo == 'zona_peligro') ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppTheme.stone100),
                  const SizedBox(height: 12),
                  Row(children: [
                    _InfoChip(
                      label: 'Riesgo: ${el.nivel ?? '?'}',
                      bg: AppTheme.redDanger.withValues(alpha: 0.1),
                      fg: AppTheme.redDanger,
                    ),
                    const SizedBox(width: 6),
                    if (el.tipoAmenaza != null)
                      _InfoChip(
                        label: el.tipoAmenaza!,
                        bg: AppTheme.stone100,
                        fg: AppTheme.stone700,
                      ),
                  ]),
                ],

                if (el.rut != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppTheme.stone100),
                  const SizedBox(height: 12),
                  Text('RUT: ${el.rut}',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.stone700)),
                  if (el.giro != null)
                    Text('Giro: ${el.giro}',
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.stone600)),
                ],

                if (el.capacidad != null) ...[
                  const SizedBox(height: 8),
                  Text('Capacidad: ${el.capacidad} personas',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.stone700)),
                ],

                if (el.rubro != null) ...[
                  const SizedBox(height: 8),
                  Text('Rubro: ${el.rubro}',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.stone700)),
                ],

                if (el.horario != null) ...[
                  const SizedBox(height: 8),
                  Text('Horario: ${el.horario}',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.stone700)),
                ],

                if (el.vigenciaHasta != null) ...[
                  const SizedBox(height: 8),
                  _InfoChip(
                    label: 'Vigencia hasta: ${_formatFecha(el.vigenciaHasta!)}',
                    bg: AppTheme.amberWarning.withValues(alpha: 0.1),
                    fg: AppTheme.amberWarning,
                  ),
                ],

                if (el.notas.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(el.notas,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppTheme.stone600, fontStyle: FontStyle.italic)),
                ],

                const SizedBox(height: 14),

                const Divider(height: 1, color: AppTheme.stone100),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditForm(context, el),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEstadoPicker(context, ref, el),
                        icon: const Icon(Icons.sync_alt, size: 16),
                        label: const Text('Estado'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _confirmDelete(context, ref, el),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),
                if (existingPolygon != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(isDrawingModeProvider.notifier).state = true;
                        ref.read(drawingPointsProvider.notifier).state = List.from(existingPolygon.points);
                        // Eliminar temporalmente para que el usuario pueda "actualizar"
                        ref.read(userPolygonsProvider.notifier).update(
                          (s) => s.where((p) => p.zona.id != el.id).toList()
                        );
                        ref.read(userElementsProvider.notifier).update(
                          (s) => s.where((e) => e.id != el.id).toList()
                        );
                        // Si era de seed, marcar como borrado
                        ref.read(deletedElementIdsProvider.notifier).update((s) => {...s, el.id});
                      },
                      icon: const Icon(Icons.polyline_outlined, size: 16),
                      label: const Text('Re-dibujar polígono'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.orange600,
                        side: const BorderSide(color: AppTheme.orange600),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                const Divider(height: 1, color: AppTheme.stone100),
                const SizedBox(height: 10),

                // Atribución
                Text('Registrado por ${el.by} · ${_formatFecha(el.fecha)}',
                    style: const TextStyle(fontSize: 11.5, color: AppTheme.stone400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditForm(BuildContext context, ElementoMapa el) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditElementSheet(elemento: el),
    );
  }

  void _showEstadoPicker(BuildContext context, WidgetRef ref, ElementoMapa el) {
    final cat = categoriaParaTipo(el.tipo);
    final isBinary = cat == 'infraestructura' || cat == 'fiscalizacion';

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Cambiar Estado', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Activo'),
              onTap: () => _updateEstado(context, ref, el, 'activo'),
            ),
            if (!isBinary)
              ListTile(
                leading: const Icon(Icons.pending, color: Colors.orange),
                title: const Text('En revisión'),
                onTap: () => _updateEstado(context, ref, el, 'en_revision'),
              ),
            ListTile(
              leading: Icon(isBinary ? Icons.do_disturb_on : Icons.cancel, color: Colors.grey),
              title: Text(isBinary ? 'Inactivo' : 'Cerrado'),
              onTap: () => _updateEstado(context, ref, el, 'cerrado'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateEstado(BuildContext context, WidgetRef ref, ElementoMapa el, String nuevo) {
    ElementoMapa? updated;
    ref.read(userElementsProvider.notifier).update((list) {
      // Si el elemento ya existe en userElements, lo actualizamos
      if (list.any((e) => e.id == el.id)) {
        updated = list.firstWhere((e) => e.id == el.id).copyWith(estado: nuevo);
        return list.map((e) => e.id == el.id ? updated! : e).toList();
      } else {
        // Si no, lo "promovemos" a userElements con el cambio
        updated = el.copyWith(estado: nuevo);
        return [...list, updated!];
      }
    });

    if (updated != null) {
      ref.read(syncServiceProvider).queueForSync(
        entidad: 'punto_interes',
        accion: 'update',
        entidadId: updated!.id,
        payload: {
          'id': updated!.id,
          'tipo': updated!.tipo,
          'nombre': updated!.nombre,
          'direccion': updated!.direccion,
          'lat': updated!.lat,
          'lng': updated!.lng,
          'estado': updated!.estado,
          'descripcion': updated!.notas,
          'metadata': {
            'capacidad': updated!.capacidad,
            'rut': updated!.rut,
            'giro': updated!.giro,
            'tipoPeligro': updated!.tipoPeligro,
            'nivel': updated!.nivel,
            'horario': updated!.horario,
          }
        },
      );
    }

    Navigator.pop(context); // Close picker
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ElementoMapa el) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Elemento'),
        content: Text('¿Está seguro de que desea eliminar "${el.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              // Eliminar de userElements si está ahí
              ref.read(userElementsProvider.notifier).update(
                (list) => list.where((e) => e.id != el.id).toList()
              );
              // Marcar como borrado (para seed data)
              ref.read(deletedElementIdsProvider.notifier).update((s) => {...s, el.id});
              
              ref.read(userPolygonsProvider.notifier).update(
                (list) => list.where((p) => p.zona.id != el.id).toList()
              );

              // Encolar para sync con el backend
              ref.read(syncServiceProvider).queueForSync(
                entidad: 'punto_interes',
                accion: 'delete',
                entidadId: el.id,
                payload: {},
              );

              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close sheet
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  String _labelEstado(String e, String tipo) {
    final cat = categoriaParaTipo(tipo);
    final isBinary = cat == 'infraestructura' || cat == 'fiscalizacion';

    if (isBinary) {
      if (e == 'activo' || e == 'vigente') return 'Activo';
      return 'Inactivo';
    }

    const m = {'activo': 'Activo', 'en_revision': 'En revisión', 'cerrado': 'Cerrado', 'vigente': 'Vigente', 'vencido': 'Vencido'};
    return m[e] ?? e;
  }

  String _nivelLabel(int? n) {
    const l = ['', 'Muy bajo', 'Bajo', 'Medio', 'Alto', 'Crítico'];
    if (n == null || n < 1 || n > 5) return 'Sin nivel';
    return l[n];
  }

  String _formatFecha(String f) {
    final d = DateTime.tryParse(f);
    if (d == null) return f;
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _InfoChip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
  );
}

