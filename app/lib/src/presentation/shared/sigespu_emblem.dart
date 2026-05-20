// Emblema institucional SIGESPU "Horizonte": badge tinta negra con sol naranjo
// y arcos topográficos. Mismo lenguaje que el editorial cream de auth_screen.
// Usado en mobile top bar, brand mark del login, sello en headers.

import 'package:flutter/material.dart';

class SigespuEmblem extends StatelessWidget {
  final double size;
  const SigespuEmblem({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _HorizonteEmblemPainter()),
    );
  }
}

class _HorizonteEmblemPainter extends CustomPainter {
  // Paleta editorial cream — coherente con auth_screen._C
  static const _ink       = Color(0xFF1C1917);
  static const _sun       = Color(0xFFF97316);
  static const _sandLight = Color(0xFFFED7AA);
  static const _accent    = Color(0xFFEA580C);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final s = w / 64;

    final radius = Radius.circular(16 * s);
    final badge = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, w), radius);
    canvas.drawRRect(badge, Paint()..color = _ink);

    canvas.drawCircle(
      Offset(32 * s, 22 * s),
      6 * s,
      Paint()..color = _sun,
    );

    void arc(double y1, double y2, Color color, double strokeW, double opacity) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeW * s
        ..color = color.withValues(alpha: opacity);
      final path = Path()
        ..moveTo(10 * s, y1 * s)
        ..quadraticBezierTo(32 * s, y2 * s, 54 * s, y1 * s);
      canvas.drawPath(path, p);
    }

    arc(42, 30, _sandLight, 2.2, 0.55);
    arc(48, 34, _sandLight, 2.6, 0.80);

    final p3 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3 * s
      ..color = _accent;
    final path3 = Path()
      ..moveTo(6 * s, 54 * s)
      ..quadraticBezierTo(32 * s, 38 * s, 58 * s, 54 * s);
    canvas.drawPath(path3, p3);
  }

  @override
  bool shouldRepaint(_HorizonteEmblemPainter oldDelegate) => false;
}
