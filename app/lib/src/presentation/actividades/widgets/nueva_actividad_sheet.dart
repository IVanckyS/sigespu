import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

import '../actividades_provider.dart';
import 'actividad_card.dart';

const _depts = ['DIDECO', 'Seg. Pública', 'Tránsito', 'Obras', 'SECPLA'];
const _sectores = ['S-1', 'S-2', 'S-3', 'S-4', 'S-5', 'S-6', 'Centro'];

Future<void> showNuevaActividadSheet(
  BuildContext context, {
  EstadoActividad estadoInicial = EstadoActividad.planificado,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 720),
        child: NuevaActividadSheet(estadoInicial: estadoInicial),
      ),
    ),
  );
}

class NuevaActividadSheet extends ConsumerStatefulWidget {
  final EstadoActividad estadoInicial;
  const NuevaActividadSheet({
    super.key,
    this.estadoInicial = EstadoActividad.planificado,
  });

  @override
  ConsumerState<NuevaActividadSheet> createState() => _NuevaActividadSheetState();
}

class _NuevaActividadSheetState extends ConsumerState<NuevaActividadSheet> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _presupuestoCtrl = TextEditingController(text: '0');

  TipoActividad _tipo = TipoActividad.reunion;
  EstadoActividad _estado = EstadoActividad.planificado;
  String? _dept;
  String? _sector;
  DateTime _fechaInicio = DateTime.now().add(const Duration(days: 1));
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _estado = widget.estadoInicial;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _direccionCtrl.dispose();
    _presupuestoCtrl.dispose();
    super.dispose();
  }


  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final presupuesto = double.tryParse(
          _presupuestoCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    const uuid = Uuid();
    final a = ActividadMunicipal(
      id: uuid.v4(),
      tipo: _tipo,
      estado: _estado,
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
      direccion: _direccionCtrl.text.trim().isEmpty
          ? null
          : _direccionCtrl.text.trim(),
      sector: _sector,
      direccionMunicipal: _dept,
      presupuestoEstimado: presupuesto,
      creadoPor: 'director@lota.cl',
      creadoEn: DateTime.now(),
    );
    ref.read(actividadesProvider.notifier).add(a);
    Navigator.of(context).pop();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _fechaInicio : (_fechaFin ?? _fechaInicio);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFEA580C)),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    final timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFEA580C)),
        ),
        child: child!,
      ),
    );
    if (!mounted) return;
    final dt = DateTime(
      picked.year,
      picked.month,
      picked.day,
      timePicked?.hour ?? initial.hour,
      timePicked?.minute ?? initial.minute,
    );
    setState(() {
      if (isStart) {
        _fechaInicio = dt;
        if (_fechaFin != null && _fechaFin!.isBefore(dt)) _fechaFin = null;
      } else {
        _fechaFin = dt;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x28000000), blurRadius: 24, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDD5),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Color(0xFFEA580C)),
                ),
                const SizedBox(width: 10),
                Text(
                  'Nueva actividad',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1917),
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close, size: 15, color: Color(0xFF57534E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, color: Color(0xFFE7E5E4)),

          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    _Label('Título de la actividad *'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _tituloCtrl,
                      autofocus: true,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1917),
                      ),
                      decoration: _inputDeco(hint: 'Ej: Mesa territorial Lota Bajo · Comerciantes'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'El título es obligatorio' : null,
                    ),
                    const SizedBox(height: 14),

                    // Tipo
                    _Label('Tipo de actividad'),
                    const SizedBox(height: 8),
                    _TipoSelector(
                      selected: _tipo,
                      onChanged: (t) => setState(() => _tipo = t),
                    ),
                    const SizedBox(height: 14),

                    // Estado inicial
                    _Label('Estado inicial'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: EstadoActividad.values.map((e) {
                        final on = e == _estado;
                        final (label, bg, fg) = switch (e) {
                          EstadoActividad.planificado => ('Planificado', const Color(0xFFF5F5F4), const Color(0xFF57534E)),
                          EstadoActividad.enCurso => ('En curso', const Color(0xFFFFF7ED), const Color(0xFFEA580C)),
                          EstadoActividad.completado => ('Completado', const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
                          EstadoActividad.archivado => ('Archivado', const Color(0xFFF5F5F4), const Color(0xFF78716C)),
                        };
                        return GestureDetector(
                          onTap: () => setState(() => _estado = e),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: on ? bg : Colors.white,
                              border: Border.all(
                                color: on ? fg : const Color(0xFFE7E5E4),
                                width: on ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                                color: on ? fg : const Color(0xFF78716C),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Descripción
                    _Label('Descripción'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF44403C), height: 1.5),
                      decoration: _inputDeco(hint: 'Detalle de la actividad…'),
                    ),
                    const SizedBox(height: 14),

                    // Sector + Dirección municipal
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sector dropdown
                        SizedBox(
                          width: 110,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Sector'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _sector,
                                hint: const Text('—', style: TextStyle(fontSize: 13)),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  color: const Color(0xFF1C1917),
                                ),
                                decoration: _inputDeco(),
                                items: _sectores
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (v) => setState(() => _sector = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Dirección municipal
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Dirección municipal'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: _depts.map((d) {
                                  final on = d == _dept;
                                  return GestureDetector(
                                    onTap: () => setState(() => _dept = on ? null : d),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 100),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: on ? const Color(0xFFEA580C) : Colors.white,
                                        border: Border.all(
                                          color: on ? const Color(0xFFEA580C) : const Color(0xFFE7E5E4),
                                        ),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        d,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                                          color: on ? Colors.white : const Color(0xFF57534E),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Fechas
                    Row(
                      children: [
                        Expanded(
                          child: _DateBtn(
                            label: 'Inicio',
                            date: _fechaInicio,
                            onTap: () => _pickDate(isStart: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DateBtn(
                            label: 'Término (opcional)',
                            date: _fechaFin,
                            onTap: () => _pickDate(isStart: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Dirección + Presupuesto
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Dirección / lugar'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _direccionCtrl,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF1C1917)),
                                decoration: _inputDeco(hint: 'Ej: Pedro Aguirre Cerda 302'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('Presupuesto (CLP)'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _presupuestoCtrl,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  color: const Color(0xFF1C1917),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: _inputDeco(hint: '0'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE7E5E4))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF57534E),
                      side: const BorderSide(color: Color(0xFFD6D3D1)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancelar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Crear actividad',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
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

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

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

InputDecoration _inputDeco({String? hint}) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFA8A29E)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      filled: true,
      fillColor: const Color(0xFFFAFAF9),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE7E5E4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEA580C), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB91C1C)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.5),
      ),
    );

class _TipoSelector extends StatelessWidget {
  final TipoActividad selected;
  final ValueChanged<TipoActividad> onChanged;
  const _TipoSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onTap: () => onChanged(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: on ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: on
                      ? [const BoxShadow(color: Color(0x10000000), blurRadius: 2, offset: Offset(0, 1))]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(iconoParaTipo(t), size: 14, color: on ? c : const Color(0xFF78716C)),
                    const SizedBox(height: 3),
                    Text(
                      labelParaTipo(t),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                        color: on ? c : const Color(0xFF78716C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DateBtn extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DateBtn({required this.label, required this.date, required this.onTap});

  String _fmt(DateTime d) {
    const m = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${m[d.month]} ${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAF9),
              border: Border.all(color: const Color(0xFFE7E5E4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF78716C)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date == null ? 'Sin fecha' : _fmt(date!),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11.5,
                      color: date == null ? const Color(0xFFA8A29E) : const Color(0xFF1C1917),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
