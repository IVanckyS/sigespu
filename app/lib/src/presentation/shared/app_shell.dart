import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:printing/printing.dart';
import '../../config/theme.dart';
import '../auth/auth_provider.dart';
import '../map/map_screen.dart';
import 'pdf_export_service.dart';

// ── Connectivity provider ─────────────────────────────────────────────────────

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

// ── Shell ─────────────────────────────────────────────────────────────────────

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final connectivityAsync = ref.watch(connectivityProvider);
    final auth = ref.watch(authProvider);

    final isOnline = connectivityAsync.when(
      data: (result) => result != ConnectivityResult.none,
      loading: () => true,
      error: (_, __) => true,
    );

    final userName = auth.user?['nombre'] as String? ?? 'Director';
    final userRole = auth.user?['nivel_acceso'] as String? ?? 'director';
    final initials = userName.isNotEmpty
        ? userName.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'US';

    return Scaffold(
      backgroundColor: AppTheme.stone50,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            height: 60,
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Brand
                        _BrandLogo(),
                        const SizedBox(width: 24),
                        // Mode switcher
                        _ModeSwitcher(location: location),
                        const Spacer(),
                        // Connectivity badge
                        _ConnBadge(isOnline: isOnline),
                        const SizedBox(width: 10),
                        // Export PDF
                        _ExportBtn(),
                        const SizedBox(width: 10),
                        // User chip
                        _UserChip(name: userName, role: userRole, initials: initials),
                        const SizedBox(width: 6),
                        // Logout
                        IconButton(
                          onPressed: () => ref.read(authProvider.notifier).logout(),
                          icon: const Icon(Icons.logout, size: 18, color: AppTheme.stone500),
                          tooltip: 'Cerrar sesión',
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                Container(height: 1, color: AppTheme.stone200),
              ],
            ),
          ),
          // ── Offline banner ───────────────────────────────────────────────────
          if (!isOnline)
            Container(
              color: const Color(0xFFFEF3C7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, size: 14, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Modo sin conexión activo — Los cambios se guardan localmente y se sincronizarán al recuperar conexión.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD97706)),
                    ),
                  ),
                ],
              ),
            ),
          // ── Banner solicitar acceso (solo visitante) ───────────────────────
          if (userRole == 'visitante')
            _SolicitarAccesoBanner(),
          // ── Content ─────────────────────────────────────────────────────────
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ── Brand logo ────────────────────────────────────────────────────────────────

class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo municipalidad (círculo azul con escudo naranja)
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(color: AppTheme.blue800, shape: BoxShape.circle),
          child: const Icon(Icons.account_balance, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        // Logo SIGESPU (cuadrado naranja con pin)
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppTheme.orange600, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.location_on, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('SIGESPU Lota', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.stone900, letterSpacing: -0.01)),
            Text('I. Municipalidad de Lota', style: TextStyle(fontSize: 10, color: AppTheme.stone500, letterSpacing: 0.08)),
          ],
        ),
      ],
    );
  }
}

// ── Mode switcher ─────────────────────────────────────────────────────────────

class _ModeSwitcher extends StatelessWidget {
  final String location;
  const _ModeSwitcher({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.stone100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeBtn(label: 'Mapa', icon: Icons.map_outlined, route: '/map', active: location == '/map'),
          _ModeBtn(label: 'Resumen', icon: Icons.dashboard_outlined, route: '/resumen', active: location == '/resumen'),
          _ModeBtn(label: 'Tabla', icon: Icons.grid_on_outlined, route: '/tabla', active: location == '/tabla'),
          _ModeBtn(label: 'Scraping', icon: Icons.download_for_offline_outlined, route: '/scraping', active: location == '/scraping'),
          _ModeBtn(label: 'Usuarios', icon: Icons.people_outline, route: '/users', active: location == '/users'),
        ],
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final bool active;
  const _ModeBtn({required this.label, required this.icon, required this.route, required this.active});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 2, offset: const Offset(0, 1))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: active ? AppTheme.orange700 : AppTheme.stone600),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? AppTheme.orange700 : AppTheme.stone600)),
          ],
        ),
      ),
    );
  }
}

// ── Connectivity badge ────────────────────────────────────────────────────────

