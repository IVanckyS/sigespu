import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared/shared.dart';

import '../actividades_provider.dart';
import 'actividad_card.dart';

class CoberturaPanel extends ConsumerWidget {
  const CoberturaPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actividades = ref.watch(actividadesProvider);

    final total = actividades.length;
    final completadas =
        actividades.where((a) => a.estado == EstadoActividad.completado).length;
    final enCurso =
        actividades.where((a) => a.estado == EstadoActividad.enCurso).length;
    final planificadas =
        actividades.where((a) => a.estado == EstadoActividad.planificado).length;
    final archivadas =
        actividades.where((a) => a.estado == EstadoActividad.archivado).length;
    final pctCompletadas = total > 0 ? (completadas / total * 100).round() : 0;

    final now = DateTime.now();
    final proximas48h = actividades
        .where((a) =>
            a.estado == EstadoActividad.planificado &&
            a.fechaInicio.isAfter(now) &&
            a.fechaInicio.isBefore(now.add(const Duration(hours: 48))))
        .toList()
      ..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));

    // Top sectores by count
    final sectorCounts = <String, int>{};
    for (final a in actividades) {
      if (a.sector != null) {
        sectorCounts[a.sector!] = (sectorCounts[a.sector!] ?? 0) + 1;
      }
    }
    final topSectores = sectorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxSector = topSectores.isEmpty ? 1 : topSectores.first.value;

    // Count per tipo
    final porTipo = {
      for (final t in TipoActividad.values)
        t: actividades.where((a) => a.tipo == t).length,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.view_kanban_outlined,
                    size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cobertura · Actividades',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1917),
                      ),
                    ),
                    Text(
                      '$total actividades',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF78716C)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stat cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total',
                  value: '$total',
                  bg: const Color(0xFFF5F5F4),
                  fg: const Color(0xFF292524),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Completadas',
                  value: '$pctCompletadas%',
                  bg: const Color(0xFFDCFCE7),
                  fg: const Color(0xFF15803D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Segmented progress bar
          _SegmentedBar(
            segments: [
              (planificadas, const Color(0xFFA8A29E)),
              (enCurso, const Color(0xFFEA580C)),
              (completadas, const Color(0xFF16A34A)),
              (archivadas, const Color(0xFFD6D3D1)),
            ],
            total: total,
          ),
          const SizedBox(height: 5),
          Row(
            children: const [
              _BarLegend('Plan.', Color(0xFFA8A29E)),
              SizedBox(width: 8),
              _BarLegend('En curso', Color(0xFFEA580C)),
              SizedBox(width: 8),
              _BarLegend('Comp.', Color(0xFF16A34A)),
              SizedBox(width: 8),
              _BarLegend('Arch.', Color(0xFFD6D3D1)),
            ],
          ),
          const SizedBox(height: 14),

          // Top sectores
          const _SectionTitle('Top sectores'),
          const SizedBox(height: 8),
          ...topSectores.take(4).toList().asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _SectorBar(
                  sector: entry.value.key,
                  count: entry.value.value,
                  max: maxSector,
                  isTop: entry.key == 0,
                ),
              )),
          const SizedBox(height: 12),

          // Por tipo
          const _SectionTitle('Por tipo'),
          const SizedBox(height: 8),
          ...TipoActividad.values.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(iconoParaTipo(t), size: 13, color: colorParaTipo(t)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        labelParaTipo(t),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF44403C)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                      decoration: BoxDecoration(
                        color: bgParaTipo(t),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${porTipo[t] ?? 0}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: colorParaTipo(t),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 14),

          // Próximas 48h
          if (proximas48h.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                border: Border.all(color: const Color(0xFFFED7AA)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.alarm_outlined,
                          size: 13, color: Color(0xFFC2410C)),
                      const SizedBox(width: 6),
                      Text(
                        'Próximas 48h · ${proximas48h.length}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC2410C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...proximas48h.take(3).map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colorParaTipo(a.tipo),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  a.titulo,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF44403C),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${a.fechaInicio.hour.toString().padLeft(2, '0')}:'
                                '${a.fechaInicio.minute.toString().padLeft(2, '0')}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  color: const Color(0xFFC2410C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF78716C),
        letterSpacing: 0.06,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color fg;

  const _StatCard({
    required this.label,
    required this.value,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: fg),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF78716C)),
          ),
        ],
      ),
    );
  }
}

class _SegmentedBar extends StatelessWidget {
  final List<(int, Color)> segments;
  final int total;

  const _SegmentedBar({required this.segments, required this.total});

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 6,
        child: Row(
          children: segments
              .where((s) => s.$1 > 0)
              .map((s) => Flexible(flex: s.$1, child: Container(color: s.$2)))
              .toList(),
        ),
      ),
    );
  }
}

class _BarLegend extends StatelessWidget {
  final String label;
  final Color color;

  const _BarLegend(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 9.5, color: Color(0xFF78716C))),
      ],
    );
  }
}

class _SectorBar extends StatelessWidget {
  final String sector;
  final int count;
  final int max;
  final bool isTop;

  const _SectorBar({
    required this.sector,
    required this.count,
    required this.max,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? count / max : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 38,
          child: Text(
            sector,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF44403C),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(height: 8, color: const Color(0xFFF5F5F4)),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: isTop
                          ? const LinearGradient(
                              colors: [Color(0xFFEA580C), Color(0xFFD97706)],
                            )
                          : null,
                      color: isTop ? null : const Color(0xFFFCA972),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF44403C),
          ),
        ),
      ],
    );
  }
}
