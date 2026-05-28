import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared/shared.dart';
import '../../data/seed_data.dart';
import '../users/users_provider.dart';

class PdfExportService {
  static const _orange = PdfColor.fromInt(0xFFC2410C);
  static const _stone900 = PdfColor.fromInt(0xFF1C1917);
  static const _stone700 = PdfColor.fromInt(0xFF44403C);
  static const _stone500 = PdfColor.fromInt(0xFF78716C);
  static const _stone200 = PdfColor.fromInt(0xFFE7E5E4);
  static const _stone50 = PdfColor.fromInt(0xFFFAFAF9);

  // ── Fuente Unicode ────────────────────────────────────────────────────────────

  static Future<(pw.Font, pw.Font)> _loadFonts() async {
    try {
      return (
        await PdfGoogleFonts.notoSansRegular(),
        await PdfGoogleFonts.notoSansBold(),
      );
    } catch (_) {
      return (pw.Font.helvetica(), pw.Font.helveticaBold());
    }
  }

  // ── Carga del logo oficial de Seguridad Pública ──────────────────────────────

  static Future<pw.ImageProvider?> _loadLogoImage() async {
    final data = await rootBundle.load('assets/icon/seguridad logo naranjo.png');
    return pw.MemoryImage(data.buffer.asUint8List());
  }

  // ── Header / Footer comunes ───────────────────────────────────────────────────

