import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared/shared.dart';

import '../actividades_provider.dart';
import 'actividad_card.dart';

const _depts = ['DIDECO', 'Seg. Pública', 'Tránsito', 'Obras', 'SECPLA'];
const _sectores = ['Centro', 'S-1', 'S-2', 'S-3', 'S-4', 'S-5', 'S-6'];

class TabDatos extends ConsumerStatefulWidget {
  final ActividadMunicipal actividad;

  const TabDatos({super.key, required this.actividad});

  @override
  ConsumerState<TabDatos> createState() => _TabDatosState();
}

class _TabDatosState extends ConsumerState<TabDatos> {
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _presupuestoCtrl;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final a = widget.actividad;
    _tituloCtrl = TextEditingController(text: a.titulo);
    _descCtrl = TextEditingController(text: a.descripcion);
    _direccionCtrl = TextEditingController(
        text: (a.direccion == null || a.direccion == 'Sin ubicación')
            ? ''
            : a.direccion!);
    _presupuestoCtrl = TextEditingController(
      text: (a.presupuestoEstimado ?? 0) > 0
          ? a.presupuestoEstimado!.toInt().toString()
          : '',
    );
    _tituloCtrl.addListener(_onTextChanged);
    _descCtrl.addListener(_onTextChanged);
    _direccionCtrl.addListener(_onTextChanged);
    _presupuestoCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [_tituloCtrl, _descCtrl, _direccionCtrl, _presupuestoCtrl]) {
      c.removeListener(_onTextChanged);
      c.dispose();
    }
    super.dispose();
  }

  ActividadMunicipal get _actividad {
    final lista = ref.read(actividadesProvider);
    return lista.firstWhere((a) => a.id == widget.actividad.id,
        orElse: () => widget.actividad);
  }

  bool get _editable =>
      _actividad.estado == EstadoActividad.planificado;

  void _onTextChanged() {
    if (!_editable) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _saveText);
  }

  void _saveText() {
    final a = _actividad;
    final titulo = _tituloCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final dir = _direccionCtrl.text.trim();
    final presup = double.tryParse(
        _presupuestoCtrl.text.replaceAll('.', '').replaceAll(',', ''));
    ref.read(actividadesProvider.notifier).update(a.copyWith(
          titulo: titulo.isEmpty ? a.titulo : titulo,
          descripcion: desc.isEmpty ? a.descripcion : desc,
          direccion: dir.isEmpty ? null : dir,
          presupuestoEstimado: presup ?? a.presupuestoEstimado,
          actualizadoEn: DateTime.now(),
        ));
  }

  void _saveField(ActividadMunicipal updated) =>
      ref.read(actividadesProvider.notifier).update(updated);

  Future<void> _pickDate(bool isInicio) async {
    final a = _actividad;
    final current = isInicio ? a.fechaInicio : (a.fechaFin ?? a.fechaInicio);
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2024),
      lastDate: DateTime(2028),
      builder: (ctx, child) => _orangeTheme(ctx, child!),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      builder: (ctx, child) => _orangeTheme(ctx, child!),
    );
    if (!mounted) return;
    final picked = DateTime(date.year, date.month, date.day,
        time?.hour ?? current.hour, time?.minute ?? current.minute);
    _saveField(_actividad.copyWith(
      fechaInicio: isInicio ? picked : a.fechaInicio,
      fechaFin: isInicio ? a.fechaFin : picked,
      actualizadoEn: DateTime.now(),
    ));
  }

  Widget _orangeTheme(BuildContext ctx, Widget child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFEA580C),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(actividadesProvider);
    final a = all.firstWhere((e) => e.id == widget.actividad.id,
        orElse: () => widget.actividad);
    final editable = a.estado == EstadoActividad.planificado;
    final T = a.tipo;
    final color = colorParaTipo(T);
    final bg = bgParaTipo(T);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Chips + badge de modo ──────────────────────────────────────
          Row(
            children: [
              Flexible(
                child: Wrap(spacing: 8, runSpacing: 6, children: [
                  _Chip(labelParaTipo(T),
                      bg: bg, fg: color, icon: iconoParaTipo(T)),
                  _Chip('Sector ${a.sector ?? "—"}',
                      bg: const Color(0xFFE7E5E4),
                      fg: const Color(0xFF44403C),
                      mono: true),
                  _EstadoChip(a.estado),
                ]),
              ),
              const SizedBox(width: 8),
              _ModeBadge(editable: editable),
            ],
          ),
          const SizedBox(height: 14),

          // ── Título ────────────────────────────────────────────────────
          const _FieldLabel('Título de la actividad'),
          const SizedBox(height: 6),
          if (editable)
            TextField(
              controller: _tituloCtrl,
              maxLines: 2,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C1917),
              ),
              decoration: _inputDeco(hint: 'Título de la actividad'),
            )
          else
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAF9),
                border:
                    Border.all(color: const Color(0xFFE7E5E4), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                a.titulo,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1917)),
              ),
            ),
          const SizedBox(height: 14),

          // ── Descripción ───────────────────────────────────────────────
          const _FieldLabel('Descripción'),
          const SizedBox(height: 6),
          if (editable)
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF44403C), height: 1.55),
              decoration: _inputDeco(hint: 'Descripción de la actividad'),
            )
          else
            _KV(Text(a.descripcion,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF44403C),
                    height: 1.55))),
          const SizedBox(height: 14),

          // ── Tipo + Sector ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TipoSelector(
                  selected: T,
                  editable: editable,
                  onChanged: (t) => _saveField(
                      _actividad.copyWith(tipo: t, actualizadoEn: DateTime.now())),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Sector'),
                    const SizedBox(height: 6),
                    if (editable)
                      _SectorDropdown(
                        selected: a.sector,
                        onChanged: (s) => _saveField(_actividad.copyWith(
                            sector: s, actualizadoEn: DateTime.now())),
                      )
                    else
                      _KV(Text(a.sector ?? '—',
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 12.5,
                              color: const Color(0xFF1C1917)))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Fechas + Presupuesto ──────────────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            final narrow = constraints.maxWidth < 400;
            final budgetWidget = editable
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Presupuesto estimado'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _presupuestoCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: const Color(0xFF1C1917)),
                        decoration:
                            _inputDeco(hint: '0', prefix: 'CLP \$'),
                      ),
                    ],
                  )
                : _BudgetField(a.presupuestoEstimado);

            if (narrow) {
              return Column(children: [
                Row(children: [
                  Expanded(
                    child: _DateField('Inicio', a.fechaInicio,
                        editable: editable,
                        onTap: () => _pickDate(true)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateField('Término', a.fechaFin,
                        editable: editable,
                        onTap: () => _pickDate(false)),
                  ),
                ]),
                const SizedBox(height: 12),
                budgetWidget,
              ]);
            }

            return Row(children: [
              Expanded(
                child: _DateField('Inicio', a.fechaInicio,
                    editable: editable, onTap: () => _pickDate(true)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField('Término', a.fechaFin,
                    editable: editable,
                    onTap: () => _pickDate(false)),
              ),
              const SizedBox(width: 12),
              Expanded(child: budgetWidget),
            ]);
          }),
          const SizedBox(height: 14),

          // ── Dirección municipal ───────────────────────────────────────
          const _FieldLabel('Dirección municipal responsable'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _depts.map((d) {
              final on = d == a.direccionMunicipal;
              return GestureDetector(
                onTap: editable
                    ? () => _saveField(_actividad.copyWith(
                        direccionMunicipal: d,
                        actualizadoEn: DateTime.now()))
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: on ? const Color(0xFFEA580C) : Colors.white,
                    border: Border.all(
                        color: on
                            ? const Color(0xFFEA580C)
                            : const Color(0xFFE7E5E4)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight:
                          on ? FontWeight.w600 : FontWeight.w500,
                      color: on
                          ? Colors.white
                          : (editable
                              ? const Color(0xFF57534E)
                              : const Color(0xFFA8A29E)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // ── Dirección física ──────────────────────────────────────────
          const _FieldLabel('Dirección / lugar'),
          const SizedBox(height: 6),
          if (editable)
            TextField(
              controller: _direccionCtrl,
              style: const TextStyle(
                  fontSize: 12.5, color: Color(0xFF1C1917)),
              decoration: _inputDeco(
                hint: 'Ej: Pedro Aguirre Cerda 302, Lota',
                prefixIcon: Icons.place_outlined,
              ),
            )
          else
            _KV(Row(children: [
              const Icon(Icons.place_outlined,
                  size: 13, color: Color(0xFF78716C)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  a.direccion ?? 'Sin ubicación',
                  style: TextStyle(
                    fontSize: 12.5,
                    color:
                        (a.direccion == null ||
                                a.direccion == 'Sin ubicación')
                            ? const Color(0xFFA8A29E)
                            : const Color(0xFF1C1917),
                  ),
                ),
              ),
            ])),
        ],
      ),
    );
  }
}

