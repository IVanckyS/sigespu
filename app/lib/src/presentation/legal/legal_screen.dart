import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'legal_texts.dart';

enum TipoLegal { terminos, privacidad }

class LegalTextScreen extends StatelessWidget {
  final TipoLegal tipo;

  const LegalTextScreen({super.key, required this.tipo});

  String get _titulo => tipo == TipoLegal.terminos
      ? 'Términos de Uso'
      : 'Política de Privacidad';

  String get _texto => tipo == TipoLegal.terminos
      ? LegalTexts.terminos
      : LegalTexts.privacidad;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F4), // stone100
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1917), // stone900
        foregroundColor: Colors.white,
        title: Text(
          _titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 18),
            tooltip: 'Copiar texto',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _texto));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Texto copiado al portapapeles'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDD5), // orange100
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Text(
                'Versión ${LegalTexts.version} · ${LegalTexts.fecha}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEA580C), // orange600
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SelectableText(
              _texto,
              style: const TextStyle(
                fontSize: 13,
                height: 1.7,
                color: Color(0xFF1C1917), // stone900
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
