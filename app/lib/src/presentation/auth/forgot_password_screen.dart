// Stub: pantalla "olvidé mi contraseña". El recovery del 19-may apuntaba
// a esta pantalla pero no la incluyó (estaba untracked). Aquí mostramos
// un placeholder hasta implementar el flujo real de reset.
// TODO(sprint-4): implementar reset por correo (endpoint /auth/reset-password).

import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.stone50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Recuperar contraseña',
            style: TextStyle(color: AppTheme.stone900, fontSize: 16)),
        iconTheme: const IconThemeData(color: AppTheme.stone700),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Contacta al administrador para reestablecer tu contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.stone600, height: 1.5),
          ),
        ),
      ),
    );
  }
}