// ── Input decoration helper ───────────────────────────────────────────────────

InputDecoration _inputDeco({
  String? hint,
  String? prefix,
  IconData? prefixIcon,
}) =>
    InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: Color(0xFFA8A29E), fontSize: 13),
      prefixText: prefix,
      prefixStyle:
          const TextStyle(color: Color(0xFF78716C), fontSize: 13),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 14, color: const Color(0xFF78716C))
          : null,
      filled: true,
      fillColor: const Color(0xFFFAFAF9),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: Color(0xFFE7E5E4), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: Color(0xFFEA580C), width: 1.5),
      ),
    );

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ModeBadge extends StatelessWidget {
  final bool editable;
  const _ModeBadge({required this.editable});

  @override
  Widget build(BuildContext context) {
    if (editable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, size: 11, color: Color(0xFF15803D)),
            SizedBox(width: 4),
            Text('Editable',
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF15803D))),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 11, color: Color(0xFF78716C)),
          SizedBox(width: 4),
          Text('Solo lectura',
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF78716C))),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF78716C),
          letterSpacing: 0.06,
        ),
      );
}

class _KV extends StatelessWidget {
  final Widget child;
  const _KV(this.child);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAF9),
          border: Border.all(color: const Color(0xFFE7E5E4)),
          borderRadius: BorderRadius.circular(7),
        ),
        child: child,
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;
  final bool mono;

  const _Chip(this.label,
      {required this.bg, required this.fg, this.icon, this.mono = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(icon != null ? 6 : 10, 3, 10, 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: fg),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: (mono ? GoogleFonts.jetBrainsMono() : const TextStyle())
                  .copyWith(
                      fontSize: 11, fontWeight: FontWeight.w600, color: fg),
            ),
          ],
        ),
      );
}

