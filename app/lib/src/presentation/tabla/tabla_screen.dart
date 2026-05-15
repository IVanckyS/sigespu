import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../data/seed_data.dart';
import '../map/providers/map_providers.dart';
import '../shared/date_range_popup.dart';

class TablaScreen extends ConsumerStatefulWidget {
  const TablaScreen({super.key});

  @override
  ConsumerState<TablaScreen> createState() => _TablaScreenState();
}

class _TablaScreenState extends ConsumerState<TablaScreen> {
  String _filterCat = 'todos'; // 'todos' | 'zonas' | 'patente' | 'infra' | 'otros'
  String _filterTipo = 'all';
  String _filterSector = 'all';
  String _filterEstado = 'all';
  String _filterBy = 'all';
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  String _search = '';
  String _sortCol = 'fecha';
  bool _sortAsc = false;
  bool _filtersExpanded = false;
  final _datePopupCtrl = DateRangePopupController(LayerLink());

  @override
  void dispose() {
    _datePopupCtrl.dismiss();
    super.dispose();
  }

  List<ElementoMapa> get _filtered {
    final list = kElementosSeed.where((e) {
      // ── filtro de categoría (chips) ──
      if (_filterCat == 'zonas' && e.layerKey != 'zona_peligro') return false;
      if (_filterCat == 'patente' && e.layerKey != 'patente') return false;
      if (_filterCat == 'infra' && !const ['centro_acopio', 'sede_comunitaria', 'infraestructura'].contains(e.layerKey)) return false;
      if (_filterCat == 'otros' && const ['zona_peligro', 'patente', 'centro_acopio', 'sede_comunitaria', 'infraestructura'].contains(e.layerKey)) return false;
      // ── filtros existentes (no tocar) ──
      if (_filterTipo != 'all' && e.layerKey != _filterTipo) return false;
      if (_filterSector != 'all' && e.sector != _filterSector) return false;
      if (_filterEstado != 'all' && e.estado != _filterEstado) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!e.nombre.toLowerCase().contains(q) &&
            !e.direccion.toLowerCase().contains(q) &&
            !(e.rut?.toLowerCase().contains(q) ?? false)) {
          return false;
        }
      }
      if (_filterBy != 'all') {
        final byLower = e.by.toLowerCase();
        bool match = false;
        switch (_filterBy) {
          case 'dir_seg': match = byLower.contains('seguridad pública'); break;
          case 'dideco': match = byLower.contains('dideco'); break;
          case 'scraping': match = byLower.contains('scraping'); break;
          case 'sepulveda': match = byLower.contains('sepúlveda'); break;
          case 'munoz': match = byLower.contains('muñoz'); break;
          case 'castro': match = byLower.contains('castro'); break;
          case 'historico': match = byLower.contains('histórico'); break;
        }
        if (!match) return false;
      }
      if (_filterDateFrom != null || _filterDateTo != null) {
        final d = DateTime.tryParse(e.fecha);
        if (d != null) {
          if (_filterDateFrom != null && d.isBefore(_filterDateFrom!)) return false;
          if (_filterDateTo != null && d.isAfter(_filterDateTo!.add(const Duration(days: 1)))) return false;
        }
      }
      return true;
    }).toList();

    list.sort((a, b) {
      int cmp;
      switch (_sortCol) {
        case 'nombre': cmp = a.nombre.compareTo(b.nombre); break;
        case 'sector': cmp = a.sector.compareTo(b.sector); break;
        case 'direccion': cmp = a.direccion.compareTo(b.direccion); break;
        case 'estado': cmp = a.estado.compareTo(b.estado); break;
        case 'tipo': cmp = a.tipo.compareTo(b.tipo); break;
        default: cmp = a.fecha.compareTo(b.fecha);
      }
      return _sortAsc ? cmp : -cmp;
    });

    return list;
  }

  void _sort(String col) {
    setState(() {
      if (_sortCol == col) {
        _sortAsc = !_sortAsc;
      } else {
        _sortCol = col;
        _sortAsc = false;
      }
    });
    _syncProvider();
  }

  void _syncProvider() {
    ref.read(tablaFilteredProvider.notifier).state = _filtered;
  }

  Widget _buildFilterControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        const _FilterLabel('Tipo'),
        _FilterSelect(
          value: _filterTipo,
          items: const [
            ('all', 'Todos los tipos'),
            ('zona_peligro', 'Zonas de peligro'),
            ('reporte', 'Reportes'),
            ('patente', 'Patentes'),
            ('centro_acopio', 'Centros de acopio'),
            ('sede_comunitaria', 'Sedes comunitarias'),
            ('infraestructura', 'Infraestructura'),
          ],
          onChanged: (v) { setState(() => _filterTipo = v); _syncProvider(); },
        ),
        const _FilterLabel('Sector'),
        _FilterSelect(
          value: _filterSector,
          items: const [
            ('all', 'Todos'),
            ('S-2', 'S-2 · Residencial Los Aromos'),
            ('S-3', 'S-3 · Mixto Los Aromos'),
            ('S-4', 'S-4 · Equipamiento'),
            ('S-5', 'S-5 · Vivienda Periférica'),
            ('Centro', 'Centro Histórico'),
          ],
          onChanged: (v) { setState(() => _filterSector = v); _syncProvider(); },
        ),
        const _FilterLabel('Estado'),
        _FilterSelect(
          value: _filterEstado,
          items: const [
            ('all', 'Todos'),
            ('activo', 'Activo'),
            ('en_revision', 'En revisión'),
            ('cerrado', 'Cerrado'),
          ],
          onChanged: (v) { setState(() => _filterEstado = v); _syncProvider(); },
        ),
        const _FilterLabel('Por'),
        _FilterSelect(
          value: _filterBy,
          items: const [
            ('all', 'Todos'),
            ('dir_seg', 'Dir. Seg. Pública'),
            ('dideco', 'DIDECO'),
            ('scraping', 'Scraping'),
            ('sepulveda', 'R. Sepúlveda'),
            ('munoz', 'C. Muñoz'),
            ('castro', 'P. Castro'),
            ('historico', 'Reg. histórico'),
          ],
          onChanged: (v) { setState(() => _filterBy = v); _syncProvider(); },
        ),
        _FilterDateChip(
          from: _filterDateFrom,
          to: _filterDateTo,
          layerLink: _datePopupCtrl.link,
          onTap: () => _datePopupCtrl.show(
            context,
            initialFrom: _filterDateFrom,
            initialTo: _filterDateTo,
            onApply: (f, t) {
              setState(() { _filterDateFrom = f; _filterDateTo = t; });
              _syncProvider();
            },
          ),
          onClear: () {
            setState(() { _filterDateFrom = null; _filterDateTo = null; });
            _syncProvider();
          },
        ),
        SizedBox(
          width: 220,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, dirección, RUT…',
              hintStyle: const TextStyle(fontSize: 12.5, color: AppTheme.stone400),
              prefixIcon: const Icon(Icons.search, size: 16, color: AppTheme.stone400),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.stone200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.stone200)),
            ),
            style: const TextStyle(fontSize: 12.5),
            onChanged: (v) { setState(() => _search = v); _syncProvider(); },
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ── View banner ──────────────────────────────────────────────────────
        _TablaBanner(total: kElementosSeed.length),
        const SizedBox(height: 16),

        // ── Filtros ──────────────────────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            if (!isMobile) {
              return Column(children: [
                _buildFilterControls(context),
                const SizedBox(height: 10),
              ]);
            }
            return Column(children: [
              GestureDetector(
                onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.stone200),
                  ),
                  child: Row(children: [
                    const Text('FILTROS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF78716C))),
                    const Spacer(),
                    Icon(
                      _filtersExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: const Color(0xFF78716C),
                    ),
                  ]),
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _filtersExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _buildFilterControls(context),
                ),
                secondChild: const SizedBox.shrink(),
              ),
              const SizedBox(height: 10),
            ]);
          },
        ),

        // ── Category chips ────────────────────────────────────────────────────────
        _CategoryChips(
          active: _filterCat,
          onChanged: (cat) {
            setState(() => _filterCat = cat);
            _syncProvider();
          },
        ),
        const SizedBox(height: 8),

        // ── Tabla ────────────────────────────────────────────────────────────
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.stone200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppTheme.stone50),
                    headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.stone600, letterSpacing: 0.05),
                    dataTextStyle: const TextStyle(fontSize: 12.5, color: AppTheme.stone800),
                    columnSpacing: 16,
                    horizontalMargin: 12,
                    dividerThickness: 1,
                    dataRowColor: WidgetStateProperty.resolveWith((states) =>
                        states.contains(WidgetState.hovered) ? AppTheme.orange50 : null),
                    columns: [
                      _sortCol2('tipo', 'Tipo'),
                      _sortCol2('nombre', 'Nombre / Descripción'),
                      _sortCol2('sector', 'Sector'),
                      _sortCol2('direccion', 'Dirección'),
                      _sortCol2('fecha', 'Fecha'),
                      _sortCol2('estado', 'Estado'),
                      const DataColumn(label: Text('Registrado por')),
                    ],
                    rows: filtered.map((e) => _buildRow(e)).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  DataColumn _sortCol2(String col, String label) {
    return DataColumn(
      onSort: (_, __) => _sort(col),
      label: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label),
        const SizedBox(width: 4),
        if (_sortCol == col)
          Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: AppTheme.orange600),
      ]),
    );
  }

  DataRow _buildRow(ElementoMapa e) {
    final tipoColor = colorParaTipo(e.tipo);
    final estadoColor = colorParaEstado(e.estado);
    final estadoBg = bgParaEstado(e.estado);
    final tipoLabel = nombreParaTipo(e.tipo);
    final estadoLabel = _labelEstado(e.estado);

    return DataRow(cells: [
      // Tipo badge
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: tipoColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
        child: Text(tipoLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tipoColor)),
      )),
      // Nombre
      DataCell(SizedBox(
        width: 180,
        child: Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
      )),
      // Sector
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: AppTheme.stone100, borderRadius: BorderRadius.circular(4)),
        child: Text(e.sector, style: const TextStyle(fontSize: 11, color: AppTheme.stone700)),
      )),
      // Dirección
      DataCell(SizedBox(
        width: 160,
        child: Text(e.direccion, style: const TextStyle(color: AppTheme.stone600), overflow: TextOverflow.ellipsis),
      )),
      // Fecha
      DataCell(Text(e.fecha, style: const TextStyle(color: AppTheme.stone500, fontSize: 12))),
      // Estado
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: estadoBg, borderRadius: BorderRadius.circular(10)),
        child: Text(estadoLabel, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: estadoColor)),
      )),
      // Por
      DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: _byColor(e.by),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            _byInitials(e.by),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        const SizedBox(width: 6),
        Text(e.by, style: const TextStyle(color: AppTheme.stone600, fontSize: 11.5)),
      ])),
    ]);
  }

  String _labelEstado(String e) {
    const m = {
      'activo': 'Activo', 'en_revision': 'En revisión',
      'cerrado': 'Cerrado', 'vigente': 'Vigente', 'vencido': 'Vencido',
    };
    return m[e] ?? e;
  }
}

