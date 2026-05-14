import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

import '../actividades_provider.dart';
import '../../users/solicitudes_provider.dart';

const _uuid = Uuid();

class TabActa extends ConsumerStatefulWidget {
  final ActividadMunicipal actividad;

  const TabActa({super.key, required this.actividad});

  @override
  ConsumerState<TabActa> createState() => _TabActaState();
}

class _TabActaState extends ConsumerState<TabActa> {
  late final TextEditingController _cuerpoCtrl;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _cuerpoCtrl = TextEditingController(
      text: widget.actividad.acta?.contenido ?? '',
    );
    _cuerpoCtrl.addListener(_onCuerpoChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cuerpoCtrl.removeListener(_onCuerpoChanged);
    _cuerpoCtrl.dispose();
    super.dispose();
  }

  ActividadMunicipal get _actividad {
    final lista = ref.read(actividadesProvider);
    return lista.firstWhere((a) => a.id == widget.actividad.id,
        orElse: () => widget.actividad);
  }

  void _onCuerpoChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      final acta = (_actividad.acta ?? const ActaActividad())
          .copyWith(contenido: _cuerpoCtrl.text);
      ref.read(actividadesProvider.notifier).updateActa(widget.actividad.id, acta);
    });
  }

  void _toggleAsistencia(int index) {
    final a = _actividad;
    final asistentes = List<AsistenteActa>.from(a.acta?.asistentes ?? []);
    asistentes[index] =
        asistentes[index].copyWith(asistio: !asistentes[index].asistio);
    final acta =
        (a.acta ?? const ActaActividad()).copyWith(asistentes: asistentes);
    ref.read(actividadesProvider.notifier).updateActa(a.id, acta);
  }

  void _toggleAcuerdo(String acuerdoId) {
    final a = _actividad;
    final acuerdos = (a.acta?.acuerdos ?? []).map((ac) {
      if (ac.id == acuerdoId) return ac.copyWith(completado: !ac.completado);
      return ac;
    }).toList();
    final acta =
        (a.acta ?? const ActaActividad()).copyWith(acuerdos: acuerdos);
    ref.read(actividadesProvider.notifier).updateActa(a.id, acta);
  }

  Future<void> _showAddAsistenteDialog() async {
    final nombreCtrl = TextEditingController();
    final cargoCtrl = TextEditingController();
    final rutCtrl = TextEditingController();
    final searchCtrl = TextEditingController();
    var searchQuery = '';
    var showManual = false;

    void addAsistente(BuildContext ctx, AsistenteActa nuevo) {
      final a = _actividad;
      final asistentes = <AsistenteActa>[...(a.acta?.asistentes ?? []), nuevo];
      final acta =
          (a.acta ?? const ActaActividad()).copyWith(asistentes: asistentes);
      ref.read(actividadesProvider.notifier).updateActa(a.id, acta);
      Navigator.pop(ctx);
    }

    // Merge real approved users with mock users (deduplicated by email)
    final realUsers = ref.read(solicitudesProvider).value
            ?.where((s) => s.estado == 'aprobada')
            .map((s) => UsuarioSistema(
                  id: s.id,
                  nombre: s.nombre,
                  cargo: s.cargo,
                  email: s.email,
                  rut: '',
                ))
            .toList() ??
        [];
    final mockUsers = ref.read(usuariosSistemaProvider);
    final realEmails = realUsers.map((u) => u.email).toSet();
    final mergedUsers = [
      ...realUsers,
      ...mockUsers.where((u) => !realEmails.contains(u.email)),
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) {
          final allUsers = mergedUsers;
          final filtered = searchQuery.isEmpty
              ? allUsers
              : allUsers
                  .where((u) =>
                      u.nombre.toLowerCase().contains(searchQuery) ||
                      u.cargo.toLowerCase().contains(searchQuery))
                  .toList();

          return AlertDialog(
            title: const Text('Añadir asistente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Búsqueda del sistema ────────────────────────────────
                  TextField(
                    controller: searchCtrl,
                    onChanged: (v) =>
                        setInner(() => searchQuery = v.toLowerCase()),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Buscar usuario del sistema…',
                      hintStyle: const TextStyle(
                          color: Color(0xFFA8A29E), fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          size: 16, color: Color(0xFF78716C)),
                      filled: true,
                      fillColor: const Color(0xFFFAFAF9),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFFE7E5E4), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFFEA580C), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // ── Lista de usuarios ────────────────────────────────────
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: filtered.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text('Sin resultados',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFA8A29E))),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final u = filtered[i];
                              final initials = u.nombre
                                  .trim()
                                  .split(' ')
                                  .take(2)
                                  .map((s) =>
                                      s.isNotEmpty ? s[0].toUpperCase() : '')
                                  .join();
                              return InkWell(
                                onTap: () => addAsistente(
                                    ctx,
                                    AsistenteActa(
                                      nombre: u.nombre,
                                      cargo: u.cargo,
                                      rut: u.rut,
                                      asistio: true,
                                    )),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 6),
                                  child: Row(children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFEDD5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(initials,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFC2410C))),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(u.nombre,
                                              style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1C1917))),
                                          Text('${u.cargo} · ${u.rut}',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF78716C))),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.add_circle_outline,
                                        size: 16, color: Color(0xFFEA580C)),
                                  ]),
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(height: 20),
                  // ── Manual toggle ────────────────────────────────────────
                  GestureDetector(
                    onTap: () => setInner(() => showManual = !showManual),
                    child: Row(children: [
                      const Text('Ingresar manualmente',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF78716C))),
                      const Spacer(),
                      Icon(
                          showManual
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 16,
                          color: const Color(0xFF78716C)),
                    ]),
                  ),
                  if (showManual) ...[
                    const SizedBox(height: 12),
                    _DialogField(
                        controller: nombreCtrl,
                        label: 'Nombre completo',
                        hint: 'Ej: Maria Gonzalez'),
                    const SizedBox(height: 10),
                    _DialogField(
                        controller: cargoCtrl,
                        label: 'Cargo',
                        hint: 'Ej: Inspector Municipal'),
                    const SizedBox(height: 10),
                    _DialogField(
                        controller: rutCtrl,
                        label: 'RUT (opcional)',
                        hint: 'Ej: 12.345.678-9'),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar')),
              if (showManual)
                ElevatedButton(
                  onPressed: () {
                    if (nombreCtrl.text.trim().isEmpty ||
                        cargoCtrl.text.trim().isEmpty) {
                      return;
                    }
                    addAsistente(
                        ctx,
                        AsistenteActa(
                          nombre: nombreCtrl.text.trim(),
                          cargo: cargoCtrl.text.trim(),
                          rut: rutCtrl.text.trim().isNotEmpty
                              ? rutCtrl.text.trim()
                              : null,
                          asistio: true,
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Añadir'),
                ),
            ],
          );
        },
      ),
    );

    nombreCtrl.dispose();
    cargoCtrl.dispose();
    rutCtrl.dispose();
    searchCtrl.dispose();
  }

  Future<void> _showAddAcuerdoDialog() async {
    final descCtrl = TextEditingController();
    final respCtrl = TextEditingController();
    DateTime? fechaLimite;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          title: const Text('Nuevo acuerdo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(
                  controller: descCtrl,
                  label: 'Descripción',
                  hint: 'Descripción del acuerdo',
                  maxLines: 2),
              const SizedBox(height: 12),
              _DialogField(
                  controller: respCtrl,
                  label: 'Responsable',
                  hint: 'Nombre del responsable'),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate:
                        DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setInner(() => fechaLimite = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFFE7E5E4), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: Color(0xFF78716C)),
                      const SizedBox(width: 8),
                      Text(
                        fechaLimite != null
                            ? '${fechaLimite!.year}-${fechaLimite!.month.toString().padLeft(2, '0')}-${fechaLimite!.day.toString().padLeft(2, '0')}'
                            : 'Seleccionar fecha límite',
                        style: TextStyle(
                          fontSize: 13,
                          color: fechaLimite != null
                              ? const Color(0xFF1C1917)
                              : const Color(0xFFA8A29E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (descCtrl.text.trim().isEmpty ||
                    respCtrl.text.trim().isEmpty ||
                    fechaLimite == null) {
                  return;
                }
                final nuevo = AcuerdoActa(
                  id: _uuid.v4(),
                  descripcion: descCtrl.text.trim(),
                  responsable: respCtrl.text.trim(),
                  fechaLimite: fechaLimite!,
                  completado: false,
                );
                final a = _actividad;
                final acuerdos = <AcuerdoActa>[...(a.acta?.acuerdos ?? []), nuevo];
                final acta = (a.acta ?? const ActaActividad())
                    .copyWith(acuerdos: acuerdos);
                ref.read(actividadesProvider.notifier).updateActa(a.id, acta);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );

    descCtrl.dispose();
    respCtrl.dispose();
  }

  Future<void> _adjuntarArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'jpg', 'png'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final filename = result.files.first.name;
    final a = _actividad;
    final adjuntos = [...a.adjuntos, filename];
    ref.read(actividadesProvider.notifier).update(a.copyWith(adjuntos: adjuntos));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Archivo adjuntado: $filename'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _tipoLabel(TipoActividad t) => switch (t) {
        TipoActividad.reunion => 'Reunión',
        TipoActividad.operativo => 'Operativo',
        TipoActividad.evento => 'Evento',
        TipoActividad.capacitacion => 'Capacitación',
      };

  String _estadoLabel(EstadoActividad e) => switch (e) {
        EstadoActividad.planificado => 'Planificado',
        EstadoActividad.enCurso => 'En curso',
        EstadoActividad.completado => 'Completado',
        EstadoActividad.archivado => 'Archivado',
      };

  Future<void> _exportarPDF() async {
    final a = _actividad;
    final doc = pw.Document();
    final now = DateTime.now();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MUNICIPALIDAD DE LOTA',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey600,
                        letterSpacing: 1,
                      ),
                    ),
                    pw.Text(
                      'Dirección de Seguridad Pública',
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.grey500),
                    ),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'ACTA DE ACTIVIDAD MUNICIPAL',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  pw.Text(
                    'ID: ${a.id.substring(0, 8).toUpperCase()}',
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColors.grey400),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Divider(thickness: 2, color: PdfColors.deepOrange700),
          pw.SizedBox(height: 4),
        ],
      ),
      footer: (ctx) => pw.Column(
        children: [
          pw.Divider(color: PdfColors.grey300, thickness: 0.5),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'SIGESPU Lota · Dirección de Seguridad Pública · ${_fmtDt(now)}',
                style: const pw.TextStyle(
                    fontSize: 7.5, color: PdfColors.grey500),
              ),
              pw.Text(
                'Pág. ${ctx.pageNumber} / ${ctx.pagesCount}',
                style: const pw.TextStyle(
                    fontSize: 7.5, color: PdfColors.grey500),
              ),
            ],
          ),
        ],
      ),
      build: (ctx) => [
        // ── Título principal ────────────────────────────────────────────
        pw.Text(
          a.titulo,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Row(children: [
          _pdfChip(_tipoLabel(a.tipo), PdfColors.deepOrange50,
              PdfColors.deepOrange700),
          pw.SizedBox(width: 6),
          _pdfChip(_estadoLabel(a.estado), PdfColors.grey100,
              PdfColors.grey600),
          if (a.sector != null) ...[
            pw.SizedBox(width: 6),
            _pdfChip(a.sector!, PdfColors.grey100, PdfColors.grey600),
          ],
        ]),
        pw.SizedBox(height: 18),

        // ── Datos generales ─────────────────────────────────────────────
        _pdfSection('1. DATOS GENERALES'),
        _pdfKV('Descripción', a.descripcion.isNotEmpty ? a.descripcion : '—'),
        _pdfKV('Tipo de actividad', _tipoLabel(a.tipo)),
        _pdfKV('Estado', _estadoLabel(a.estado)),
        _pdfKV('Fecha de inicio', _fmtDtHora(a.fechaInicio)),
        if (a.fechaFin != null)
          _pdfKV('Fecha de término', _fmtDtHora(a.fechaFin!)),
        if (a.direccionMunicipal != null)
          _pdfKV('Dirección municipal', a.direccionMunicipal!),
        if (a.presupuestoEstimado != null)
          _pdfKV('Presupuesto estimado',
              '\$${a.presupuestoEstimado!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
        _pdfKV('Registrado por', a.creadoPor),
        _pdfKV('Fecha de registro', _fmtDtHora(a.creadoEn)),
        if (a.actualizadoEn != null)
          _pdfKV('Última modificación', _fmtDtHora(a.actualizadoEn!)),
        pw.SizedBox(height: 16),

        // ── Ubicación ───────────────────────────────────────────────────
        if (a.direccion != null || a.lat != null) ...[
          _pdfSection('2. UBICACIÓN'),
          if (a.direccion != null) _pdfKV('Dirección', a.direccion!),
          if (a.sector != null) _pdfKV('Sector', a.sector!),
          if (a.lat != null && a.lng != null)
            _pdfKV('Coordenadas',
                '${a.lat!.toStringAsFixed(6)}, ${a.lng!.toStringAsFixed(6)}'),
          pw.SizedBox(height: 16),
        ],

        // ── Cuerpo del acta ─────────────────────────────────────────────
        _pdfSection('${(a.direccion != null || a.lat != null) ? '3' : '2'}. CUERPO DEL ACTA'),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text(
            a.acta?.contenido?.trim().isNotEmpty == true
                ? a.acta!.contenido!
                : '(Sin contenido registrado)',
            style: const pw.TextStyle(fontSize: 11, lineSpacing: 6),
          ),
        ),
        pw.SizedBox(height: 16),

        // ── Asistentes ──────────────────────────────────────────────────
        if ((a.acta?.asistentes ?? []).isNotEmpty) ...[
          _pdfSection('ASISTENTES (${a.acta!.asistentes.length})'),
          pw.TableHelper.fromTextArray(
            headers: ['N°', 'Nombre completo', 'Cargo', 'RUT', 'Asistencia'],
            data: a.acta!.asistentes.asMap().entries
                .map((e) => [
                      '${e.key + 1}',
                      e.value.nombre,
                      e.value.cargo,
                      e.value.rut ?? '—',
                      e.value.asistio ? '✓ Asistió' : '✗ Ausente',
                    ])
                .toList(),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
                color: PdfColors.white),
            cellStyle: const pw.TextStyle(fontSize: 9.5),
            cellAlignments: {
              0: pw.Alignment.center,
              4: pw.Alignment.center,
            },
            headerDecoration: const pw.BoxDecoration(
                color: PdfColors.deepOrange700),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration:
                const pw.BoxDecoration(color: PdfColors.orange50),
            border: pw.TableBorder.all(
                color: PdfColors.grey300, width: 0.5),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${a.acta!.asistentes.where((p) => p.asistio).length} de ${a.acta!.asistentes.length} asistentes presentes.',
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 16),
        ],

        // ── Acuerdos ────────────────────────────────────────────────────
        if ((a.acta?.acuerdos ?? []).isNotEmpty) ...[
          _pdfSection('ACUERDOS Y COMPROMISOS (${a.acta!.acuerdos.length})'),
          pw.TableHelper.fromTextArray(
            headers: [
              'N°',
              'Descripción',
              'Responsable',
              'Fecha límite',
              'Estado'
            ],
            data: a.acta!.acuerdos.asMap().entries
                .map((e) {
                  final ac = e.value;
                  final vencido = !ac.completado &&
                      ac.fechaLimite.isBefore(DateTime.now());
                  return [
                    '${e.key + 1}',
                    ac.descripcion,
                    ac.responsable,
                    _fmtDt(ac.fechaLimite),
                    ac.completado
                        ? 'Completado'
                        : vencido
                            ? 'Vencido'
                            : 'Pendiente',
                  ];
                })
                .toList(),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
                color: PdfColors.white),
            cellStyle: const pw.TextStyle(fontSize: 9.5),
            cellAlignments: {
              0: pw.Alignment.center,
              4: pw.Alignment.center,
            },
            headerDecoration: const pw.BoxDecoration(
                color: PdfColors.deepOrange700),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration:
                const pw.BoxDecoration(color: PdfColors.orange50),
            border: pw.TableBorder.all(
                color: PdfColors.grey300, width: 0.5),
          ),
          pw.SizedBox(height: 16),
        ],

        // ── Archivos adjuntos ───────────────────────────────────────────
        if (a.adjuntos.isNotEmpty) ...[
          _pdfSection('ARCHIVOS ADJUNTOS'),
          ...a.adjuntos.asMap().entries.map(
                (e) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Text(
                    '${e.key + 1}. ${e.value}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ),
          pw.SizedBox(height: 16),
        ],

        // ── Firmas ──────────────────────────────────────────────────────
        pw.SizedBox(height: 24),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _pdfFirmaBox('Director/a de Seguridad Pública'),
            _pdfFirmaBox('Responsable de la actividad'),
          ],
        ),
      ],
    ));

    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Acta-${a.id.substring(0, 8).toUpperCase()}-${a.fechaInicio.year}.pdf',
    );
  }

  pw.Widget _pdfChip(String label, PdfColor bg, PdfColor fg) =>
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(99)),
        ),
        child: pw.Text(label,
            style: pw.TextStyle(
                fontSize: 9, fontWeight: pw.FontWeight.bold, color: fg)),
      );

  pw.Widget _pdfFirmaBox(String cargo) => pw.Column(
        children: [
          pw.Container(
            width: 180,
            height: 40,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.8)),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(cargo,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              textAlign: pw.TextAlign.center),
        ],
      );

  pw.Widget _pdfSection(String title) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(title,
            style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.deepOrange700)),
      );

  pw.Widget _pdfKV(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.SizedBox(
              width: 130,
              child: pw.Text('$label:',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold))),
          pw.Expanded(
              child: pw.Text(value,
                  style: const pw.TextStyle(fontSize: 10))),
        ]),
      );

  String _fmtDt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtDtHora(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final actividades = ref.watch(actividadesProvider);
    final a = actividades.firstWhere((e) => e.id == widget.actividad.id,
        orElse: () => widget.actividad);
    final acta = a.acta;
    final asistentes = acta?.asistentes ?? [];
    final acuerdos = acta?.acuerdos ?? [];
    final now = DateTime.now();
    final presentes = asistentes.where((p) => p.asistio).length;
    final vencidos = acuerdos
        .where((ac) => !ac.completado && ac.fechaLimite.isBefore(now))
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cuerpo del acta ──────────────────────────────────────────
          Row(children: [
            const _SectionLabel('Cuerpo del acta'),
            const Spacer(),
            Text(
              a.actualizadoEn != null
                  ? 'Última edición · ${_fmtDtHora(a.actualizadoEn!)}'
                  : 'Sin modificaciones',
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 10, color: const Color(0xFFA8A29E)),
            ),
          ]),
          const SizedBox(height: 8),
          TextField(
            controller: _cuerpoCtrl,
            maxLines: 6,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF292524), height: 1.65),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFAFAF9),
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
              contentPadding: const EdgeInsets.all(14),
              hintText: 'Redacta el acta de la actividad…',
              hintStyle:
                  const TextStyle(color: Color(0xFFA8A29E), fontSize: 13),
            ),
          ),
          const SizedBox(height: 18),

          // ── Asistentes + Acuerdos ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asistentes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const _SectionLabel('Asistentes'),
                      const SizedBox(width: 8),
                      _Badge('$presentes/${asistentes.length} presentes',
                          bg: const Color(0xFFDCFCE7),
                          fg: const Color(0xFF15803D)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _showAddAsistenteDialog,
                        icon: const Icon(Icons.add,
                            size: 11, color: Color(0xFFC2410C)),
                        label: const Text('Añadir',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFC2410C))),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: const Color(0xFFE7E5E4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: asistentes.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Sin asistentes registrados',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFA8A29E))),
                            )
                          : Column(
                              children:
                                  asistentes.asMap().entries.map((entry) {
                                final i = entry.key;
                                final p = entry.value;
                                final initials = p.nombre
                                    .trim()
                                    .split(' ')
                                    .take(2)
                                    .map((s) => s.isNotEmpty
                                        ? s[0].toUpperCase()
                                        : '')
                                    .join();
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: i < asistentes.length - 1
                                        ? const Border(
                                            bottom: BorderSide(
                                                color:
                                                    Color(0xFFF5F5F4)))
                                        : null,
                                  ),
                                  child: Row(children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: p.asistio
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFF5F5F4),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(initials,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: p.asistio
                                                  ? const Color(
                                                      0xFF15803D)
                                                  : const Color(
                                                      0xFF78716C),
                                            )),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(p.nombre,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: Color(
                                                      0xFF1C1917))),
                                          Text(
                                            p.rut != null
                                                ? '${p.cargo} · ${p.rut}'
                                                : p.cargo,
                                            style:
                                                GoogleFonts.jetBrainsMono(
                                                    fontSize: 10,
                                                    color: const Color(
                                                        0xFF78716C)),
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    _AsistioToggle(
                                      asistio: p.asistio,
                                      onToggle: () =>
                                          _toggleAsistencia(i),
                                    ),
                                  ]),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),

              // Acuerdos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const _SectionLabel('Acuerdos'),
                      const SizedBox(width: 8),
                      if (vencidos > 0)
                        _Badge(
                            '$vencidos vencido${vencidos > 1 ? "s" : ""}',
                            bg: const Color(0xFFFFF7ED),
                            fg: const Color(0xFFC2410C)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _showAddAcuerdoDialog,
                        icon: const Icon(Icons.add,
                            size: 11, color: Color(0xFFC2410C)),
                        label: const Text('Nuevo acuerdo',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFC2410C))),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    acuerdos.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: const Color(0xFFE7E5E4)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Sin acuerdos registrados',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFA8A29E))),
                          )
                        : Column(
                            children: acuerdos.map((ac) {
                              final vencido = !ac.completado &&
                                  ac.fechaLimite.isBefore(now);
                              return GestureDetector(
                                onTap: () => _toggleAcuerdo(ac.id),
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: vencido
                                        ? const Color(0xFFFFF7ED)
                                        : Colors.white,
                                    border: Border.all(
                                        color: vencido
                                            ? const Color(0xFFFED7AA)
                                            : const Color(0xFFE7E5E4)),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        margin: const EdgeInsets.only(
                                            top: 1),
                                        decoration: BoxDecoration(
                                          color: ac.completado
                                              ? const Color(0xFF15803D)
                                              : Colors.white,
                                          border: Border.all(
                                            color: ac.completado
                                                ? const Color(
                                                    0xFF15803D)
                                                : const Color(
                                                    0xFFD6D3D1),
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: ac.completado
                                            ? const Icon(Icons.check,
                                                size: 11,
                                                color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ac.descripcion,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: ac.completado
                                                    ? FontWeight.w500
                                                    : FontWeight.w600,
                                                color: const Color(
                                                    0xFF1C1917),
                                                decoration: ac.completado
                                                    ? TextDecoration
                                                        .lineThrough
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(children: [
                                              const Icon(
                                                  Icons.people_outline,
                                                  size: 10.5,
                                                  color:
                                                      Color(0xFF78716C)),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                child: Text(
                                                    ac.responsable,
                                                    style: const TextStyle(
                                                        fontSize: 10.5,
                                                        color: Color(
                                                            0xFF78716C))),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text('·',
                                                  style: TextStyle(
                                                      color: Color(
                                                          0xFFD6D3D1))),
                                              const SizedBox(width: 8),
                                              Icon(
                                                  Icons
                                                      .access_time_outlined,
                                                  size: 10.5,
                                                  color: vencido
                                                      ? const Color(
                                                          0xFFC2410C)
                                                      : const Color(
                                                          0xFF78716C)),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${ac.fechaLimite.year}-${ac.fechaLimite.month.toString().padLeft(2, '0')}-${ac.fechaLimite.day.toString().padLeft(2, '0')}${vencido ? ' · vencido' : ''}',
                                                style: GoogleFonts
                                                    .jetBrainsMono(
                                                  fontSize: 10.5,
                                                  color: vencido
                                                      ? const Color(
                                                          0xFFC2410C)
                                                      : const Color(
                                                          0xFF78716C),
                                                  fontWeight: vencido
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                                ),
                                              ),
                                            ]),
                                          ],
                                        ),
                                      ),
                                    ],
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
          const SizedBox(height: 18),

          // ── Archivos adjuntos ────────────────────────────────────────
          if (a.adjuntos.isNotEmpty) ...[
            const _SectionLabel('Archivos adjuntos'),
            const SizedBox(height: 8),
            ...a.adjuntos.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    const Icon(Icons.attach_file_outlined,
                        size: 13, color: Color(0xFF78716C)),
                    const SizedBox(width: 6),
                    Text(f,
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 10.5,
                            color: const Color(0xFF78716C))),
                  ]),
                )),
            const SizedBox(height: 12),
          ],

          // ── Footer ───────────────────────────────────────────────────
          const Divider(height: 1, color: Color(0xFFE7E5E4)),
          const SizedBox(height: 12),
          Row(children: [
            Text(
              'Acta-${a.id.substring(0, 8)}-2026.pdf',
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5, color: const Color(0xFF78716C)),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _adjuntarArchivo,
              icon: const Icon(Icons.attach_file_outlined, size: 13),
              label: const Text('Adjuntar archivo',
                  style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF44403C),
                side: const BorderSide(
                    color: Color(0xFFE7E5E4), width: 1.5),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _exportarPDF,
              icon: const Icon(Icons.description_outlined, size: 13),
              label: const Text('Exportar PDF',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF78716C),
            letterSpacing: 0.06),
      );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Badge(this.label, {required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: fg)),
      );
}

