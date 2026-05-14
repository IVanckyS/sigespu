import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../data/seed_data.dart';
import '../map/providers/map_providers.dart';

class TablaScreen extends ConsumerStatefulWidget {
  const TablaScreen({super.key});

  @override
  ConsumerState<TablaScreen> createState() => _TablaScreenState();
}

class _TablaScreenState extends ConsumerState<TablaScreen> {
  String _filterTipo = 'all';
  String _filterSector = 'all';
  String _filterEstado = 'all';
  String _search = '';
  String _sortCol = 'fecha';
  bool _sortAsc = false;
  bool _filtersExpanded = true;

  List<ElementoMapa> get _filtered {
    final list = kElementosSeed.where((e) {
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

  Widget _buildFilterControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        _FilterLabel('Tipo'),
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
        _FilterLabel('Sector'),
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
        _FilterLabel('Estado'),
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
        _TablaBanner(total: kElementosSeed.length, shown: filtered.length),
        const SizedBox(height: 16),

        // ── Filtros ──────────────────────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            if (!isMobile) {
              return Column(children: [
                _buildFilterControls(),
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
                  child: _buildFilterControls(),
                ),
                secondChild: const SizedBox.shrink(),
              ),
              const SizedBox(height: 10),
            ]);
          },
        ),

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
      DataCell(Text(e.by, style: const TextStyle(color: AppTheme.stone500, fontSize: 11.5))),
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
  final int shown;
  const _TablaBanner({required this.total, required this.shown});

  @override
  Widget build(BuildContext context) {
    final types = kElementosSeed.map((e) => e.tipo).toSet().length;
    final sectors = kElementosSeed.map((e) => e.sector).toSet().length;

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
              padding: const EdgeInsets.fromLTRB(28, 24, 140, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.grid_on_outlined, size: 12, color: Color(0x80FFFFFF)),
                    const SizedBox(width: 6),
                    const Text(
                      'Vista · Registro de elementos',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0x80FFFFFF), letterSpacing: 0.9),
                    ),
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
                  Row(children: [
                    _TablaStat(value: '$total', label: 'Total registros', valueColor: const Color(0xFFFB923C)),
                    const SizedBox(width: 16),
                    _TablaStat(value: '$types', label: 'Tipos distintos'),
                    const SizedBox(width: 16),
                    _TablaStat(value: '$sectors', label: 'Sectores'),
                    const SizedBox(width: 16),
                    _TablaStat(value: '$shown', label: 'Mostrando'),
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