  static pw.Widget _header(String date, String subtitle, {pw.ImageProvider? logo}) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _stone200, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          if (logo != null)
            pw.SizedBox(
              width: 38,
              height: 38,
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            )
          else
            pw.SizedBox(
              width: 38,
              height: 38,
              child: pw.CustomPaint(painter: _pdfEmblemPainter),
            ),
          pw.SizedBox(width: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('SIGESPU LOTA', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _stone900)),
              pw.Text(subtitle, style: const pw.TextStyle(fontSize: 7, color: _stone500)),
            ],
          ),
          pw.Spacer(),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('DOCUMENTO OFICIAL', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: _orange)),
              pw.Text(date, style: const pw.TextStyle(fontSize: 7, color: _stone500)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(String user, String date, int page, int total) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _stone200, width: 0.5)),
      ),
      child: pw.Row(children: [
        pw.Text('Generado por: $user  |  $date', style: const pw.TextStyle(fontSize: 7, color: _stone500)),
        pw.Spacer(),
        pw.Text('SIGESPU LOTA - DIRECCION DE SEGURIDAD PUBLICA', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey400)),
        pw.Spacer(),
        pw.Text('Pagina $page de $total', style: const pw.TextStyle(fontSize: 7, color: _stone500)),
      ]),
    );
  }

  static pw.Widget _sectionTitle(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: const pw.BoxDecoration(
        color: _orange,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
    );
  }

  static pw.Widget _kpiBox(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(right: 8),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _stone200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _orange)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: _stone500)),
      ]),
    );
  }

  // ── Exportar vista Mapa / Tabla ───────────────────────────────────────────────

  static Future<Uint8List> generateReport(
    List<ElementoMapa> elementos,
    String userName, {
    Map<String, String>? filterInfo,
    String title = 'REPORTE DE GESTION TERRITORIAL',
  }) async {
    final (fontR, fontB) = await _loadFonts();
    final logoImage = await _loadLogoImage().catchError((_) => null as pw.ImageProvider?);
    final pdf = pw.Document(theme: pw.ThemeData.withFont(base: fontR, bold: fontB));
    final now = DateTime.now();
    final dateStr = _fmtDate(now);

    final kpis = {
      'Reportes': elementos.where((e) => e.tipo.startsWith('reporte_')).length,
      'Zonas peligro': elementos.where((e) => e.tipo == 'zona_peligro').length,
      'Patentes': elementos.where((e) => e.tipo == 'patente').length,
      'C. Acopio': elementos.where((e) => e.tipo == 'centro_acopio').length,
      'Sedes': elementos.where((e) => e.tipo == 'sede_comunitaria').length,
    };

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (_) => _header(dateStr, 'Sistema de Informacion Geoespacial de Seguridad Publica', logo: logoImage),
      footer: (ctx) => _footer(userName, dateStr, ctx.pageNumber, ctx.pagesCount),
      build: (_) => [
        pw.SizedBox(height: 16),
        pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _stone900)),
        pw.SizedBox(height: 2),
        pw.Text('Direccion de Seguridad Publica  |  I. Municipalidad de Lota', style: const pw.TextStyle(fontSize: 9, color: _stone500)),
        pw.SizedBox(height: 16),
        if (filterInfo != null) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(color: _stone50, borderRadius: pw.BorderRadius.all(pw.Radius.circular(6))),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('CRITERIOS DE FILTRADO:', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: _stone700)),
              pw.SizedBox(height: 5),
              pw.Row(children: filterInfo.entries.map((f) => pw.Padding(
                padding: const pw.EdgeInsets.only(right: 18),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(f.key.toUpperCase(), style: const pw.TextStyle(fontSize: 6, color: _stone500)),
                  pw.Text(f.value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ]),
              )).toList()),
            ]),
          ),
          pw.SizedBox(height: 16),
        ],
        pw.Row(children: kpis.entries.map((e) => pw.Expanded(child: _kpiBox(e.key, '${e.value}'))).toList()),
        pw.SizedBox(height: 20),
        _sectionTitle('DETALLE DE ELEMENTOS  |  Total: ${elementos.length}'),
        _elementosTable(elementos),
      ],
    ));

    return pdf.save();
  }

  // ── Exportar vista Resumen ────────────────────────────────────────────────────

  static Future<Uint8List> generateResumenReport(
    List<ElementoMapa> elementos,
    String userName,
  ) async {
    final (fontR, fontB) = await _loadFonts();
    final logoImage = await _loadLogoImage().catchError((_) => null as pw.ImageProvider?);
    final pdf = pw.Document(theme: pw.ThemeData.withFont(base: fontR, bold: fontB));
    final now = DateTime.now();
    final dateStr = _fmtDate(now);

    final reportes    = elementos.where((e) => e.tipo.startsWith('reporte_')).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    final nReportes   = reportes.length;
    final nZonas      = elementos.where((e) => e.tipo == 'zona_peligro').length;
    final nAcopios    = elementos.where((e) => e.tipo == 'centro_acopio').length;
    final nSedes      = elementos.where((e) => e.tipo == 'sede_comunitaria').length;
    final nInfra      = elementos.where((e) => e.tipo == 'infraestructura').length;
    final nPatentes   = kPatentes.length;

    final robos       = reportes.where((e) => e.tipo == 'reporte_robo').length;
    final vandalismo  = reportes.where((e) => e.tipo == 'reporte_vandalismo').length;
    final accidentes  = reportes.where((e) => e.tipo == 'reporte_accidente').length;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (_) => _header(dateStr, 'Resumen Operativo - Sistema de Informacion Geoespacial', logo: logoImage),
      footer: (ctx) => _footer(userName, dateStr, ctx.pageNumber, ctx.pagesCount),
      build: (_) => [
        pw.SizedBox(height: 16),
        pw.Text('RESUMEN OPERATIVO', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _stone900)),
        pw.SizedBox(height: 2),
        pw.Text('Indicadores clave  |  Actualizado: $dateStr', style: const pw.TextStyle(fontSize: 9, color: _stone500)),
        pw.SizedBox(height: 16),

        // KPIs
        pw.Row(children: [
          pw.Expanded(child: _kpiBox('Reportes seguridad', '$nReportes')),
          pw.Expanded(child: _kpiBox('Zonas de peligro', '$nZonas')),
          pw.Expanded(child: _kpiBox('Centros de acopio', '$nAcopios')),
          pw.Expanded(child: _kpiBox('Sedes comunitarias', '$nSedes')),
          pw.Expanded(child: _kpiBox('Infraestructura', '$nInfra')),
        ]),
        pw.SizedBox(height: 8),
        pw.Row(children: [
          pw.Expanded(child: _kpiBox('Patentes en BD', '$nPatentes')),
          pw.Expanded(child: _kpiBox('Robos', '$robos')),
          pw.Expanded(child: _kpiBox('Vandalismo', '$vandalismo')),
          pw.Expanded(child: _kpiBox('Accidentes', '$accidentes')),
          pw.Expanded(child: pw.SizedBox()),
        ]),
        pw.SizedBox(height: 20),

        // Incidentes recientes
        _sectionTitle('ULTIMOS INCIDENTES Y REPORTES'),
        pw.SizedBox(height: 8),
        _reportesTable(reportes.take(15).toList()),
        pw.SizedBox(height: 20),

        // Zonas de peligro
        _sectionTitle('ZONAS DE PELIGRO ACTIVAS'),
        pw.SizedBox(height: 8),
        _zonasTable(elementos.where((e) => e.tipo == 'zona_peligro').toList()),
      ],
    ));

    return pdf.save();
  }

  // ── Exportar vista Scraping ───────────────────────────────────────────────────

  static Future<Uint8List> generateScrapingReport(
    String userName, {
    List<DatoPatente>? patentes,
    List<DatoPermiso>? permisos,
    List<DatoOrganizacion>? orgs,
  }) async {
    final p = patentes ?? kPatentes;
    final pe = permisos ?? kPermisos;
    final o = orgs ?? kOrganizaciones;

    final (fontR, fontB) = await _loadFonts();
    final logoImage = await _loadLogoImage().catchError((_) => null as pw.ImageProvider?);
    final pdf = pw.Document(theme: pw.ThemeData.withFont(base: fontR, bold: fontB));
    final now = DateTime.now();
    final dateStr = _fmtDate(now);

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (_) => _header(dateStr, 'Datos de Transparencia Municipal - lotatransparente.cl', logo: logoImage),
      footer: (ctx) => _footer(userName, dateStr, ctx.pageNumber, ctx.pagesCount),
      build: (_) => [
        pw.SizedBox(height: 16),
        pw.Text('DATOS SCRAPING - TRANSPARENCIA MUNICIPAL', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: _stone900)),
        pw.SizedBox(height: 2),
        pw.Text('Fuente: lotatransparente.cl  |  Extraido: $dateStr', style: const pw.TextStyle(fontSize: 9, color: _stone500)),
        pw.SizedBox(height: 6),

        // KPIs scraping
        pw.Row(children: [
          pw.Expanded(child: _kpiBox('Patentes comerciales', '${p.length}')),
          pw.Expanded(child: _kpiBox('Permisos DOM', '${pe.length}')),
          pw.Expanded(child: _kpiBox('Organizaciones sociales', '${o.length}')),
        ]),
        pw.SizedBox(height: 20),

        _sectionTitle('PATENTES COMERCIALES  |  ${p.length} registros'),
        _patentesTable(p),
        pw.SizedBox(height: 16),

        _sectionTitle('PERMISOS DIRECCION DE OBRAS  |  ${pe.length} registros'),
        _permisosTable(pe),
        pw.SizedBox(height: 16),

        _sectionTitle('ORGANIZACIONES SOCIALES  |  ${o.length} registros'),
        _organizacionesTable(o),
      ],
    ));

    return pdf.save();
  }

  // ── Exportar vista Usuarios ───────────────────────────────────────────────────

  static Future<Uint8List> generateUsuariosReport(
    String userName, {
    List<UsuarioItem> usuarios = const [],
  }) async {
    final (fontR, fontB) = await _loadFonts();
    final logoImage = await _loadLogoImage().catchError((_) => null as pw.ImageProvider?);
    final pdf = pw.Document(theme: pw.ThemeData.withFont(base: fontR, bold: fontB));
    final now = DateTime.now();
    final dateStr = _fmtDate(now);

    final activos    = usuarios.where((u) => u.activo).length;
    final directores = usuarios.where((u) => u.nivelAcceso == 'director').length;
    final operativos = usuarios.where((u) => u.nivelAcceso == 'operativo').length;
    final visitantes = usuarios.where((u) => u.nivelAcceso == 'visitante').length;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (_) => _header(dateStr, 'Gestion de Usuarios - Sistema de Informacion Geoespacial', logo: logoImage),
      footer: (ctx) => _footer(userName, dateStr, ctx.pageNumber, ctx.pagesCount),
      build: (_) => [
        pw.SizedBox(height: 16),
        pw.Text('MODULO DE USUARIOS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _stone900)),
        pw.SizedBox(height: 2),
        pw.Text('Listado de funcionarios municipales registrados en el sistema.', style: const pw.TextStyle(fontSize: 9, color: _stone500)),
        pw.SizedBox(height: 16),
        pw.Row(children: [
          pw.Expanded(child: _kpiBox('Usuarios activos', '$activos')),
          pw.Expanded(child: _kpiBox('Total registrados', '${usuarios.length}')),
          pw.Expanded(child: _kpiBox('Directores', '$directores')),
          pw.Expanded(child: _kpiBox('Operativos', '$operativos')),
          pw.Expanded(child: _kpiBox('Visitantes', '$visitantes')),
        ]),
        pw.SizedBox(height: 20),
        if (usuarios.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _stone50,
              border: pw.Border.all(color: _stone200),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Text(
              'Conecte el sistema al servidor para obtener el listado actualizado de usuarios.',
              style: const pw.TextStyle(fontSize: 10, color: _stone500),
            ),
          )
        else ...[
          _sectionTitle('LISTADO DE USUARIOS  |  ${usuarios.length} registros'),
          _usuariosTable(usuarios),
        ],
      ],
    ));

    return pdf.save();
  }

  // ── Exportar acta individual de actividad ─────────────────────────────────────

  static Future<Uint8List> generateActaReport(
    ActividadMunicipal actividad,
    String userName,
  ) async {
    final (fontR, fontB) = await _loadFonts();
    final logoImage = await _loadLogoImage().catchError((_) => null as pw.ImageProvider?);
    final pdf = pw.Document(theme: pw.ThemeData.withFont(base: fontR, bold: fontB));
    final now = DateTime.now();
    final dateStr = _fmtDate(now);
    final a = actividad;

    String tipoLabel(TipoActividad t) => switch (t) {
      TipoActividad.reunion      => 'Reunion',
      TipoActividad.operativo    => 'Operativo',
      TipoActividad.evento       => 'Evento',
      TipoActividad.capacitacion => 'Capacitacion',
    };

    String estadoLabel(EstadoActividad e) => switch (e) {
      EstadoActividad.planificado => 'Planificado',
      EstadoActividad.enCurso     => 'En curso',
      EstadoActividad.completado  => 'Completado',
      EstadoActividad.archivado   => 'Archivado',
    };

    String fmtDt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    String fmtDtHora(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    pw.Widget kvRow(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.SizedBox(
          width: 140,
          child: pw.Text('$label:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _stone700)),
        ),
        pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 10))),
      ]),
    );

    pw.Widget firmaBox(String cargo) => pw.Column(children: [
      pw.Container(
        width: 180,
        height: 40,
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _stone500, width: 0.8)),
        ),
      ),
      pw.SizedBox(height: 6),
      pw.Text(cargo, style: const pw.TextStyle(fontSize: 9, color: _stone500), textAlign: pw.TextAlign.center),
    ]);

    pw.Widget labelChip(String text, PdfColor bg, PdfColor fg) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: fg)),
    );

    final secNum = (a.direccion != null || a.lat != null) ? '3' : '2';

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (_) => _header(dateStr, 'Acta de Actividad Municipal', logo: logoImage),
      footer: (ctx) => _footer(userName, dateStr, ctx.pageNumber, ctx.pagesCount),
      build: (_) => [
        pw.SizedBox(height: 16),
        pw.Text(
          a.titulo,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _stone900),
        ),
        pw.SizedBox(height: 8),
        pw.Row(children: [
          labelChip(tipoLabel(a.tipo), const PdfColor.fromInt(0xFFFFF7ED), _orange),
          pw.SizedBox(width: 6),
          labelChip(estadoLabel(a.estado), _stone50, _stone700),
          if (a.sector != null) ...[
            pw.SizedBox(width: 6),
            labelChip(a.sector!, _stone50, _stone700),
          ],
        ]),
        pw.SizedBox(height: 18),

        _sectionTitle('1. DATOS GENERALES'),
        pw.SizedBox(height: 8),
        kvRow('Descripcion', a.descripcion.isNotEmpty ? a.descripcion : '—'),
        kvRow('Tipo de actividad', tipoLabel(a.tipo)),
        kvRow('Estado', estadoLabel(a.estado)),
        kvRow('Fecha de inicio', fmtDtHora(a.fechaInicio)),
        if (a.fechaFin != null) kvRow('Fecha de termino', fmtDtHora(a.fechaFin!)),
        if (a.direccionMunicipal != null) kvRow('Direccion municipal', a.direccionMunicipal!),
        if (a.presupuestoEstimado != null)
          kvRow('Presupuesto estimado', '\$${a.presupuestoEstimado!.toStringAsFixed(0)}'),
        kvRow('Registrado por', a.creadoPor),
        kvRow('Fecha de registro', fmtDtHora(a.creadoEn)),
        if (a.actualizadoEn != null) kvRow('Ultima modificacion', fmtDtHora(a.actualizadoEn!)),
        pw.SizedBox(height: 16),

        if (a.direccion != null || a.lat != null) ...[
          _sectionTitle('2. UBICACION'),
          pw.SizedBox(height: 8),
          if (a.direccion != null) kvRow('Direccion', a.direccion!),
          if (a.sector != null) kvRow('Sector', a.sector!),
          if (a.lat != null && a.lng != null)
            kvRow('Coordenadas', '${a.lat!.toStringAsFixed(6)}, ${a.lng!.toStringAsFixed(6)}'),
          pw.SizedBox(height: 16),
        ],

        _sectionTitle('$secNum. CUERPO DEL ACTA'),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: _stone50,
            border: pw.Border.all(color: _stone200, width: 0.5),
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

        if ((a.acta?.asistentes ?? []).isNotEmpty) ...[
          _sectionTitle('ASISTENTES (${a.acta!.asistentes.length})'),
          pw.SizedBox(height: 8),
          _table(
            ['N', 'NOMBRE', 'CARGO', 'RUT', 'ASISTENCIA'],
            a.acta!.asistentes.asMap().entries.map((e) => [
              '${e.key + 1}',
              e.value.nombre,
              e.value.cargo,
              e.value.rut ?? '—',
              e.value.asistio ? 'Asistio' : 'Ausente',
            ]).toList(),
            widths: [0.4, 2.5, 1.8, 1.2, 0.9],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${a.acta!.asistentes.where((p) => p.asistio).length} de ${a.acta!.asistentes.length} presentes.',
            style: const pw.TextStyle(fontSize: 8.5, color: _stone500),
          ),
          pw.SizedBox(height: 16),
        ],

        if ((a.acta?.acuerdos ?? []).isNotEmpty) ...[
          _sectionTitle('ACUERDOS Y COMPROMISOS (${a.acta!.acuerdos.length})'),
          pw.SizedBox(height: 8),
          _table(
            ['N', 'DESCRIPCION', 'RESPONSABLE', 'FECHA LIMITE', 'ESTADO'],
            a.acta!.acuerdos.asMap().entries.map((e) {
              final ac = e.value;
              final vencido = !ac.completado && ac.fechaLimite.isBefore(DateTime.now());
              return [
                '${e.key + 1}',
                ac.descripcion,
                ac.responsable,
                fmtDt(ac.fechaLimite),
                ac.completado ? 'Completado' : vencido ? 'Vencido' : 'Pendiente',
              ];
            }).toList(),
            widths: [0.4, 2.5, 1.5, 1.2, 1.0],
          ),
          pw.SizedBox(height: 16),
        ],

        if (a.adjuntos.isNotEmpty) ...[
          _sectionTitle('ARCHIVOS ADJUNTOS'),
          pw.SizedBox(height: 6),
          ...a.adjuntos.asMap().entries.map((e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Text('${e.key + 1}. ${e.value}', style: const pw.TextStyle(fontSize: 10)),
          )),
          pw.SizedBox(height: 16),
        ],

        pw.SizedBox(height: 24),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            firmaBox('Director/a de Seguridad Publica'),
            firmaBox('Responsable de la actividad'),
          ],
        ),
      ],
    ));

    return pdf.save();
  }

  // ── Exportar vista Actividades ────────────────────────────────────────────────

  static Future<Uint8List> generateActividadesReport(
    List<ActividadMunicipal> actividades,
    String userName,
  ) async {
    final (fontR, fontB) = await _loadFonts();
    final logoImage = await _loadLogoImage().catchError((_) => null as pw.ImageProvider?);
    final pdf = pw.Document(theme: pw.ThemeData.withFont(base: fontR, bold: fontB));
    final now = DateTime.now();
    final dateStr = _fmtDate(now);

    final planificadas = actividades.where((a) => a.estado == EstadoActividad.planificado).length;
    final enCurso      = actividades.where((a) => a.estado == EstadoActividad.enCurso).length;
    final completadas  = actividades.where((a) => a.estado == EstadoActividad.completado).length;
    final archivadas   = actividades.where((a) => a.estado == EstadoActividad.archivado).length;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (_) => _header(dateStr, 'Tablero de Actividades Municipales', logo: logoImage),
      footer: (ctx) => _footer(userName, dateStr, ctx.pageNumber, ctx.pagesCount),
      build: (_) => [
        pw.SizedBox(height: 16),
        pw.Text('ACTIVIDADES MUNICIPALES',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _stone900)),
        pw.SizedBox(height: 2),
        pw.Text('Tablero kanban  |  Total: ${actividades.length} actividades',
            style: const pw.TextStyle(fontSize: 9, color: _stone500)),
        pw.SizedBox(height: 16),
        pw.Row(children: [
          pw.Expanded(child: _kpiBox('Planificadas', '$planificadas')),
          pw.Expanded(child: _kpiBox('En curso', '$enCurso')),
          pw.Expanded(child: _kpiBox('Completadas', '$completadas')),
          pw.Expanded(child: _kpiBox('Archivadas', '$archivadas')),
        ]),
        pw.SizedBox(height: 20),
        _sectionTitle('DETALLE DE ACTIVIDADES  |  Total: ${actividades.length}'),
        _actividadesTable(actividades),
      ],
    ));

    return pdf.save();
  }

  // ── Tablas auxiliares ─────────────────────────────────────────────────────────

  static pw.Widget _elementosTable(List<ElementoMapa> elementos) {
    final headers = ['TIPO', 'NOMBRE', 'DIRECCION', 'SECTOR', 'ESTADO', 'FECHA'];
    final rows = elementos.map((e) => [
      e.tipo.replaceAll('_', ' ').toUpperCase(),
      e.nombre,
      e.direccion,
      e.sector,
      e.estado.toUpperCase(),
      e.fecha,
    ]).toList();
    return _table(headers, rows, widths: [1.2, 2.5, 2.0, 0.8, 0.9, 1.0]);
  }

  static pw.Widget _reportesTable(List<ElementoMapa> reportes) {
    final headers = ['TIPO', 'DESCRIPCION', 'DIRECCION', 'ESTADO', 'FECHA', 'REGISTRADO POR'];
    final rows = reportes.map((e) => [
      e.tipo.replaceAll('reporte_', '').toUpperCase(),
      e.nombre,
      e.direccion,
      e.estado.toUpperCase(),
      e.fecha,
      e.by,
    ]).toList();
    return _table(headers, rows, widths: [1.0, 2.4, 2.0, 0.9, 1.0, 1.6]);
  }

  static pw.Widget _zonasTable(List<ElementoMapa> zonas) {
    if (zonas.isEmpty) {
      return pw.Text('Sin zonas de peligro registradas.', style: const pw.TextStyle(fontSize: 8, color: _stone500));
    }
    final headers = ['NOMBRE', 'TIPO PELIGRO', 'NIVEL', 'SECTOR', 'HORARIO', 'VIGENCIA'];
    final rows = zonas.map((e) => [
      e.nombre,
      e.tipoPeligro ?? '-',
      '${e.nivel ?? '-'}/5',
      e.sector,
      e.horario ?? '-',
      e.vigenciaHasta ?? 'Indefinida',
    ]).toList();
    return _table(headers, rows, widths: [2.2, 1.2, 0.6, 0.7, 1.5, 1.0]);
  }

  static pw.Widget _patentesTable(List<DatoPatente> patentes) {
    final headers = ['N.DECRETO', 'RAZON SOCIAL', 'GIRO', 'DIRECCION', 'FECHA', 'TIPO'];
    final rows = patentes.map((p) => [
      '${p.nDecreto}',
      p.razonSocial,
      p.giro,
      p.direccion,
      p.fechaDecreto,
      p.tipo,
    ]).toList();
    return _table(headers, rows, widths: [0.9, 2.4, 2.2, 1.8, 1.0, 1.2]);
  }

  static pw.Widget _permisosTable(List<DatoPermiso> permisos) {
    final headers = ['N.PERMISO', 'TIPO', 'DESCRIPCION', 'DIRECCION', 'FECHA', 'ESTADO'];
    final rows = permisos.map((p) => [
      p.nPermiso,
      p.tipo,
      p.descripcion,
      p.direccion,
      p.fecha,
      p.estado.toUpperCase(),
    ]).toList();
    return _table(headers, rows, widths: [1.2, 1.4, 2.2, 1.8, 1.0, 0.9]);
  }

  static pw.Widget _organizacionesTable(List<DatoOrganizacion> orgs) {
    final headers = ['N.PERSONALIDAD', 'TIPO', 'NOMBRE', 'REPRESENTANTE', 'SECTOR', 'VIGENCIA'];
    final rows = orgs.map((o) => [
      o.nPersonalidad,
      o.tipo,
      o.nombre,
      o.representante,
      o.sector,
      o.vigencia,
    ]).toList();
    return _table(headers, rows, widths: [1.2, 1.4, 2.2, 2.0, 0.7, 1.8]);
  }

  static pw.Widget _usuariosTable(List<UsuarioItem> usuarios) {
    final headers = ['NOMBRE', 'EMAIL', 'ROL', 'UNIDAD', 'CARGO', 'ESTADO'];
    final rows = usuarios.map((u) => [
      u.nombre,
      u.email,
      u.nivelAcceso.toUpperCase(),
      u.unidad,
      u.cargo ?? '—',
      u.activo ? 'Activo' : 'Inactivo',
    ]).toList();
    return _table(headers, rows, widths: [2.0, 2.5, 0.9, 1.5, 1.2, 0.8]);
  }

  static pw.Widget _actividadesTable(List<ActividadMunicipal> actividades) {
    if (actividades.isEmpty) {
      return pw.Text('Sin actividades en el rango seleccionado.',
          style: const pw.TextStyle(fontSize: 8, color: _stone500));
    }
    final headers = ['TITULO', 'TIPO', 'ESTADO', 'DEPARTAMENTO', 'FECHA INICIO', 'FECHA FIN'];
    String fmtD(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final rows = actividades.map((a) => <String>[
      a.titulo,
      a.tipo.name.toUpperCase(),
      a.estado.name.toUpperCase(),
      a.direccionMunicipal ?? '-',
      fmtD(a.fechaInicio),
      a.fechaFin != null ? fmtD(a.fechaFin!) : '-',
    ]).toList();
    return _table(headers, rows, widths: [3.0, 1.0, 1.0, 1.0, 1.2, 1.2]);
  }

  static pw.Widget _table(
    List<String> headers,
    List<List<String>> rows, {
    required List<double> widths,
  }) {
    final colWidths = {
      for (int i = 0; i < widths.length; i++) i: pw.FlexColumnWidth(widths[i]),
    };
    return pw.Table(
      border: pw.TableBorder.all(color: _stone200, width: 0.3),
      columnWidths: colWidths,
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _stone50),
          children: headers.map((h) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: pw.Text(h, style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: _stone700)),
          )).toList(),
        ),
        ...rows.map((row) => pw.TableRow(
          children: row.map((cell) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            child: pw.Text(cell, style: const pw.TextStyle(fontSize: 7, color: _stone900)),
          )).toList(),
        )),
      ],
    );
  }

  // ── Utilidades ────────────────────────────────────────────────────────────────

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}  '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// ── Emblem painter para PDF ───────────────────────────────────────────────────
// pw.CustomPainter es un typedef void Function(PdfGraphics, PdfPoint) — no es clase.
// Coordenadas PDF: origen abajo-izquierda, Y crece hacia arriba (invertido vs Flutter).