class _AsistioToggle extends StatelessWidget {
  final bool asistio;
  final VoidCallback onToggle;
  const _AsistioToggle({required this.asistio, required this.onToggle});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: const Color(0xFFF5F5F4),
              borderRadius: BorderRadius.circular(6)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Pill(
                  label: 'Asistió',
                  icon: Icons.check,
                  active: asistio,
                  activeColor: const Color(0xFF15803D)),
              _Pill(
                  label: 'Ausente',
                  icon: Icons.close,
                  active: !asistio,
                  activeColor: const Color(0xFFB91C1C)),
            ],
          ),
        ),
      );
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  const _Pill(
      {required this.label,
      required this.icon,
      required this.active,
      required this.activeColor});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 10,
                color: active ? Colors.white : const Color(0xFF78716C)),
            const SizedBox(width: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? Colors.white
                        : const Color(0xFF78716C))),
          ],
        ),
      );
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  const _DialogField(
      {required this.controller,
      required this.label,
      required this.hint,
      this.maxLines = 1});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF44403C))),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style:
                const TextStyle(fontSize: 13, color: Color(0xFF1C1917)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Color(0xFFA8A29E), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFFAFAF9),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: Color(0xFFE7E5E4), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: Color(0xFFEA580C), width: 1.5),
              ),
            ),
          ),
        ],
      );
}
