import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/seed_data.dart';

class PdfExportService {
  static const orangeColor = PdfColor.fromInt(0xFFC2410C); // Naranja Dark (orange 700)
  static const blueColor = PdfColor.fromInt(0xFF1E3A8A);

  static Future<Uint8List> generateReport(
    List<ElementoMapa> elementos,
    String userName, {
    Map<String, String>? filterInfo,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final kpis = {
      'Reportes': elementos.where((e) => e.tipo.startsWith('reporte_')).length,
      'Zonas peligro': elementos.where((e) => e.tipo == 'zona_peligro').length,
      'Patentes': elementos.where((e) => e.tipo == 'patente').length,
      'C. Acopio': elementos.where((e) => e.tipo == 'centro_acopio').length,
      'Sedes': elementos.where((e) => e.tipo == 'sede_comunitaria').length,
    };

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => _buildHeader(dateStr),
        footer: (ctx) =>
            _buildFooter(userName, dateStr, ctx.pageNumber, ctx.pagesCount),
        build: (_) => [
          pw.SizedBox(height: 20),
          // Título del reporte
          pw.Text(
            'REPORTE DE GESTIÓN TERRITORIAL',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: blueColor,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Dirección de Seguridad Pública · I. Municipalidad de Lota',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),

          // Metadatos de Filtros
          if (filterInfo != null) _buildFilterInfo(filterInfo),
          pw.SizedBox(height: 20),

          // KPIs
          pw.Row(
            children: kpis.entries
                .map((e) => pw.Expanded(child: _buildKpiCard(e.key, '${e.value}')))
                .toList(),
          ),
          pw.SizedBox(height: 24),

          // Título tabla
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: const pw.BoxDecoration(
              color: orangeColor,
              borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(6)),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  'DETALLE DE ELEMENTOS FILTRADOS',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  'Total: ${elementos.length}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          _buildTable(elementos),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String date) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          // Logo Municipalidad (Simulado)
          pw.Container(
            width: 42,
            height: 42,
            decoration: const pw.BoxDecoration(color: blueColor, shape: pw.BoxShape.circle),
            child: pw.Center(
              child: pw.Text('L', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 18)),
            ),
          ),
          pw.SizedBox(width: 8),
          // Logo SIGESPU (Simulado)
          pw.Container(
            width: 42,
            height: 42,
            decoration: const pw.BoxDecoration(
              color: orangeColor,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Center(
              child: pw.Text('S', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 18)),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SIGESPU LOTA',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: blueColor),
              ),
              pw.Text(
                'Sistema de Gestión de Seguridad Pública',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('DOCUMENTO OFICIAL', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: orangeColor)),
              pw.Text(date, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFilterInfo(Map<String, String> filters) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('CRITERIOS DE FILTRADO:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
          pw.SizedBox(height: 6),
          pw.Row(
            children: filters.entries.map((f) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(right: 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(f.key.toUpperCase(), style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey500)),
                    pw.Text(f.value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildKpiCard(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(right: 8),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: PdfColors.white,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: orangeColor,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(List<ElementoMapa> elementos) {
    final headers = ['TIPO', 'NOMBRE / DESCRIPCIÓN', 'DIRECCIÓN', 'SECTOR', 'ESTADO', 'VIGENCIA', 'FECHA'];
    final rows = elementos.map((e) {
      String cap(String s, int max) =>
          s.length > max ? '${s.substring(0, max - 1)}…' : s;
      return [
        cap(e.tipo.replaceAll('_', ' ').toUpperCase(), 15),
        cap(e.nombre, 30),
        cap(e.direccion, 25),
        e.sector,
        e.estado.toUpperCase(),
        e.vigenciaHasta ?? '-',
        e.fecha,
      ];
    }).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.3),
      columnWidths: {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(2.5),
        2: pw.FlexColumnWidth(2.0),
        3: pw.FlexColumnWidth(0.8),
        4: pw.FlexColumnWidth(0.8),
        5: pw.FlexColumnWidth(1.0),
        6: pw.FlexColumnWidth(1.0),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey50),
          children: headers
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                  child: pw.Text(
                    h,
                    style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                  ),
                ),
              )
              .toList(),
        ),
        ...rows.map(
          (row) => pw.TableRow(
            children: row
                .map(
                  (cell) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: pw.Text(cell, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey900)),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(
      String user, String date, int page, int total) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            'Generado por: $user · $date',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
          ),
          pw.Spacer(),
          pw.Text(
            'SIGESPU LOTA - DIRECCIÓN DE SEGURIDAD PÚBLICA',
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey400),
          ),
          pw.Spacer(),
          pw.Text(
            'Página $page de $total',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }
}
