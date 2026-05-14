import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared/shared.dart';

import 'actividades_provider.dart';
import 'widgets/actividad_bottom_sheet.dart';
import 'widgets/kanban_board.dart';
import 'widgets/nueva_actividad_sheet.dart';

class ActividadesScreen extends ConsumerStatefulWidget {
  const ActividadesScreen({super.key});

  @override
  ConsumerState<ActividadesScreen> createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends ConsumerState<ActividadesScreen> {
  void _open(ActividadMunicipal a) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960, maxHeight: 640),
          child: ActividadBottomSheet(
            actividad: a,
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }

  void _openNuevaActividad({EstadoActividad? estado}) {
    showNuevaActividadSheet(
      context,
      estadoInicial: estado ?? EstadoActividad.planificado,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActividadesToolbar(onNuevaActividad: _openNuevaActividad),
        Expanded(
          child: KanbanBoard(
            onCardTap: _open,
            onNuevaActividad: _openNuevaActividad,
          ),
        ),
      ],
    );
  }
}

// ── Toolbar ───────────────────────────────────────────────────────────────────

class _ActividadesToolbar extends ConsumerStatefulWidget {
  final VoidCallback onNuevaActividad;

  const _ActividadesToolbar({required this.onNuevaActividad});

  @override
  ConsumerState<_ActividadesToolbar> createState() => _ActividadesToolbarState();
}

class _ActividadesToolbarState extends ConsumerState<_ActividadesToolbar> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportarJson() async {
    final json = ref.read(actividadesProvider.notifier).exportTrelloJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON copiado al portapapeles (formato Trello)'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _importarJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;
    if (bytes == null) return;

