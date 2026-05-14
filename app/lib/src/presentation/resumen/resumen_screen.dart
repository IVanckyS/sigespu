import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../data/seed_data.dart';

class ResumenScreen extends StatelessWidget {
  const ResumenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final fechaStr =
        '${now.day.toString().padLeft(2, '0')} de ${_mes(now.month)} de ${now.year}, '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // KPIs calculados desde seed
    final reportes = kElementosSeed.where((e) => e.tipo.startsWith('reporte_')).length;
    final zonas = kElementosSeed.where((e) => e.tipo == 'zona_peligro').length;
    final patentes = kPatentes.length; // total en BD de scraping
    final acopios = kElementosSeed.where((e) => e.tipo == 'centro_acopio').length;
    final sedes = kElementosSeed.where((e) => e.tipo == 'sede_comunitaria').length;

    // Reportes por tipo para gráfico (últimos 30 días)
    final limite30 = now.subtract(const Duration(days: 30));
    bool enUltimos30(ElementoMapa e) {
      final d = DateTime.tryParse(e.fecha);
      return d != null && d.isAfter(limite30);
    }
    final reportesPorTipo = <String, int>{
      'Robo':       kElementosSeed.where((e) => e.tipo == 'reporte_robo'       && enUltimos30(e)).length,
      'Vandalismo': kElementosSeed.where((e) => e.tipo == 'reporte_vandalismo' && enUltimos30(e)).length,
      'Accidente':  kElementosSeed.where((e) => e.tipo == 'reporte_accidente'  && enUltimos30(e)).length,
    };

    // Tendencia semanal (últimas 8 semanas)
    final weeklyData = _weeklyReportCounts(now);

    // Últimos reportes (ordenados por fecha desc)
    final ultimos = kElementosSeed
        .where((e) => e.tipo.startsWith('reporte_'))
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── View banner ──────────────────────────────────────────────────
          _ResumenBanner(
            reportes: reportes,
            zonas: zonas,
            patentes: patentes,
            acopios: acopios,
            fechaStr: fechaStr,
          ),
          const SizedBox(height: 20),

          // ── KPI grid ─────────────────────────────────────────────────────
          _KpiGrid(reportes: reportes, zonas: zonas, patentes: patentes, acopios: acopios, sedes: sedes),
          const SizedBox(height: 12),

          // ── Row 1: Doughnut chart + Sector list ───────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              final card1 = _DashCard(
                title: 'Reportes por tipo',
                subtitle: 'últimos 30 días',
                child: SizedBox(height: 220, child: _DoughnutChartTipos(data: reportesPorTipo)),
              );
              final card2 = _DashCard(
                title: 'Zonas por sector',
                subtitle: 'Plan Regulador',
                child: _SectorList(),
              );
              if (isMobile) {
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  card1,
                  const SizedBox(height: 12),
                  card2,
                ]);
              }
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 2, child: card1),
                const SizedBox(width: 12),
                Expanded(child: card2),
              ]);
            },
          ),
          const SizedBox(height: 12),

          // ── Row 2: Line chart + Recent list ─────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              final card1 = _DashCard(
                title: 'Tendencia semanal',
                subtitle: 'reportes por semana',
                child: SizedBox(height: 220, child: _LineChartTendencia(data: weeklyData)),
              );
              final card2 = _DashCard(
                title: 'Últimos reportes',
                subtitle: 'orden cronológico',
                child: _RecentList(items: ultimos.take(5).toList()),
              );
              if (isMobile) {
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  card1,
                  const SizedBox(height: 12),
                  card2,
                ]);
              }
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: card1),
                const SizedBox(width: 12),
                Expanded(child: card2),
              ]);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _mes(int m) => const [
    '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ][m];

  /// Conteo de reportes por semana para las últimas 8 semanas (más reciente al final).
  static List<int> _weeklyReportCounts(DateTime ref) {
    return List.generate(8, (i) {
      // i=0 es la semana más antigua (7 semanas atrás), i=7 la más reciente
      final daysAgo = (7 - i) * 7;
      final weekStart = DateTime(
        ref.subtract(Duration(days: daysAgo + 6)).year,
        ref.subtract(Duration(days: daysAgo + 6)).month,
        ref.subtract(Duration(days: daysAgo + 6)).day,
      );
      final weekEnd = DateTime(
        ref.subtract(Duration(days: daysAgo)).year,
        ref.subtract(Duration(days: daysAgo)).month,
        ref.subtract(Duration(days: daysAgo)).day,
        23, 59, 59,
      );
      return kElementosSeed.where((e) {
        if (!e.tipo.startsWith('reporte_')) return false;
        final d = DateTime.tryParse(e.fecha);
        if (d == null) return false;
        return !d.isBefore(weekStart) && !d.isAfter(weekEnd);
      }).length;
    });
  }
}