class _EstadoChip extends StatelessWidget {
  final EstadoActividad estado;
  const _EstadoChip(this.estado);

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg, dot) = switch (estado) {
      EstadoActividad.planificado => (
          'Planificado',
          const Color(0xFFF5F5F4),
          const Color(0xFF57534E),
          const Color(0xFFA8A29E)
        ),
      EstadoActividad.enCurso => (
          'En curso',
          const Color(0xFFFEF3C7),
          const Color(0xFFCA8A04),
          const Color(0xFFCA8A04)
        ),
      EstadoActividad.completado => (
          'Completado',
          const Color(0xFFDCFCE7),
          const Color(0xFF15803D),
          const Color(0xFF15803D)
        ),
      EstadoActividad.archivado => (
          'Archivado',
          const Color(0xFFF5F5F4),
          const Color(0xFF78716C),
          const Color(0xFFA8A29E)
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

class _TipoSelector extends StatelessWidget {
  final TipoActividad selected;
  final bool editable;
  final void Function(TipoActividad)? onChanged;

  const _TipoSelector({
    required this.selected,
    required this.editable,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Tipo de actividad'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F4),
              border: Border.all(color: const Color(0xFFE7E5E4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: TipoActividad.values.map((t) {
                final on = t == selected;
                final c = colorParaTipo(t);
                return Expanded(
                  child: GestureDetector(
                    onTap: editable ? () => onChanged?.call(t) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: on ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: on
                            ? [
                                BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.06),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1))
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(iconoParaTipo(t),
                              size: 12.5,
                              color: on
                                  ? c
                                  : (editable
                                      ? const Color(0xFF78716C)
                                      : const Color(0xFFA8A29E))),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              labelParaTipo(t),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: on
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: on
                                    ? c
                                    : (editable
                                        ? const Color(0xFF78716C)
                                        : const Color(0xFFA8A29E)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
}

class _SectorDropdown extends StatelessWidget {
  final String? selected;
  final void Function(String) onChanged;

  const _SectorDropdown(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) async {
        final overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final box = context.findRenderObject() as RenderBox;
        final offset =
            box.localToGlobal(Offset.zero, ancestor: overlay);

        final result = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + box.size.height + 4,
            offset.dx + 120,
            offset.dy + 300,
          ),
          items: _sectores
              .map((s) => PopupMenuItem(value: s, child: Text(s)))
              .toList(),
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        );
        if (result != null && result != selected) onChanged(result);
      },
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAF9),
          border: Border.all(color: const Color(0xFFE7E5E4), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              selected ?? '—',
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 12.5, color: const Color(0xFF1C1917)),
            ),
          ),
          const Icon(Icons.expand_more,
              size: 14, color: Color(0xFF78716C)),
        ]),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool editable;
  final VoidCallback? onTap;

  const _DateField(this.label, this.date,
      {this.editable = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? '—'
        : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')} '
            '${date!.hour.toString().padLeft(2, '0')}:${date!.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: editable ? onTap : null,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAF9),
              border: Border.all(color: const Color(0xFFE7E5E4), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 11.5,
                        color: date != null
                            ? const Color(0xFF1C1917)
                            : const Color(0xFFA8A29E)),
                  ),
                ),
              ),
              if (editable)
                const Icon(Icons.edit_calendar_outlined,
                    size: 13, color: Color(0xFFEA580C)),
            ]),
          ),
        ),
      ],
    );
  }
}

class _BudgetField extends StatelessWidget {
  final double? value;
  const _BudgetField(this.value);

  @override
  Widget build(BuildContext context) {
    final text = (value == null || value == 0)
        ? 'CLP \$0'
        : 'CLP \$${value!.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Presupuesto estimado'),
        const SizedBox(height: 6),
        _KV(Text(text,
            style: GoogleFonts.jetBrainsMono(
                fontSize: 12, color: const Color(0xFF1C1917)))),
      ],
    );
  }
}
