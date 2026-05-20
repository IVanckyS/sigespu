// Stub: pantalla de perfil del usuario. El recovery del 19-may referenciaba
// esta pantalla pero no la incluyó. Placeholder hasta implementar edición
// de perfil (nombre, avatar, cambio de contraseña).
// TODO(sprint-4): UI completa de perfil con upload de avatar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final nombre = user?['nombre'] as String? ?? 'Usuario';
    final email = user?['email'] as String? ?? '';
    final rol = user?['nivel_acceso'] as String? ?? 'visitante';

    return Scaffold(
      backgroundColor: AppTheme.stone50,
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Row(label: 'Nombre', value: nombre),
            const SizedBox(height: 12),
            _Row(label: 'Correo', value: email),
            const SizedBox(height: 12),
            _Row(label: 'Rol', value: rol),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.stone500, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 14, color: AppTheme.stone900)),
        ),
      ],
    );
  }
}
