import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../providers/map_providers.dart';
import '../providers/visor_provider.dart';
import '../../../config/map_config.dart';

class PanelImprimir extends ConsumerStatefulWidget {
  final GlobalKey mapKey;
  const PanelImprimir({super.key, required this.mapKey});

  @override
  ConsumerState<PanelImprimir> createState() => _PanelImprimirState();
}

class _PanelImprimirState extends ConsumerState<PanelImprimir> {
  final _titleCtrl = TextEditingController(text: 'Mapa de Lota');
  String _layout = 'A4';
  bool _printing = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2327),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exportar mapa PDF',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Título del mapa',
              labelStyle: const TextStyle(color: Colors.white38, fontSize: 11),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white12),
                borderRadius: BorderRadius.circular(6),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFEA580C)),
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['Letter', 'A4'].map((l) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(l, style: const TextStyle(fontSize: 11)),
                  selected: _layout == l,
                  onSelected: (_) => setState(() => _layout = l),
                  selectedColor: const Color(0xFFEA580C),
                  labelStyle: TextStyle(
                    color: _layout == l ? Colors.white : Colors.white54,
                  ),
                  backgroundColor: const Color(0xFF2A2F35),
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _printing ? null : _print,
              icon: _printing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf, size: 16),
              label: Text(_printing ? 'Generando...' : 'Exportar PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _print() async {
    setState(() => _printing = true);
    try {
      final boundary = widget.mapKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final activeLayers = ref.read(activeLayersProvider);
      final sismosVisible = ref.read(sismosVisibleProvider);

      final legendItems = MapLayerConfig.layers
          .where((l) => activeLayers.contains(l.$1))
          .toList();
      if (sismosVisible) {
        legendItems.add(('sismos', 'Sismos recientes', const Color(0xFFE53935)));
      }

      final now = DateTime.now();
      final dateStr =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}  '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // Auto-detectar orientación según proporciones del mapa capturado.
      // En móvil el mapa es portrait → PDF portrait para evitar márgenes blancos.
      final isPortraitCapture = image.height > image.width;
      final baseFormat = _layout == 'A4' ? PdfPageFormat.a4 : PdfPageFormat.letter;
      final pageFormat = isPortraitCapture ? baseFormat : baseFormat.landscape;

      // ── Fuente Unicode (soporta español y símbolos especiales) ────────────
      pw.Font fontRegular;
      pw.Font fontBold;
      try {
        fontRegular = await PdfGoogleFonts.notoSansRegular();
        fontBold = await PdfGoogleFonts.notoSansBold();
      } catch (_) {
        fontRegular = pw.Font.helvetica();
        fontBold = pw.Font.helveticaBold();
      }

      // ── PDF color palette ──────────────────────────────────────────────────
      final orange = PdfColor.fromHex('EA580C');
      final orangeLight = PdfColor.fromHex('FFEDD5');
      final stone500 = PdfColor.fromHex('78716C');
      final stone700 = PdfColor.fromHex('44403C');
      final stone200 = PdfColor.fromHex('E7E5E4');
      final stone50 = PdfColor.fromHex('FAFAF9');

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
      );
      final pdfImage = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(32),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ── Header naranja ─────────────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: orange,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            _titleCtrl.text.isEmpty
                                ? 'Mapa SIGESPU Lota'
                                : _titleCtrl.text,
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Sistema de Información Geoespacial de Seguridad Pública',
                            style: pw.TextStyle(
                                color: orangeLight, fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'I. Municipalidad de Lota',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Dirección de Seguridad Pública',
                          style: pw.TextStyle(
                              color: orangeLight, fontSize: 7),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Generado: $dateStr',
                          style: pw.TextStyle(
                              color: orangeLight, fontSize: 7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ── Imagen del mapa ────────────────────────────────────────────
              pw.Expanded(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: stone200, width: 1),
                  ),
                  child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
                ),
              ),

              // ── Leyenda capas activas ──────────────────────────────────────
              if (legendItems.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: stone50,
                    border: pw.Border(
                      top: pw.BorderSide(
                          color: orange, width: 2),
                      left: pw.BorderSide(color: stone200, width: 1),
                      right: pw.BorderSide(color: stone200, width: 1),
                      bottom: pw.BorderSide(color: stone200, width: 1),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'LEYENDA - CAPAS ACTIVAS',
                        style: pw.TextStyle(
                          color: stone500,
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      ..._buildLegendRows(legendItems, stone700),
                    ],
                  ),
                ),
              ],

              pw.SizedBox(height: 6),

              // ── Footer ─────────────────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'SIGESPU Lota  |  Dirección de Seguridad Pública, I. Municipalidad de Lota',
                    style: pw.TextStyle(color: stone500, fontSize: 7),
                  ),
                  pw.Text(
                    'Lota, Región del Biobío, Chile',
                    style: pw.TextStyle(color: stone500, fontSize: 7),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (_) async => pdf.save());
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  List<pw.Widget> _buildLegendRows(
    List<(String, String, Color)> items,
    PdfColor textColor,
  ) {
    const itemsPerRow = 5;
    final rows = <pw.Widget>[];

    for (int i = 0; i < items.length; i += itemsPerRow) {
      final chunk =
          items.sublist(i, (i + itemsPerRow).clamp(i, items.length));

      rows.add(pw.Row(
        children: [
          ...chunk.map((l) {
            final c = l.$3;
            final pdfColor = PdfColor(c.r, c.g, c.b);
            return pw.Expanded(
              child: pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(
                    width: 8,
                    height: 8,
                    decoration: pw.BoxDecoration(
                      color: pdfColor,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Flexible(
                    child: pw.Text(
                      l.$2,
                      style: pw.TextStyle(color: textColor, fontSize: 8),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Fill remaining slots so columns align
          ...List.generate(
            itemsPerRow - chunk.length,
            (_) => pw.Expanded(child: pw.SizedBox()),
          ),
        ],
      ));

      if (i + itemsPerRow < items.length) rows.add(pw.SizedBox(height: 4));
    }

    return rows;
  }
}