class _ConnBadge extends StatelessWidget {
  final bool isOnline;
  const _ConnBadge({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final bg = isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final fg = isOnline ? const Color(0xFF15803D) : const Color(0xFFD97706);
    final label = isOnline ? 'En línea' : 'Sin conexión';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

// ── Export button ─────────────────────────────────────────────────────────────

class _ExportBtn extends ConsumerWidget {
  const _ExportBtn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () => _exportPdf(context, ref),
      icon: const Icon(Icons.picture_as_pdf_outlined, size: 14),
      label: const Text(
        'Exportar PDF',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      style: TextButton.styleFrom(
        backgroundColor: AppTheme.stone100,
        foregroundColor: AppTheme.stone700,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    final activeLayers = ref.read(activeLayersProvider);
    final dangerFilter = ref.read(dangerFilterProvider);
    final dateRange = ref.read(dateRangeProvider);
    final elementos = ref.read(filteredElementsProvider);

    final auth = ref.read(authProvider);
    final userName = auth.user?['nombre'] as String? ?? 'Funcionario';

    final filterInfo = {
      'Capas': activeLayers.join(', '),
      'Peligro': dangerFilter,
      'Rango': '$dateRange días',
    };

    try {
      final bytes = await PdfExportService.generateReport(
        elementos,
        userName,
        filterInfo: filterInfo,
      );
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al generar el PDF')),
        );
      }
    }
  }
}

// ── User chip ─────────────────────────────────────────────────────────────────

class _UserChip extends StatelessWidget {
  final String name;
  final String role;
  final String initials;
  const _UserChip({required this.name, required this.role, required this.initials});

  @override
  Widget build(BuildContext context) {
    final avatarColor = role == 'director' ? AppTheme.blue800 : AppTheme.orange600;
    final roleLabel = role == 'director' ? 'Director' : role == 'operativo' ? 'Operativo' : 'Visitante';

    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
      decoration: BoxDecoration(color: AppTheme.stone100, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: avatarColor,
            child: Text(initials, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.stone900)),
              Text(roleLabel, style: const TextStyle(fontSize: 10, color: AppTheme.stone500, letterSpacing: 0.05)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Solicitar acceso (visitante) ──────────────────────────────────────────────

class _SolicitarAccesoBanner extends ConsumerStatefulWidget {
  const _SolicitarAccesoBanner();

  @override
  ConsumerState<_SolicitarAccesoBanner> createState() =>
      _SolicitarAccesoBannerState();
}

class _SolicitarAccesoBannerState
    extends ConsumerState<_SolicitarAccesoBanner> {
  final _cargoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  bool _formVisible = false;

  @override
  void dispose() {
    _cargoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final solicitudEstado = auth.user?['solicitud_operativo'] as String?;

    if (solicitudEstado == 'pendiente') {
      return _banner(
        bg: const Color(0xFFFEF3C7),
        fg: const Color(0xFFD97706),
        icon: Icons.hourglass_top,
        text: 'Solicitud en revisión — el Director aprobará tu acceso operativo.',
      );
    }

    if (solicitudEstado == 'rechazada') {
      return _banner(
        bg: Color(AppTheme.redDanger.toARGB32()).withValues(alpha: 0.08),
        fg: AppTheme.redDanger,
        icon: Icons.cancel_outlined,
        text: 'Solicitud rechazada — contacta al Director directamente.',
      );
    }

    if (_formVisible) {
      return _buildForm(auth.isLoading);
    }

    return _banner(
      bg: AppTheme.orange50,
      fg: AppTheme.orange700,
      icon: Icons.lock_open_outlined,
      text: 'Tienes acceso Visitante (solo lectura).',
      action: TextButton(
        onPressed: () => setState(() => _formVisible = true),
        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
        child: const Text(
          'Solicitar acceso operativo →',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.orange700),
        ),
      ),
    );
  }

  Widget _banner({
    required Color bg,
    required Color fg,
    required IconData icon,
    required String text,
    Widget? action,
  }) {
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg),
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Container(
      color: AppTheme.orange50,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cargoCtrl,
              decoration: InputDecoration(
                labelText: 'Cargo',
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _direccionCtrl,
              decoration: InputDecoration(
                labelText: 'Dependencia municipal',
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (_cargoCtrl.text.trim().isEmpty ||
                        _direccionCtrl.text.trim().isEmpty) {
                      return;
                    }
                    final ok = await ref
                        .read(authProvider.notifier)
                        .solicitarAcceso(
                          _cargoCtrl.text.trim(),
                          _direccionCtrl.text.trim(),
                        );
                    if (ok && mounted) {
                      setState(() => _formVisible = false);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enviar', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => setState(() => _formVisible = false),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 12, color: AppTheme.stone500),
            ),
          ),
        ],
      ),
    );
  }
}