// ── View banner ───────────────────────────────────────────────────────────────

class _TablaBanner extends StatelessWidget {
  final int total;
  const _TablaBanner({required this.total});

  @override
  Widget build(BuildContext context) {
    const seed = kElementosSeed;
    final sectors = seed.map((e) => e.sector).toSet().length;
    final activos = seed.where((e) => e.estado == 'activo').length;
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final estaSemana = seed.where((e) {
      final d = DateTime.tryParse(e.fecha);
      return d != null && d.isAfter(sevenDaysAgo);
    }).length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF292524), Color(0xFF1C1917)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 24,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: 0.12,
                  child: CustomPaint(
                    size: const Size(100, 100),
                    painter: _TableDecoPainter(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.grid_on_outlined, size: 12, color: Color(0x80FFFFFF)),
                    SizedBox(width: 6),
                    Flexible(child: Text(
                      'Vista · Registro de elementos',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0x80FFFFFF), letterSpacing: 0.9),
                      overflow: TextOverflow.ellipsis,
                    )),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'Tabla de datos del sistema',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.44,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Todos los elementos georreferenciados. Filtrable por tipo, sector y estado.',
                    style: TextStyle(fontSize: 12, color: Color(0xBFFFFFFF), height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _TablaStat(value: '$total', label: 'Total registros', valueColor: const Color(0xFFFB923C)),
                      const SizedBox(width: 16),
                      _TablaStat(value: '$sectors', label: 'Sectores'),
                      const SizedBox(width: 16),
                      _TablaStat(value: '$activos', label: 'Activos'),
                      const SizedBox(width: 16),
                      _TablaStat(value: '$estaSemana', label: 'Esta semana'),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TablaStat extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  const _TablaStat({required this.value, required this.label, this.valueColor});

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
            color: valueColor ?? Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xBFFFFFFF))),
      ],
    );
  }
}

