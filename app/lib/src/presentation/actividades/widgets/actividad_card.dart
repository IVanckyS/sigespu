import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared/shared.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Color colorParaTipo(TipoActividad t) => switch (t) {
      TipoActividad.reunion => const Color(0xFF7C3AED),
      TipoActividad.operativo => const Color(0xFFEA580C),
      TipoActividad.evento => const Color(0xFF16A34A),
      TipoActividad.capacitacion => const Color(0xFF1E3A8A),
    };

Color bgParaTipo(TipoActividad t) => switch (t) {
      TipoActividad.reunion => const Color(0xFFEDE9FE),
      TipoActividad.operativo => const Color(0xFFFFEDD5),
      TipoActividad.evento => const Color(0xFFDCFCE7),
      TipoActividad.capacitacion => const Color(0xFFDBEAFE),
    };

String labelParaTipo(TipoActividad t) => switch (t) {
      TipoActividad.reunion => 'Reunión',
      TipoActividad.operativo => 'Operativo',
      TipoActividad.evento => 'Evento',
      TipoActividad.capacitacion => 'Capacitación',
    };

IconData iconoParaTipo(TipoActividad t) => switch (t) {
      TipoActividad.reunion => Icons.people_outline,
      TipoActividad.operativo => Icons.shield_outlined,
      TipoActividad.evento => Icons.calendar_today_outlined,
      TipoActividad.capacitacion => Icons.school_outlined,
    };

String _fmtDate(DateTime d) {
  const meses = [
    '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  final hora = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  return '${d.day} ${meses[d.month]} · $hora';
}

int _acuerdosVencidos(ActividadMunicipal a) {
  final acuerdos = a.acta?.acuerdos ?? [];
  final now = DateTime.now();
  return acuerdos.where((ac) => !ac.completado && ac.fechaLimite.isBefore(now)).length;
}

// ── ActividadCard ─────────────────────────────────────────────────────────────

class ActividadCard extends StatelessWidget {
  final ActividadMunicipal actividad;
  final bool highlighted;
  final bool muted;
  final VoidCallback onTap;

  const ActividadCard({
    super.key,
    required this.actividad,
    required this.onTap,
    this.highlighted = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = actividad;
    final tipo = a.tipo;
    final color = colorParaTipo(tipo);
    final bg = bgParaTipo(tipo);
    final vencidos = _acuerdosVencidos(a);
    final sinUbicacion = a.direccion == null || a.direccion == 'Sin ubicación';

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: muted ? 0.72 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: highlighted ? const Color(0xFFEA580C) : const Color(0xFFE7E5E4),
              width: highlighted ? 1.5 : 1,
            ),
            boxShadow: [
              if (highlighted)
                const BoxShadow(color: Color(0xFFFFEDD5), blurRadius: 0, spreadRadius: 3),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: type chip + sector
                  Row(
                    children: [
                      _TypeChip(label: labelParaTipo(tipo), color: color, bg: bg, icon: iconoParaTipo(tipo)),
                      const Spacer(),
                      if (a.sector != null)
                        _SectorChip(a.sector!),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    a.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1917),
                      height: 1.32,
                      letterSpacing: -0.05,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date + participants
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 11.5, color: Color(0xFF78716C)),
                      const SizedBox(width: 4),
                      Text(
                        _fmtDate(a.fechaInicio),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10.5,
                          color: const Color(0xFF57534E),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('·', style: TextStyle(color: Color(0xFFD6D3D1))),
                      const SizedBox(width: 6),
                      const Icon(Icons.people_outline, size: 11.5, color: Color(0xFF78716C)),
                      const SizedBox(width: 4),
                      Text(
                        '${a.acta?.asistentes.length ?? a.participanteIds.length} part.',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF57534E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 11.5,
                        color: sinUbicacion ? const Color(0xFFA8A29E) : const Color(0xFF78716C),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          a.direccion ?? 'Sin ubicación',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: sinUbicacion ? const Color(0xFFA8A29E) : const Color(0xFF57534E),
                            fontStyle: sinUbicacion ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Acuerdos vencidos badge
                  if (vencidos > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_outlined, size: 11, color: Color(0xFFC2410C)),
                          const SizedBox(width: 5),
                          Text(
                            '$vencidos acuerdo${vencidos > 1 ? "s" : ""} vencido${vencidos > 1 ? "s" : ""}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC2410C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Grip handle (top-right)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.drag_indicator, size: 14, color: Color(0xFFD6D3D1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;

  const _TypeChip({required this.label, required this.color, required this.bg, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 2, 7, 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.01),
          ),
        ],
      ),
    );
  }
}

class _SectorChip extends StatelessWidget {
  final String sector;
  const _SectorChip(this.sector);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE7E5E4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        sector,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF44403C),
        ),
      ),
    );
  }
}
