import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/seed_data.dart';

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

  // ── Header / Footer comunes ───────────────────────────────────────────────────

  static pw.Widget _header(String date, String subtitle) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _stone200, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 38, height: 38,
            decoration: const pw.BoxDecoration(color: _stone700, shape: pw.BoxShape.circle),
            child: pw.Center(
              child: pw.Text('L', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 16)),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Container(
            width: 38, height: 38,
            decoration: const pw.BoxDecoration(
              color: _orange,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Center(
              child: pw.Text('S', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 16)),
            ),
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
      header: (_) => _header(dateStr, 'Sistema de Informacion Geoespacial de Seguridad Publica'),
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
      header: (_) => _header(dateStr, 'Resumen Operativo - Sistema de Informacion Geoespacial'),
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
    List<DatoTransito>? transito,
    List<DatoOrganizacion>? orgs,
  }) async {
    final p = patentes ?? kPatentes;
    final pe = permisos ?? kPermisos;
    final t = transito ?? kTransito;
    final o = orgs ?? kOrganizaciones;

    final (fontR, fontB) = await _loadFonts();
    final pdf = pw.Document(theme: pw.ThemeData.withFont(base: fontR, bold: fontB));
    final now = DateTime.now();
    final dateStr = _fmtDate(now);

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (_) => _header(dateStr, 'Datos de Transparencia Municipal - lotatransparente.cl'),
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
          pw.Expanded(child: _kpiBox('Decretos transito', '${t.length}')),
          pw.Expanded(child: _kpiBox('Organizaciones sociales', '${o.length}')),
        ]),
        pw.SizedBox(height: 20),

        _sectionTitle('PATENTES COMERCIALES  |  ${p.length} registros'),
        _patentesTable(p),
        pw.SizedBox(height: 16),

        _sectionTitle('PERMISOS DIRECCION DE OBRAS  |  ${pe.length} registros'),
        _permisosTable(pe),
        pw.SizedBox(height: 16),

        _sectionTitle('DECRETOS DE TRANSITO  |  ${t.length} registros'),
        _transitoTable(t),
        pw.SizedBox(height: 16),

        _sectionTitle('ORGANIZACIONES SOCIALES  |  ${o.length} registros'),
        _organizacionesTable(o),
      ],
    ));

    return pdf.save();
  }

  // ── Exportar vista Usuarios ───────────────────────────────────────────────────

  static Future<Uint8List> generateUsuariosReport(String userName) async {
    final (fontR, fontB) = await _loadFonts();
    final pdf = pw.Document(theme: pw.ThemeData.withFont(base: fontR, bold: fontB));
    final now = DateTime.now();
    final dateStr = _fmtDate(now);

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _header(dateStr, 'Gestion de Usuarios - Sistema de Informacion Geoespacial'),
          pw.SizedBox(height: 24),
          pw.Text('MODULO DE USUARIOS', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: _stone900)),
          pw.SizedBox(height: 6),
          pw.Text('Este modulo exporta el listado de funcionarios municipales registrados en el sistema.', style: const pw.TextStyle(fontSize: 10, color: _stone700)),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _stone50,
              border: pw.Border.all(color: _stone200),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Text(
              'Conecte el sistema al servidor para obtener el listado actualizado de usuarios.\n\nGenerado por: $userName  |  $dateStr',
              style: const pw.TextStyle(fontSize: 10, color: _stone500),
            ),
          ),
          pw.Spacer(),
          _footer(userName, dateStr, 1, 1),
        ],
      ),
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

  static pw.Widget _transitoTable(List<DatoTransito> transito) {
    final headers = ['N.DECRETO', 'TIPO', 'DIRECCION', 'MOTIVO', 'INICIO', 'FIN', 'ESTADO'];
    final rows = transito.map((t) => [
      t.nDecreto,
      t.tipo,
      t.direccion,
      t.motivo,
      t.fechaInicio,
      t.fechaFin,
      t.estado.toUpperCase(),
    ]).toList();
    return _table(headers, rows, widths: [1.2, 1.5, 2.0, 1.8, 0.9, 0.9, 0.9]);
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