    try {
      final jsonStr = utf8.decode(bytes);
      ref.read(actividadesProvider.notifier).importFromTrelloJson(jsonStr);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actividades importadas correctamente')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al leer el JSON. Verifica el formato.')),
      );
    }
  }

  void _clearAllFilters() {
    _searchCtrl.clear();
    ref.read(actividadesSearchProvider.notifier).state = '';
    ref.read(actividadesTipoFilterProvider.notifier).state = null;
    ref.read(actividadesDeptFilterProvider.notifier).state = null;
    ref.read(actividadesDateFromProvider.notifier).state = null;
    ref.read(actividadesDateToProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final total      = ref.watch(actividadesProvider).length;
    final tipoFilter = ref.watch(actividadesTipoFilterProvider);
    final deptFilter = ref.watch(actividadesDeptFilterProvider);
    final dateFrom   = ref.watch(actividadesDateFromProvider);
    final dateTo     = ref.watch(actividadesDateToProvider);
    final anyFilter  = tipoFilter != null || deptFilter != null ||
        dateFrom != null || dateTo != null ||
        ref.watch(actividadesSearchProvider).isNotEmpty;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE7E5E4))),
      ),
      child: Row(
        children: [
          // Title area
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.view_kanban_outlined,
                    size: 15, color: Color(0xFFEA580C)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Actividades municipales',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1917),
                      letterSpacing: -0.1,
                    ),
                  ),
                  Text(
                    'Tablero kanban · $total actividades',
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF78716C)),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),

          // Search
          SizedBox(
            width: 220,
            height: 32,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) =>
                  ref.read(actividadesSearchProvider.notifier).state = v,
              style: const TextStyle(fontSize: 12.5),
              decoration: InputDecoration(
                hintText: 'Buscar actividades…',
                hintStyle:
                    const TextStyle(fontSize: 12.5, color: Color(0xFFA8A29E)),
                prefixIcon:
                    const Icon(Icons.search, size: 15, color: Color(0xFFA8A29E)),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: const Color(0xFFFAFAF9),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE7E5E4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFEA580C), width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Tipo filter
          _TipoFilterBtn(
            selected: tipoFilter,
            onChanged: (t) =>
                ref.read(actividadesTipoFilterProvider.notifier).state = t,
          ),
          const SizedBox(width: 6),

          // Dept filter
          _DeptFilterBtn(
            selected: deptFilter,
            onChanged: (d) =>
                ref.read(actividadesDeptFilterProvider.notifier).state = d,
          ),
          const SizedBox(width: 6),

          // Date range filter
          _DateFilterBtn(
            dateFrom: dateFrom,
            dateTo: dateTo,
            onChanged: (from, to) {
              ref.read(actividadesDateFromProvider.notifier).state = from;
              ref.read(actividadesDateToProvider.notifier).state = to;
            },
          ),
          const SizedBox(width: 6),

          // Clear all filters chip
          if (anyFilter)
            GestureDetector(
              onTap: _clearAllFilters,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  border: Border.all(
                      color: const Color(0xFFFED7AA), width: 1.5),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_alt_off_outlined,
                        size: 12, color: Color(0xFFC2410C)),
                    SizedBox(width: 4),
                    Text('Limpiar filtros',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFC2410C))),
                  ],
                ),
              ),
            ),
          if (anyFilter) const SizedBox(width: 6),

          // Export JSON
          _ToolbarBtn(
            label: 'Exportar JSON',
            icon: Icons.download_outlined,
            onTap: _exportarJson,
          ),
          const SizedBox(width: 6),

          // Import JSON
          _ToolbarBtn(
            label: 'Importar JSON',
            icon: Icons.upload_outlined,
            onTap: _importarJson,
          ),
          const SizedBox(width: 10),

          // Divider
          Container(width: 1, height: 22, color: const Color(0xFFE7E5E4)),
          const SizedBox(width: 10),

          // Nueva actividad
          ElevatedButton.icon(
            onPressed: widget.onNuevaActividad,
            icon: const Icon(Icons.add, size: 14),
            label: const Text(
              'Nueva actividad',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ToolbarBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ToolbarBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE7E5E4), width: 1.5),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF57534E)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF44403C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipoFilterBtn extends StatelessWidget {
  final TipoActividad? selected;
  final ValueChanged<TipoActividad?> onChanged;

  const _TipoFilterBtn({required this.selected, required this.onChanged});

  static const _labels = {
    null: 'Tipo: Todos',
    TipoActividad.reunion: 'Reunión',
    TipoActividad.operativo: 'Operativo',
    TipoActividad.evento: 'Evento',
    TipoActividad.capacitacion: 'Capacitación',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) async {
        final overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final box = context.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero, ancestor: overlay);

        final result = await showMenu<TipoActividad?>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + box.size.height + 4,
            offset.dx + 160,
            offset.dy + 200,
          ),
          items: [
            const PopupMenuItem(value: null, child: Text('Todos')),
            ...TipoActividad.values.map(
              (t) => PopupMenuItem(
                value: t,
                child: Text(_labels[t] ?? t.name),
              ),
            ),
          ],
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
        if (result != selected) onChanged(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected != null
                ? const Color(0xFFEA580C)
                : const Color(0xFFE7E5E4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(7),
          color: selected != null
              ? const Color(0xFFFFF7ED)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _labels[selected] ?? 'Tipo: Todos',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected != null
                    ? const Color(0xFFC2410C)
                    : const Color(0xFF44403C),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 14,
              color: selected != null
                  ? const Color(0xFFC2410C)
                  : const Color(0xFF78716C),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dept filter ───────────────────────────────────────────────────────────────

class _DeptFilterBtn extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _DeptFilterBtn({required this.selected, required this.onChanged});

  static const _depts = [
    'Seg. Publica',
    'DIDECO',
    'Transito',
    'Obras',
    'SECPLA',
  ];

  @override
  Widget build(BuildContext context) {
    final active = selected != null;
    return GestureDetector(
      onTapDown: (details) async {
        final overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final box = context.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero, ancestor: overlay);

        final result = await showMenu<String?>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + box.size.height + 4,
            offset.dx + 160,
            offset.dy + 300,
          ),
          items: [
            const PopupMenuItem(value: null, child: Text('Todos los deptos.')),
            ..._depts.map((d) => PopupMenuItem(value: d, child: Text(d))),
          ],
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
        if (result != selected) onChanged(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFF7ED) : Colors.transparent,
          border: Border.all(
            color:
                active ? const Color(0xFFEA580C) : const Color(0xFFE7E5E4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              active ? selected! : 'Depto.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active
                    ? const Color(0xFFC2410C)
                    : const Color(0xFF44403C),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more,
                size: 14,
                color: active
                    ? const Color(0xFFC2410C)
                    : const Color(0xFF78716C)),
          ],
        ),
      ),
    );
  }
}

// -- Date range filter ---------------------------------------------------------

class _DateFilterBtn extends StatelessWidget {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final void Function(DateTime? from, DateTime? to) onChanged;

  const _DateFilterBtn({
    required this.dateFrom,
    required this.dateTo,
    required this.onChanged,
  });

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}';

  @override
  Widget build(BuildContext context) {
    final active = dateFrom != null || dateTo != null;
    String label = 'Fecha';
    if (dateFrom != null && dateTo != null) {
      label = '${_fmt(dateFrom!)}-${_fmt(dateTo!)}';
    } else if (dateFrom != null) {
      label = 'Desde ${_fmt(dateFrom!)}';
    } else if (dateTo != null) {
      label = 'Hasta ${_fmt(dateTo!)}';
    }

    return GestureDetector(
      onTap: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2024),
          lastDate: DateTime(2027),
          initialDateRange: dateFrom != null && dateTo != null
              ? DateTimeRange(start: dateFrom!, end: dateTo!)
              : null,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFEA580C),
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
        if (range != null) {
          onChanged(range.start, range.end);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFF7ED) : Colors.transparent,
          border: Border.all(
            color:
                active ? const Color(0xFFEA580C) : const Color(0xFFE7E5E4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 12,
                color: active
                    ? const Color(0xFFC2410C)
                    : const Color(0xFF78716C)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active
                    ? const Color(0xFFC2410C)
                    : const Color(0xFF44403C),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more,
                size: 14,
                color: active
                    ? const Color(0xFFC2410C)
                    : const Color(0xFF78716C)),
          ],
        ),
      ),
    );
  }
}
