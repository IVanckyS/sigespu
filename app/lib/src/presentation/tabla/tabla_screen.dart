import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../data/seed_data.dart';

class TablaScreen extends StatefulWidget {
  const TablaScreen({super.key});

  @override
  State<TablaScreen> createState() => _TablaScreenState();
}

class _TablaScreenState extends State<TablaScreen> {
  String _filterTipo = 'all';
  String _filterSector = 'all';
  String _filterEstado = 'all';
  String _search = '';
  String _sortCol = 'fecha';
  bool _sortAsc = false;

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
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──────────────────────────────────────────────────────────
        Row(children: [
          const Text('Registro de elementos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.stone900, letterSpacing: -0.02)),
          const Spacer(),
          Text.rich(TextSpan(children: [
            const TextSpan(text: 'Mostrando ', style: TextStyle(fontSize: 11.5, color: AppTheme.stone600)),
            TextSpan(text: '${filtered.length}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.orange700)),
            const TextSpan(text: ' de ', style: TextStyle(fontSize: 11.5, color: AppTheme.stone600)),
            TextSpan(text: '${kElementosSeed.length}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.orange700)),
            const TextSpan(text: ' registros', style: TextStyle(fontSize: 11.5, color: AppTheme.stone600)),
          ])),
        ]),
        const SizedBox(height: 12),

        // ── Filtros ──────────────────────────────────────────────────────────
        Container(
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
              onChanged: (v) => setState(() => _filterTipo = v),
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
              onChanged: (v) => setState(() => _filterSector = v),
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
              onChanged: (v) => setState(() => _filterEstado = v),
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
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),

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
