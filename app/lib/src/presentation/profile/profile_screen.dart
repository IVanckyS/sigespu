import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final nombre = user?['nombre'] as String? ?? 'Usuario';
    final email = user?['email'] as String? ?? '';
    final rol = user?['nivel_acceso'] as String? ?? 'visitante';
    final isOffline = authState.isOffline;

    final initials = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: AppTheme.stone100,
      appBar: AppBar(
        title: const Text(
          'Mi perfil',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.stone900),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.stone700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.stone200),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Avatar card ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.orange600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.orange600.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials.isEmpty ? 'U' : initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.stone900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email.isEmpty ? (isOffline ? 'Modo sin conexión' : '—') : email,
                    style: const TextStyle(fontSize: 13, color: AppTheme.stone500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  _RoleBadge(rol: isOffline ? 'offline' : rol),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Info card ────────────────────────────────────────────────────
            if (!isOffline) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Nombre',
                      value: nombre,
                      isFirst: true,
                    ),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Correo',
                      value: email.isEmpty ? '—' : email,
                    ),
                    _InfoRow(
                      icon: Icons.shield_outlined,
                      label: 'Rol',
                      value: _rolLabel(rol),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Offline notice ───────────────────────────────────────────────
            if (isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 18, color: AppTheme.orange600),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Estás navegando sin conexión. Los datos mostrados corresponden al caché local.',
                        style: TextStyle(fontSize: 13, color: AppTheme.orange700, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ── Institución card ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INSTITUCIÓN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.stone400,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'I. Municipalidad de Lota',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.stone900),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Dirección de Seguridad Pública',
                    style: TextStyle(fontSize: 13, color: AppTheme.stone500),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Pedro Aguirre Cerda 302, Lota · Región del Biobío',
                    style: TextStyle(fontSize: 12, color: AppTheme.stone400),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: AppTheme.stone100),
                  const SizedBox(height: 12),
                  const Text(
                    'SIGESPU v1.0 · Sistema de Información Geoespacial de Seguridad Pública',
                    style: TextStyle(fontSize: 11, color: AppTheme.stone400),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _rolLabel(String rol) {
    switch (rol) {
      case 'director': return 'Director de Seguridad Pública';
      case 'operativo': return 'Funcionario Operativo';
      default: return 'Visitante Municipal';
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final String rol;
  const _RoleBadge({required this.rol});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = switch (rol) {
      'director' => (const Color(0xFF1E3A8A), const Color(0xFFEFF6FF), 'Director'),
      'operativo' => (const Color(0xFF15803D), const Color(0xFFF0FDF4), 'Operativo'),
      'offline' => (AppTheme.orange700, const Color(0xFFFFF7ED), 'Sin conexión'),
      _ => (AppTheme.stone500, AppTheme.stone100, 'Visitante'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: isFirst ? BorderSide.none : const BorderSide(color: AppTheme.stone100),
        ),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.stone400),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppTheme.stone500, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: AppTheme.stone900),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
