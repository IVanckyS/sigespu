import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../data/seed_data.dart';
import '../map/layers/custom_markers.dart';
import '../map/providers/map_providers.dart';
import '../shared/date_range_popup.dart';

class TablaScreen extends ConsumerStatefulWidget {
  const TablaScreen({super.key});

  @override
  ConsumerState<TablaScreen> createState() => _TablaScreenState();
}

class _TablaScreenState extends ConsumerState<TablaScreen> {
  String _filterCat = 'todos';
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
  ElementoMapa? _selected;
  final _datePopupCtrl = DateRangePopupController(LayerLink());

  /// Cache de la última lista filtrada+ordenada. Se invalida explícitamente
  /// en los setters de filtro para evitar recomputar en rebuilds de hover.
  List<ElementoMapa>? _filteredCache;

  @override
  void initState() {
    super.initState();
    // Sincronizar el provider de PDF export con el estado inicial de filtros.
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncProvider());
  }

  @override
  void dispose() {
    _datePopupCtrl.dismiss();
    super.dispose();
  }

  List<ElementoMapa> get _filtered {
    if (_filteredCache != null) return _filteredCache!;
    final source = ref.read(allElementsProvider);
    final list = source.where((e) {
      if (_filterCat == 'zonas' && e.layerKey != 'zona_peligro') return false;
      if (_filterCat == 'patente' && e.layerKey != 'patente') return false;
      if (_filterCat == 'infra' &&
          !const {'centro_acopio', 'sede_comunitaria', 'infraestructura'}
              .contains(e.layerKey)) return false;
      if (_filterCat == 'reportes' && !e.layerKey.startsWith('reporte_')) return false;
      if (_filterCat == 'otros' && (
          const {'zona_peligro', 'patente', 'centro_acopio', 'sede_comunitaria', 'infraestructura'}
              .contains(e.layerKey) ||
          e.layerKey.startsWith('reporte_'))) return false;
      if (_filterTipo != 'all') {
        if (_filterTipo == 'reporte') {
          if (!e.layerKey.startsWith('reporte_')) { return false; }
        } else {
          if (e.layerKey != _filterTipo) { return false; }
        }
      }
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
          // Excluir lo que caiga en o después del inicio del día siguiente al "hasta",
          // de modo que el rango incluya el día "hasta" completo sin colar el día posterior.
          if (_filterDateTo != null &&
              !d.isBefore(_filterDateTo!.add(const Duration(days: 1)))) return false;
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

    _filteredCache = list;
    return list;
  }

  /// Invalida el cache de filtros y devuelve la lista recalculada.
  /// Llamar siempre que cambie cualquier filtro, orden o búsqueda.
  List<ElementoMapa> _invalidateAndFilter() {
    _filteredCache = null;
    return _filtered;
  }

  void _sort(String col) {
    setState(() {
      if (_sortCol == col) {
        _sortAsc = !_sortAsc;
      } else {
        _sortCol = col;
        _sortAsc = false;
      }
      // Invalida el cache dentro del setState para que el build() subsiguiente
      // llame a _filtered con la lista ya recalculada y la almacene en cache.
      _filteredCache = null;
    });
    // _filtered ya fue recomputado en build(); reutilizamos el cache.
    ref.read(tablaFilteredProvider.notifier).state = _filtered;
  }

  void _syncProvider() {
    ref.read(tablaFilteredProvider.notifier).state = _invalidateAndFilter();
  }

  /// Aplica un cambio de filtro de forma atómica: invalida el cache, actualiza
  /// el estado local y sincroniza el provider del PDF export en un solo ciclo.
  void _applyFilter(VoidCallback mutate) {
    setState(() {
      mutate();
      _filteredCache = null;
    });
    ref.read(tablaFilteredProvider.notifier).state = _filtered;
  }

  void _selectElement(ElementoMapa e, bool isMobile) {
    setState(() => _selected = e);
    if (!isMobile) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MobileDetailSheet(
        elemento: e,
        onClose: () => Navigator.of(context).pop(),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _selected = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allElements = ref.watch(allElementsProvider);
    final filtered = _filtered;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isCompact = constraints.maxWidth < 1100;
        final showDetailInline = !isCompact && _selected != null;

        return Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TablaBanner(allElements: allElements),
              const SizedBox(height: 16),

              // Filtros
              if (!isMobile)
                _FiltersBar(
                  filterTipo: _filterTipo,
                  filterSector: _filterSector,
                  filterEstado: _filterEstado,
                  filterBy: _filterBy,
                  search: _search,
                  dateFrom: _filterDateFrom,
                  dateTo: _filterDateTo,
                  datePopupLink: _datePopupCtrl.link,
                  onTipo: (v) => _applyFilter(() => _filterTipo = v),
                  onSector: (v) => _applyFilter(() => _filterSector = v),
                  onEstado: (v) => _applyFilter(() => _filterEstado = v),
                  onBy: (v) => _applyFilter(() => _filterBy = v),
                  onSearch: (v) => _applyFilter(() => _search = v),
                  onDateTap: () => _datePopupCtrl.show(
                    context,
                    initialFrom: _filterDateFrom,
                    initialTo: _filterDateTo,
                    onApply: (f, t) =>
                        _applyFilter(() { _filterDateFrom = f; _filterDateTo = t; }),
                  ),
                  onDateClear: () =>
                      _applyFilter(() { _filterDateFrom = null; _filterDateTo = null; }),
                )
              else
                _MobileFilters(
                  expanded: _filtersExpanded,
                  onToggle: () => setState(() => _filtersExpanded = !_filtersExpanded),
                  child: _FiltersBar(
                    filterTipo: _filterTipo,
                    filterSector: _filterSector,
                    filterEstado: _filterEstado,
                    filterBy: _filterBy,
                    search: _search,
                    dateFrom: _filterDateFrom,
                    dateTo: _filterDateTo,
                    datePopupLink: _datePopupCtrl.link,
                    onTipo: (v) => _applyFilter(() => _filterTipo = v),
                    onSector: (v) => _applyFilter(() => _filterSector = v),
                    onEstado: (v) => _applyFilter(() => _filterEstado = v),
                    onBy: (v) => _applyFilter(() => _filterBy = v),
                    onSearch: (v) => _applyFilter(() => _search = v),
                    onDateTap: () => _datePopupCtrl.show(
                      context,
                      initialFrom: _filterDateFrom,
                      initialTo: _filterDateTo,
                      onApply: (f, t) =>
                          _applyFilter(() { _filterDateFrom = f; _filterDateTo = t; }),
                    ),
                    onDateClear: () =>
                        _applyFilter(() { _filterDateFrom = null; _filterDateTo = null; }),
                  ),
                ),
              const SizedBox(height: 12),

              _CategoryChips(
                allElements: allElements,
                active: _filterCat,
                onChanged: (cat) => _applyFilter(() => _filterCat = cat),
              ),
              const SizedBox(height: 12),

              // Tabla + detalle
              Expanded(
                child: isMobile
                    ? _MobileCardList(
                        rows: filtered,
                        onSelect: (e) => _selectElement(e, true),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _TablaContenido(
                              rows: filtered,
                              selectedId: _selected?.id,
                              sortCol: _sortCol,
                              sortAsc: _sortAsc,
                              onSort: _sort,
                              onSelect: (e) => _selectElement(e, false),
                            ),
                          ),
                          if (showDetailInline) ...[
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 360,
                              child: _DetailPanel(
                                key: ValueKey(_selected!.id),
                                elemento: _selected!,
                                onClose: () => setState(() => _selected = null),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Tabla contenido ───────────────────────────────────────────────────────────

class _TablaContenido extends StatelessWidget {
  final List<ElementoMapa> rows;
  final String? selectedId;
  final String sortCol;
  final bool sortAsc;
  final ValueChanged<String> onSort;
  final ValueChanged<ElementoMapa> onSelect;

  const _TablaContenido({
    required this.rows,
    required this.selectedId,
    required this.sortCol,
    required this.sortAsc,
    required this.onSort,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _TablaHeader(sortCol: sortCol, sortAsc: sortAsc, onSort: onSort),
          if (rows.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Sin resultados con los filtros actuales',
                  style: TextStyle(color: AppTheme.stone500, fontSize: 13),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (ctx, i) {
                  final e = rows[i];
                  return _TablaFila(
                    elemento: e,
                    selected: e.id == selectedId,
                    onTap: () => onSelect(e),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TablaHeader extends StatelessWidget {
  final String sortCol;
  final bool sortAsc;
  final ValueChanged<String> onSort;

  const _TablaHeader({
    required this.sortCol,
    required this.sortAsc,
    required this.onSort,
  });

  Widget _headerCell(String col, String label, int flex) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => onSort(col),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.stone600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              if (sortCol == col) ...[
                const SizedBox(width: 4),
                Icon(
                  sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: AppTheme.orange600,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.stone50,
        border: Border(bottom: BorderSide(color: AppTheme.stone200)),
      ),
      child: Row(
        children: [
          _headerCell('tipo', 'Tipo', 2),
          _headerCell('nombre', 'Nombre / Descripción', 4),
          _headerCell('sector', 'Sector', 1),
          _headerCell('direccion', 'Dirección', 3),
          _headerCell('fecha', 'Fecha', 2),
          _headerCell('estado', 'Estado', 2),
          _headerCell('by', 'Registrado por', 3),
        ],
      ),
    );
  }
}

class _TablaFila extends StatefulWidget {
  final ElementoMapa elemento;
  final bool selected;
  final VoidCallback onTap;

  const _TablaFila({
    required this.elemento,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_TablaFila> createState() => _TablaFilaState();
}

class _TablaFilaState extends State<_TablaFila> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.elemento;
    final tipoColor = colorParaTipo(e.tipo);
    final estadoColor = colorParaEstado(e.estado);
    final estadoBg = bgParaEstado(e.estado);
    final tipoLabel = nombreParaTipo(e.tipo);
    final estadoLabel = _labelEstado(e.estado);

    final bg = widget.selected
        ? AppTheme.orange50
        : _hover
            ? const Color(0xFFFAFAF9)
            : Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              left: BorderSide(
                color: widget.selected ? AppTheme.orange600 : Colors.transparent,
                width: 3,
              ),
              bottom: const BorderSide(color: AppTheme.stone100),
            ),
          ),
          child: Row(
            children: [
              // Tipo
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tipoColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tipoLabel,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tipoColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Nombre
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    e.nombre,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.stone800,
                    ),
                  ),
                ),
              ),
              // Sector
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.stone100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        e.sector,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.stone700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Dirección
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    e.direccion,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: AppTheme.stone600),
                  ),
                ),
              ),
              // Fecha
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    e.fecha,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.stone500,
                    ),
                  ),
                ),
              ),
              // Estado
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: estadoBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        estadoLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: estadoColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Por
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _byColor(e.by),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _byInitials(e.by),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          e.by,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.stone600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _labelEstado(String e) {
  const m = {
    'activo': 'Activo',
    'en_revision': 'En revisión',
    'cerrado': 'Cerrado',
    'vigente': 'Vigente',
    'vencido': 'Vencido',
  };
  return m[e] ?? e;
}

// ── Detail Panel ──────────────────────────────────────────────────────────────

class _DetailPanel extends StatelessWidget {
  final ElementoMapa elemento;
  final VoidCallback onClose;

  const _DetailPanel({super.key, required this.elemento, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final e = elemento;
    final tipoColor = colorParaTipo(e.tipo);
    final tipoLabel = nombreParaTipo(e.tipo);
    final estadoColor = colorParaEstado(e.estado);
    final estadoBg = bgParaEstado(e.estado);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.stone100)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tipoColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tipoLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: tipoColor,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 18),
                  splashRadius: 18,
                  color: AppTheme.stone500,
                  tooltip: 'Cerrar',
                ),
              ],
            ),
          ),

          // Mini-map
          SizedBox(
            height: 200,
            child: _MiniMapa(elemento: e),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.stone900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: estadoBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _labelEstado(e.estado),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: estadoColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.place_outlined,
                  label: 'Dirección',
                  value: e.direccion.isEmpty ? '—' : e.direccion,
                ),
                _DetailRow(
                  icon: Icons.layers_outlined,
                  label: 'Sector',
                  value: e.sector,
                ),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha',
                  value: e.fecha,
                ),
                _DetailRow(
                  icon: Icons.person_outline,
                  label: 'Registrado por',
                  value: e.by,
                ),
                _DetailRow(
                  icon: Icons.my_location_outlined,
                  label: 'Coordenadas',
                  value:
                      '${e.lat.toStringAsFixed(5)}, ${e.lng.toStringAsFixed(5)}',
                ),
                if (e.rut != null && e.rut!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.badge_outlined,
                    label: 'RUT',
                    value: e.rut!,
                  ),
                if (e.giro != null && e.giro!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.storefront_outlined,
                    label: 'Giro',
                    value: e.giro!,
                  ),
                if (e.capacidad != null)
                  _DetailRow(
                    icon: Icons.group_outlined,
                    label: 'Capacidad',
                    value: '${e.capacidad} personas',
                  ),
                if (e.nivel != null)
                  _DetailRow(
                    icon: Icons.warning_amber_outlined,
                    label: 'Nivel',
                    value: 'Nivel ${e.nivel}',
                  ),
                if (e.tipoPeligro != null && e.tipoPeligro!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.report_problem_outlined,
                    label: 'Tipo de peligro',
                    value: e.tipoPeligro!,
                  ),
                if (e.horario != null && e.horario!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.schedule_outlined,
                    label: 'Horario',
                    value: e.horario!,
                  ),
                if (e.notas.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'NOTAS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.stone500,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.notas,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.stone700,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppTheme.stone500),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.stone500,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.stone800,
                    height: 1.35,
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

class _MiniMapa extends StatelessWidget {
  final ElementoMapa elemento;
  const _MiniMapa({required this.elemento});

  @override
  Widget build(BuildContext context) {
    final hasCoords = elemento.lat != 0 && elemento.lng != 0;
    if (!hasCoords) {
      return Container(
        color: AppTheme.stone50,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined, size: 24, color: AppTheme.stone400),
            SizedBox(height: 6),
            Text(
              'Sin coordenadas',
              style: TextStyle(
                fontSize: 11.5,
                color: AppTheme.stone500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final color = colorParaTipo(elemento.tipo);
    return RepaintBoundary(
      child: AbsorbPointer(
        // Bloqueamos interacciones para que el mini-mapa sea solo visual.
        // Si más adelante quieres pan/zoom, basta con quitar el AbsorbPointer.
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(elemento.lat, elemento.lng),
            initialZoom: 16,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: AppConstants.mapTileUrl,
              subdomains: AppConstants.mapSubdomains,
              userAgentPackageName: 'cl.lota.sigespu',
              retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
              tileProvider: CancellableNetworkTileProvider(),
            ),
            MarkerLayer(
              markers: [
                CustomMarkers.buildMarker(
                  point: LatLng(elemento.lat, elemento.lng),
                  icon: CustomMarkers.getIconForTipo(elemento.tipo),
                  color: color,
                  isPending: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filters bar ───────────────────────────────────────────────────────────────

class _FiltersBar extends StatelessWidget {
  final String filterTipo;
  final String filterSector;
  final String filterEstado;
  final String filterBy;
  final String search;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final LayerLink datePopupLink;
  final ValueChanged<String> onTipo;
  final ValueChanged<String> onSector;
  final ValueChanged<String> onEstado;
  final ValueChanged<String> onBy;
  final ValueChanged<String> onSearch;
  final VoidCallback onDateTap;
  final VoidCallback onDateClear;

  const _FiltersBar({
    required this.filterTipo,
    required this.filterSector,
    required this.filterEstado,
    required this.filterBy,
    required this.search,
    required this.dateFrom,
    required this.dateTo,
    required this.datePopupLink,
    required this.onTipo,
    required this.onSector,
    required this.onEstado,
    required this.onBy,
    required this.onSearch,
    required this.onDateTap,
    required this.onDateClear,
  });

  static const _tipoItems = <(String, String)>[
    ('all', 'Todos los tipos'),
    ('zona_peligro', 'Zonas de peligro'),
    ('reporte', 'Reportes'),
    ('patente', 'Patentes'),
    ('centro_acopio', 'Centros de acopio'),
    ('sede_comunitaria', 'Sedes comunitarias'),
    ('infraestructura', 'Infraestructura'),
  ];

  static const _sectorItems = <(String, String)>[
    ('all', 'Todos'),
    ('S-2', 'S-2 · Residencial Los Aromos'),
    ('S-3', 'S-3 · Mixto Los Aromos'),
    ('S-4', 'S-4 · Equipamiento'),
    ('S-5', 'S-5 · Vivienda Periférica'),
    ('Centro', 'Centro Histórico'),
  ];

  static const _estadoItems = <(String, String)>[
    ('all', 'Todos'),
    ('activo', 'Activo'),
    ('en_revision', 'En revisión'),
    ('cerrado', 'Cerrado'),
  ];

  static const _byItems = <(String, String)>[
    ('all', 'Todos'),
    ('dir_seg', 'Dir. Seg. Pública'),
    ('dideco', 'DIDECO'),
    ('scraping', 'Scraping'),
    ('sepulveda', 'R. Sepúlveda'),
    ('munoz', 'C. Muñoz'),
    ('castro', 'P. Castro'),
    ('historico', 'Reg. histórico'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          _FilterField(
            label: 'Tipo',
            child: _FilterDropdown(
              value: filterTipo,
              items: _tipoItems,
              onChanged: onTipo,
              width: 200,
            ),
          ),
          _FilterField(
            label: 'Sector',
            child: _FilterDropdown(
              value: filterSector,
              items: _sectorItems,
              onChanged: onSector,
              width: 180,
            ),
          ),
          _FilterField(
            label: 'Estado',
            child: _FilterDropdown(
              value: filterEstado,
              items: _estadoItems,
              onChanged: onEstado,
              width: 140,
            ),
          ),
          _FilterField(
            label: 'Registrado por',
            child: _FilterDropdown(
              value: filterBy,
              items: _byItems,
              onChanged: onBy,
              width: 180,
            ),
          ),
          _FilterField(
            label: 'Fecha',
            child: _FilterDateChip(
              from: dateFrom,
              to: dateTo,
              layerLink: datePopupLink,
              onTap: onDateTap,
              onClear: onDateClear,
            ),
          ),
          _FilterField(
            label: 'Buscar',
            child: SizedBox(
              width: 240,
              height: 36,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Nombre, dirección, RUT…',
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppTheme.stone400),
                  prefixIcon: const Icon(Icons.search, size: 16, color: AppTheme.stone400),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.stone200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.stone200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.orange600, width: 1.5),
                  ),
                ),
                style: const TextStyle(fontSize: 12.5),
                onChanged: onSearch,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FilterField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.stone500,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<(String, String)> items;
  final ValueChanged<String> onChanged;
  final double width;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.stone200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, size: 16, color: AppTheme.stone500),
          style: const TextStyle(fontSize: 12.5, color: AppTheme.stone800),
          borderRadius: BorderRadius.circular(8),
          items: items.map((item) {
            final (val, label) = item;
            return DropdownMenuItem(
              value: val,
              child: Text(label, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _MobileFilters extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _MobileFilters({
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.stone200),
            ),
            child: Row(children: [
              const Text(
                'FILTROS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.stone500,
                ),
              ),
              const Spacer(),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                size: 16,
                color: AppTheme.stone500,
              ),
            ]),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: child,
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Banner ────────────────────────────────────────────────────────────────────

class _TablaBanner extends StatelessWidget {
  final List<ElementoMapa> allElements;
  const _TablaBanner({required this.allElements});

  @override
  Widget build(BuildContext context) {
    final total = allElements.length;
    final sectors = allElements.map((e) => e.sector).toSet().length;
    final activos = allElements.where((e) => e.estado == 'activo').length;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final estaSemana = allElements.where((e) {
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
                    Flexible(
                      child: Text(
                        'Vista · Registro de elementos',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0x80FFFFFF),
                          letterSpacing: 0.9,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xBFFFFFFF),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _TablaStat(
                        value: '$total',
                        label: 'Total registros',
                        valueColor: const Color(0xFFFB923C),
                      ),
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
  // Paint objects creados una sola vez — shouldRepaint devuelve false por lo que
  // paint() solo se invoca en el primer layout, pero aun así vale la pena
  // no asignar en el heap en cada llamada.
  static final _p1 = Paint()..color = Colors.white;
  static final _p2 = Paint()..color = Colors.white.withValues(alpha: 0.6);
  static final _p3 = Paint()..color = Colors.white.withValues(alpha: 0.4);
  static final _p4 = Paint()..color = Colors.white.withValues(alpha: 0.3);
  static final _p5 = Paint()..color = Colors.white.withValues(alpha: 0.2);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5 * s, 15 * s, 110 * s, 10 * s),
        Radius.circular(2 * s),
      ),
      _p1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5 * s, 33 * s, 110 * s, 8 * s),
        Radius.circular(2 * s),
      ),
      _p2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5 * s, 49 * s, 110 * s, 8 * s),
        Radius.circular(2 * s),
      ),
      _p3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5 * s, 65 * s, 110 * s, 8 * s),
        Radius.circular(2 * s),
      ),
      _p4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5 * s, 81 * s, 70 * s, 8 * s),
        Radius.circular(2 * s),
      ),
      _p5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Category chips ────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final List<ElementoMapa> allElements;
  final String active;
  final ValueChanged<String> onChanged;

  const _CategoryChips({
    required this.allElements,
    required this.active,
    required this.onChanged,
  });

  static const _infraKeys = {'centro_acopio', 'sede_comunitaria', 'infraestructura'};

  @override
  Widget build(BuildContext context) {
    final countZonas = allElements.where((e) => e.layerKey == 'zona_peligro').length;
    final countPatentes = allElements.where((e) => e.layerKey == 'patente').length;
    final countInfra = allElements.where((e) => _infraKeys.contains(e.layerKey)).length;
    final countReportes = allElements.where((e) => e.layerKey.startsWith('reporte_')).length;
    final countOtros = allElements.where((e) =>
        !_infraKeys.contains(e.layerKey) &&
        e.layerKey != 'zona_peligro' &&
        e.layerKey != 'patente' &&
        !e.layerKey.startsWith('reporte_')).length;

    final chips = [
      (
        id: 'todos',
        label: 'Total',
        count: allElements.length,
        fg: AppTheme.stone600,
        bg: AppTheme.stone100,
      ),
      (
        id: 'zonas',
        label: 'Zonas peligro',
        count: countZonas,
        fg: AppTheme.redDanger,
        bg: const Color(0xFFFEE2E2),
      ),
      (
        id: 'reportes',
        label: 'Reportes',
        count: countReportes,
        fg: const Color(0xFFDC2626),
        bg: const Color(0xFFFEE2E2),
      ),
      (
        id: 'patente',
        label: 'Patentes',
        count: countPatentes,
        fg: AppTheme.amberWarning,
        bg: const Color(0xFFFEF3C7),
      ),
      (
        id: 'infra',
        label: 'Infraestructura',
        count: countInfra,
        fg: AppTheme.greenSuccess,
        bg: const Color(0xFFDCFCE7),
      ),
      (
        id: 'otros',
        label: 'Otros',
        count: countOtros,
        fg: AppTheme.stone500,
        bg: AppTheme.stone100,
      ),
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
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: c.fg, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    c.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? c.fg : AppTheme.stone600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isActive ? c.fg.withValues(alpha: 0.15) : AppTheme.stone100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${c.count}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isActive ? c.fg : AppTheme.stone500,
                      ),
                    ),
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

// ── Avatar helpers ────────────────────────────────────────────────────────────

Color _byColor(String by) {
  const colors = [
    Color(0xFF9A3412),
    Color(0xFF15803D),
    Color(0xFF7C3AED),
    Color(0xFFCA8A04),
    Color(0xFF57534E),
    Color(0xFFB91C1C),
    Color(0xFF0284C7),
    Color(0xFF92400E),
  ];
  return colors[by.codeUnits.fold(0, (a, b) => a + b) % colors.length];
}

String _byInitials(String by) {
  final parts = by.trim().split(RegExp(r'[\s.]+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  if (parts[0].length >= 2) return parts[0].substring(0, 2).toUpperCase();
  return parts[0][0].toUpperCase();
}

// ── Mobile card list (móvil) ──────────────────────────────────────────────────

class _MobileCardList extends StatelessWidget {
  final List<ElementoMapa> rows;
  final ValueChanged<ElementoMapa> onSelect;

  const _MobileCardList({required this.rows, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
        child: Text(
          'Sin resultados con los filtros actuales',
          style: TextStyle(color: AppTheme.stone500, fontSize: 13),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: rows.length,
      itemBuilder: (ctx, i) => _MobileElementoCard(
        elemento: rows[i],
        onTap: () => onSelect(rows[i]),
      ),
    );
  }
}

class _MobileElementoCard extends StatelessWidget {
  final ElementoMapa elemento;
  final VoidCallback onTap;

  const _MobileElementoCard({required this.elemento, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final e = elemento;
    final tipoColor = colorParaTipo(e.tipo);
    final tipoLabel = nombreParaTipo(e.tipo);
    final estadoColor = colorParaEstado(e.estado);
    final estadoBg = bgParaEstado(e.estado);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.stone200),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tipoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.location_on_outlined, size: 18, color: tipoColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: tipoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(tipoLabel,
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: tipoColor)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: estadoBg,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(_labelEstado(e.estado),
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: estadoColor)),
                ),
              ]),
              const SizedBox(height: 5),
              Text(e.nombre,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.stone900),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.place_outlined, size: 11, color: AppTheme.stone400),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    '${e.direccion} · ${e.sector}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.stone500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.schedule_outlined, size: 11, color: AppTheme.stone400),
                const SizedBox(width: 3),
                Text(e.fecha,
                    style: const TextStyle(fontSize: 11, color: AppTheme.stone500)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(e.by,
                      style: const TextStyle(fontSize: 11, color: AppTheme.stone500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ]),
          ),
          const Icon(Icons.chevron_right, size: 16, color: AppTheme.stone300),
        ]),
      ),
    );
  }
}

class _MobileDetailSheet extends StatelessWidget {
  final ElementoMapa elemento;
  final VoidCallback onClose;

  const _MobileDetailSheet({required this.elemento, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.stone300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: _DetailPanel(
              elemento: elemento,
              onClose: onClose,
            ),
          ),
        ]),
      ),
    );
  }
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
    if (from == null && to == null) return 'Cualquiera';
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
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _active ? AppTheme.orange50 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _active ? AppTheme.orange600 : AppTheme.stone200,
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 13,
              color: _active ? AppTheme.orange600 : AppTheme.stone500,
            ),
            const SizedBox(width: 6),
            Text(
              _label,
              style: TextStyle(
                fontSize: 12.5,
                color: _active ? AppTheme.orange700 : AppTheme.stone700,
              ),
            ),
            if (_active) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 13, color: AppTheme.orange600),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.expand_more, size: 16, color: AppTheme.stone500),
              ),
          ]),
        ),
      ),
    );
  }
}