void _pdfEmblemPainter(PdfGraphics canvas, PdfPoint size) {
  final s = size.x / 64;

  // Badge oscuro de fondo
  canvas.setFillColor(const PdfColor.fromInt(0xFF1C1917));
  canvas.drawRect(0, 0, size.x, size.y);
  canvas.fillPath();

  // Sol — Flutter (32,22) top-down → PDF (32,42) bottom-up
  canvas.setFillColor(PdfColor.fromInt(0xFFF97316));
  canvas.drawEllipse(32 * s, 42 * s, 6 * s, 6 * s);
  canvas.fillPath();

  canvas.setLineCap(PdfLineCap.round);

  // Arco 1 — sandLight 55%
  // Flutter Q(10,42)→ctrl(32,30)→(54,42), Y invertido → Q(10,22)→ctrl(32,34)→(54,22)
  // Cuadrático→cúbico: cp1=(24.67,30) cp2=(39.33,30)
  canvas.setStrokeColor(PdfColor.fromInt(0x8CFED7AA));
  canvas.setLineWidth(2.2 * s);
  canvas.moveTo(10 * s, 22 * s);
  canvas.curveTo(24.67 * s, 30 * s, 39.33 * s, 30 * s, 54 * s, 22 * s);
  canvas.strokePath();

  // Arco 2 — sandLight 80%
  // Flutter Q(10,48)→ctrl(32,34)→(54,48), Y invertido → Q(10,16)→ctrl(32,30)→(54,16)
  // cp1=(24.67,25.33) cp2=(39.33,25.33)
  canvas.setStrokeColor(PdfColor.fromInt(0xCCFED7AA));
  canvas.setLineWidth(2.6 * s);
  canvas.moveTo(10 * s, 16 * s);
  canvas.curveTo(24.67 * s, 25.33 * s, 39.33 * s, 25.33 * s, 54 * s, 16 * s);
  canvas.strokePath();

  // Arco 3 — acento naranja
  // Flutter Q(6,54)→ctrl(32,38)→(58,54), Y invertido → Q(6,10)→ctrl(32,26)→(58,10)
  // cp1=(23.33,20.67) cp2=(40.67,20.67)
  canvas.setStrokeColor(PdfColor.fromInt(0xFFEA580C));
  canvas.setLineWidth(3 * s);
  canvas.moveTo(6 * s, 10 * s);
  canvas.curveTo(23.33 * s, 20.67 * s, 40.67 * s, 20.67 * s, 58 * s, 10 * s);
  canvas.strokePath();
}
