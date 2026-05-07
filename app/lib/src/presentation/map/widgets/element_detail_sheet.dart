import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/theme.dart';
import '../../../data/seed_data.dart';
import '../map_screen.dart';

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
    final tipoColor = colorParaTipo(elemento.tipo);
    final tipoLabel = nombreParaTipo(elemento.tipo);
    final estadoColor = colorParaEstado(elemento.estado);
    final estadoBg = bgParaEstado(elemento.estado);

    // Buscar si es una zona dibujada
    final userPolygons = ref.watch(userPolygonsProvider);
    final existingPolygon = userPolygons.cast<({List<LatLng> points, ElementoMapa zona})?>().firstWhere(
      (p) => p?.zona.id == elemento.id,
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
                    child: Text(_labelEstado(elemento.estado),
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
                Text(elemento.nombre,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.stone900)),
                const SizedBox(height: 4),
                Text('${elemento.direccion} · ${elemento.sector}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.stone500)),

                // Campos condicionales
                if (elemento.tipo == 'zona_peligro') ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppTheme.stone100),
                  const SizedBox(height: 12),
                  Row(children: [
                    _InfoChip(
                      label: 'Nivel ${elemento.nivel ?? '?'} · ${_nivelLabel(elemento.nivel)}',
                      bg: AppTheme.redDanger.withValues(alpha: 0.1),
                      fg: AppTheme.redDanger,
                    ),
                    const SizedBox(width: 6),
                    if (elemento.tipoPeligro != null)
                      _InfoChip(
                        label: _tipoPeligroLabel(elemento.tipoPeligro!),
                        bg: AppTheme.stone100,
                        fg: AppTheme.stone700,
                      ),
                  ]),
                  if (elemento.horario != null) ...[
                    const SizedBox(height: 6),
                    Text('Horario crítico: ${elemento.horario}',
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.stone600)),
                  ],
                ],

                if (elemento.rut != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppTheme.stone100),
                  const SizedBox(height: 12),
                  Text('RUT: ${elemento.rut}',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.stone700)),
                  if (elemento.giro != null)
                    Text('Giro: ${elemento.giro}',
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.stone600)),
                ],

                if (elemento.capacidad != null) ...[
                  const SizedBox(height: 8),
                  Text('Capacidad: ${elemento.capacidad} personas',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.stone700)),
                ],

                if (elemento.vigenciaHasta != null) ...[
                  const SizedBox(height: 8),
                  _InfoChip(
                    label: 'Vigencia hasta: ${_formatFecha(elemento.vigenciaHasta!)}',
                    bg: AppTheme.amberWarning.withValues(alpha: 0.1),
                    fg: AppTheme.amberWarning,
                  ),
                ],

                if (elemento.notas.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(elemento.notas,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppTheme.stone600, fontStyle: FontStyle.italic)),
                ],

                const SizedBox(height: 14),
                
                if (existingPolygon != null) ...[
                  const Divider(height: 1, color: AppTheme.stone100),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(isDrawingModeProvider.notifier).state = true;
                        ref.read(drawingPointsProvider.notifier).state = List.from(existingPolygon.points);
                        // Eliminar temporalmente para que el usuario pueda "actualizar"
                        ref.read(userPolygonsProvider.notifier).update(
                          (s) => s.where((p) => p.zona.id != elemento.id).toList()
                        );
                        ref.read(userElementsProvider.notifier).update(
                          (s) => s.where((e) => e.id != elemento.id).toList()
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Re-dibujar zona'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.orange600,
                        side: const BorderSide(color: AppTheme.orange600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const Divider(height: 1, color: AppTheme.stone100),
                const SizedBox(height: 10),

                // Atribución
                Text('Registrado por ${elemento.by} · ${_formatFecha(elemento.fecha)}',
                    style: const TextStyle(fontSize: 11.5, color: AppTheme.stone400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _labelEstado(String e) {
    const m = {'activo': 'Activo', 'en_revision': 'En revisión', 'cerrado': 'Cerrado', 'vigente': 'Vigente', 'vencido': 'Vencido'};
    return m[e] ?? e;
  }

  String _nivelLabel(int? n) {
    const l = ['', 'Muy bajo', 'Bajo', 'Medio', 'Alto', 'Crítico'];
    if (n == null || n < 1 || n > 5) return 'Sin nivel';
    return l[n];
  }

  String _tipoPeligroLabel(String t) {
    const m = {
      'drogas': 'Tráfico drogas', 'robos': 'Robos', 'vivienda_ilegal': 'Vivienda ilegal',
      'vandalismo': 'Vandalismo', 'riña': 'Riñas', 'sin_iluminacion': 'Sin iluminación',
      'accidentes': 'Accidentes', 'microbasural': 'Microbasural', 'otro': 'Otro',
    };
    return m[t] ?? t;
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
