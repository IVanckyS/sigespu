// Stub mínimo del emblema oficial SIGESPU. El recovery del 19-may esperaba
// un SVG/CustomPaint del escudo institucional; aquí dibujamos un placeholder
// reconocible (círculo naranja con iniciales SP) hasta que se incorpore
// el asset oficial.
// TODO(sprint-5): reemplazar por asset SVG oficial del logo SIGESPU.

import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SigespuEmblem extends StatelessWidget {
  final double size;
  const SigespuEmblem({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.orange600,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.orange700, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        'SP',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.4,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}
