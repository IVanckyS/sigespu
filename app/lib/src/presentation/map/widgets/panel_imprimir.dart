import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PanelImprimir extends ConsumerStatefulWidget {
  final GlobalKey mapKey;
  const PanelImprimir({super.key, required this.mapKey});

  @override
  ConsumerState<PanelImprimir> createState() => _PanelImprimirState();
}

class _PanelImprimirState extends ConsumerState<PanelImprimir> {
  final _titleCtrl = TextEditingController(text: 'SIGESPU Lota — Mapa');
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
            'Imprimir mapa',
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
              labelText: 'Título',
              labelStyle:
                  const TextStyle(color: Colors.white38, fontSize: 11),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white12),
                borderRadius: BorderRadius.circular(6),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF00897B)),
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['Letter', 'A4'].map((l) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(l,
                      style: const TextStyle(fontSize: 11)),
                  selected: _layout == l,
                  onSelected: (_) => setState(() => _layout = l),
                  selectedColor: const Color(0xFF00897B),
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
                  : const Icon(Icons.print, size: 16),
              label: Text(
                  _printing ? 'Generando...' : 'Imprimir / PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 10),
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
      final boundary = widget.mapKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final pageFormat = _layout == 'A4'
          ? PdfPageFormat.a4.landscape
          : PdfPageFormat.letter.landscape;

      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(pngBytes);

      pdf.addPage(pw.Page(
        pageFormat: pageFormat,
        build: (ctx) => pw.Column(children: [
          pw.Text(_titleCtrl.text,
              style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 8),
          pw.Expanded(
            child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
          ),
        ]),
      ));

      await Printing.layoutPdf(
        onLayout: (_) async => pdf.save(),
      );
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }
}