class _TableDecoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    final s = size.width / 120;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(5*s,15*s,110*s,10*s), Radius.circular(2*s)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(5*s,33*s,110*s,8*s), Radius.circular(2*s)), Paint()..color = Colors.white.withValues(alpha: 0.6));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(5*s,49*s,110*s,8*s), Radius.circular(2*s)), Paint()..color = Colors.white.withValues(alpha: 0.4));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(5*s,65*s,110*s,8*s), Radius.circular(2*s)), Paint()..color = Colors.white.withValues(alpha: 0.3));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(5*s,81*s,70*s,8*s), Radius.circular(2*s)), Paint()..color = Colors.white.withValues(alpha: 0.2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Helpers de filtro ─────────────────────────────────────────────────────────

class _FilterLabel extends StatelessWidget {
  final String text;
  const _FilterLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.stone600, letterSpacing: 0.05),
  );
}

class _FilterSelect extends StatelessWidget {
  final String value;
  final List<(String, String)> items;
  final ValueChanged<String> onChanged;
  const _FilterSelect({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        underline: const SizedBox.shrink(),
        style: const TextStyle(fontSize: 12.5, color: AppTheme.stone800),
        borderRadius: BorderRadius.circular(8),
        items: items.map((item) {
          final (val, label) = item;
          return DropdownMenuItem(value: val, child: Text(label));
        }).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }
}

// ── CategoryChips ─────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChanged;

