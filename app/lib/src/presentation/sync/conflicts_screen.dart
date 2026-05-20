// Stub: pantalla de conflictos de sincronización offline. El recovery del
// 19-may referenciaba esta pantalla pero no la incluyó. Aquí mostramos
// un placeholder hasta implementar la UI real de conflictos.
// TODO(sprint-3): UI de conflictos last-write-wins con detalle por entidad.

import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ConflictsScreen extends StatelessWidget {
  const ConflictsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.stone50,
      appBar: AppBar(
        title: const Text('Conflictos de sincronización',
            style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Sin conflictos pendientes.',
            style: TextStyle(fontSize: 14, color: AppTheme.stone600),
          ),
        ),
      ),
    );
  }
}