// ── View banner ───────────────────────────────────────────────────────────────

class _ResumenBanner extends StatelessWidget {
  final int reportes, zonas, patentes, acopios;
  final String fechaStr;
  const _ResumenBanner({
    required this.reportes,
    required this.zonas,
    required this.patentes,
    required this.acopios,
    required this.fechaStr,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFC2410C), Color(0xFFEA580C), Color(0xFFFB923C)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative dashboard SVG (low opacity)
            Positioned(
              right: 24,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: 0.12,
                  child: CustomPaint(
                    size: const Size(100, 100),
                    painter: _DashboardDecoPainter(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 140, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.dashboard_outlined, size: 12, color: Colors.white70),
                    const SizedBox(width: 6),
                    const Text(
                      'Vista · Resumen operativo',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 0.09 * 10,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'Dirección de Seguridad Pública',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEAEAEA),
                      letterSpacing: -0.44,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Indicadores clave y últimos registros · Actualizado: $fechaStr',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    _VStat(value: '$reportes', label: 'Reportes'),
                    const SizedBox(width: 16),
                    _VStat(value: '$zonas', label: 'Zonas activas'),
                    const SizedBox(width: 16),
                    _VStat(value: '$patentes', label: 'Patentes (mes)'),
                    const SizedBox(width: 16),
                    _VStat(value: '$acopios', label: 'Centros acopio'),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VStat extends StatelessWidget {
  final String value;
  final String label;
  const _VStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFEAEAEA),
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }
}

class _DashboardDecoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    final s = size.width / 120;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(10*s,10*s,45*s,55*s), Radius.circular(4*s)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(65*s,10*s,45*s,35*s), Radius.circular(4*s)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(65*s,55*s,45*s,55*s), Radius.circular(4*s)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(10*s,75*s,45*s,35*s), Radius.circular(4*s)), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── KPI grid ──────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final int reportes, zonas, patentes, acopios, sedes;
  const _KpiGrid({required this.reportes, required this.zonas, required this.patentes, required this.acopios, required this.sedes});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiCard(label: 'Reportes este mes', value: '$reportes', accent: AppTheme.orange600,
          icon: Icons.location_on_outlined, trend: '+12% vs mes anterior', trendUp: false),
      _KpiCard(label: 'Zonas de peligro activas', value: '$zonas', accent: AppTheme.redDanger,
          icon: Icons.warning_amber_outlined, trend: '3 nuevas esta semana', trendUp: false),
      _KpiCard(label: 'Patentes nuevas (mes)', value: '$patentes', accent: AppTheme.amberWarning,
          icon: Icons.store_outlined, trend: 'scraping · hace 3h', trendUp: true),
      _KpiCard(label: 'Centros de acopio', value: '$acopios', accent: AppTheme.blue800,
          icon: Icons.home_outlined, trend: 'Listos para emergencias', trendUp: true),
      _KpiCard(label: 'Sedes comunitarias', value: '$sedes', accent: AppTheme.greenSuccess,
          icon: Icons.people_outline, trend: 'Activas e identificadas', trendUp: true),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return Column(children: cards);
        }
        return Row(children: cards.map((c) => Expanded(child: c)).toList());
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;
  final String trend;
  final bool trendUp;

  const _KpiCard({required this.label, required this.value, required this.accent, required this.icon, required this.trend, required this.trendUp});

  @override
  Widget build(BuildContext context) {
    final bgIcon = accent.withValues(alpha: 0.08);
    final trendColor = trendUp ? AppTheme.greenSuccess : AppTheme.redDanger;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: Stack(children: [
        // Acento top
        Positioned(top: -20, left: -20, right: -20, child: Container(
          height: 3,
          decoration: BoxDecoration(color: accent, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: bgIcon, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: accent),
            ),
          ]),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.stone500, letterSpacing: 0.06)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.stone900, letterSpacing: -0.03, height: 1.1)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(trendUp ? Icons.trending_up : Icons.trending_down, size: 12, color: trendColor),
            const SizedBox(width: 4),
            Flexible(child: Text(trend, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: trendColor))),
          ]),
        ]),
      ]),
    );
  }
}

// ── Dashboard card wrapper ─────────────────────────────────────────────────────

class _DashCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _DashCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.stone900)),
          const Spacer(),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.stone500, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