  const _CategoryChips({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const seed = kElementosSeed;
    final chips = [
      (id: 'todos',   label: 'Total',           count: seed.length,
        fg: AppTheme.stone600, bg: AppTheme.stone100),
      (id: 'zonas',   label: 'Zonas peligro',   count: seed.where((e) => e.layerKey == 'zona_peligro').length,
        fg: AppTheme.redDanger, bg: const Color(0xFFFEE2E2)),
      (id: 'patente', label: 'Patentes',         count: seed.where((e) => e.layerKey == 'patente').length,
        fg: AppTheme.amberWarning, bg: const Color(0xFFFEF3C7)),
      (id: 'infra',   label: 'Infraestructura',  count: seed.where((e) => const ['centro_acopio','sede_comunitaria','infraestructura'].contains(e.layerKey)).length,
        fg: AppTheme.greenSuccess, bg: const Color(0xFFDCFCE7)),
      (id: 'otros',   label: 'Otros',            count: seed.where((e) => !const ['zona_peligro','patente','centro_acopio','sede_comunitaria','infraestructura'].contains(e.layerKey)).length,
        fg: AppTheme.stone500, bg: AppTheme.stone100),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((c) {
          final isActive = active == c.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(c.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? c.bg : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? c.fg : AppTheme.stone200,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(color: c.fg, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(c.label,
                    style: TextStyle(
                      fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? c.fg : AppTheme.stone600,
                    )),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isActive ? c.fg.withValues(alpha: 0.15) : AppTheme.stone100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${c.count}',
                      style: TextStyle(
                        fontSize: 10.5, fontWeight: FontWeight.w700,
                        color: isActive ? c.fg : AppTheme.stone500,
                      )),
                  ),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Avatar helpers ────────────────────────────────────────────────────────

Color _byColor(String by) {
  const colors = [
    Color(0xFF9A3412), Color(0xFF15803D), Color(0xFF7C3AED),
    Color(0xFFCA8A04), Color(0xFF57534E), Color(0xFFB91C1C),
    Color(0xFF0284C7), Color(0xFF92400E),
  ];
  return colors[by.codeUnits.fold(0, (a, b) => a + b) % colors.length];
}

String _byInitials(String by) {
  final parts = by.trim().split(RegExp(r'[\s.]+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  if (parts[0].length >= 2) return parts[0].substring(0, 2).toUpperCase();
  return parts[0][0].toUpperCase();
}

// ── FilterDateChip ────────────────────────────────────────────────────────────

class _FilterDateChip extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final LayerLink layerLink;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _FilterDateChip({
    required this.from,
    required this.to,
    required this.layerLink,
    required this.onTap,
    required this.onClear,
  });

  String get _label {
    if (from == null && to == null) return 'Fecha';
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final f = from != null ? fmt(from!) : '…';
    final t = to != null ? fmt(to!) : '…';
    return '$f – $t';
  }

  bool get _active => from != null || to != null;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _active ? AppTheme.orange50 : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _active ? AppTheme.orange600 : AppTheme.stone200),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.calendar_today_outlined, size: 13,
                color: _active ? AppTheme.orange600 : AppTheme.stone500),
            const SizedBox(width: 5),
            Text(_label, style: TextStyle(
                fontSize: 12.5,
                color: _active ? AppTheme.orange700 : AppTheme.stone700)),
            if (_active) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 13, color: AppTheme.orange600),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