// ── Doughnut chart: reportes por tipo ────────────────────────────────────────

class _DoughnutChartTipos extends StatelessWidget {
  final Map<String, int> data;
  const _DoughnutChartTipos({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final colors = [
      AppTheme.redDanger,
      const Color(0xFFA855F7),
      AppTheme.orange600
    ];
    final total = data.values.fold(0, (a, b) => a + b);

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: List.generate(entries.length, (i) {
                final value = entries[i].value.toDouble();
                final percentage = total > 0
                    ? (value / total * 100).toStringAsFixed(0)
                    : '0';
                return PieChartSectionData(
                  color: colors[i % colors.length],
                  value: value,
                  title: '$percentage%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Leyenda
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(entries.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entries[i].key}: ${entries[i].value}',
                    style:
                        const TextStyle(fontSize: 11, color: AppTheme.stone600),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Line chart: tendencia semanal ─────────────────────────────────────────────

class _LineChartTendencia extends StatelessWidget {
  final List<int> data;
  const _LineChartTendencia({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold(0, (a, b) => a > b ? a : b);
    final maxY = (maxVal + 1).toDouble().clamp(4.0, double.infinity);
    final spots = List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i].toDouble()));
    // Etiquetas: S1…S8 (S8 = semana más reciente)
    final days = List.generate(data.length, (i) => 'S${i + 1}');

    return LineChart(LineChartData(
      minY: 0, maxY: maxY,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
            '${s.y.toInt()} reportes',
            const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          )).toList(),
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= days.length) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(days[i], style: const TextStyle(fontSize: 11, color: AppTheme.stone500)),
            );
          },
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (v, _) => Text(
            v.toInt().toString(),
            style: const TextStyle(fontSize: 10, color: AppTheme.stone400),
          ),
        )),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.stone100, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [LineChartBarData(
        spots: spots,
        isCurved: true,
        color: AppTheme.orange600,
        barWidth: 2.5,
        dotData: FlDotData(getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
          radius: 4,
          color: Colors.white,
          strokeWidth: 2,
          strokeColor: AppTheme.orange600,
        )),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.orange600.withValues(alpha: 0.15), AppTheme.orange600.withValues(alpha: 0)],
          ),
        ),
      )],
    ));
  }
}

// ── Sector list ───────────────────────────────────────────────────────────────

class _SectorList extends StatelessWidget {
  static const _sectores = [
    ('S-2', 'Residencial Los Aromos', Color(0xFF86EFAC), '2 zonas · 3 reportes'),
    ('S-3', 'Mixto Los Aromos', Color(0xFFFDE68A), '1 zona · 2 reportes'),
    ('S-4', 'Equipamiento', Color(0xFFBFDBFE), '0 zonas · 0 reportes'),
    ('S-5', 'Vivienda Periférica', Color(0xFFC7D2FE), '2 zonas · 1 reporte'),
    ('Centro', 'Centro Histórico Lota', Color(0xFFFED7AA), '2 zonas · 5 reportes'),
  ];

  static const _barsMax = [3, 2, 0, 2, 5];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_sectores.length, (i) {
        final (code, name, color, stats) = _sectores[i];
        final fraction = _barsMax[4] > 0 ? _barsMax[i] / _barsMax[4] : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.stone50, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                child: Text(code, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.stone900)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.stone800)),
                Text(stats, style: const TextStyle(fontSize: 10.5, color: AppTheme.stone500)),
              ])),
              const SizedBox(width: 8),
              SizedBox(
                width: 60, height: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: fraction.toDouble(),
                    backgroundColor: AppTheme.stone200,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.orange600),
                  ),
                ),
              ),
            ]),
          ),
        );
      }),
    );
  }
}

// ── Recent list ───────────────────────────────────────────────────────────────

class _RecentList extends StatelessWidget {
  final List<ElementoMapa> items;
  const _RecentList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items.map((e) {
        final color = colorParaTipo(e.tipo);
        final nombre = nombreParaTipo(e.tipo);
        final bgTag = color.withValues(alpha: 0.1);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.stone100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.warning_amber_outlined, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.nombre, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.stone900), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(children: [
                  Text(e.fecha, style: const TextStyle(fontSize: 10.5, color: AppTheme.stone500)),
                  const SizedBox(width: 8),
                  Text(e.by, style: const TextStyle(fontSize: 10.5, color: AppTheme.stone500)),
                ]),
              ])),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: bgTag, borderRadius: BorderRadius.circular(8)),
                child: Text(nombre, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.04)),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }
}
