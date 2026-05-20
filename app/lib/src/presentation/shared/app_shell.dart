import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../data/sync/sync_provider.dart';
import '../actividades/actividades_provider.dart';
import '../auth/auth_provider.dart';
import '../map/providers/map_providers.dart';
import '../profile/avatar_provider.dart';
import '../users/users_provider.dart';
import 'pdf_export_service.dart';
import 'sigespu_emblem.dart';

// ── Connectivity provider ─────────────────────────────────────────────────────

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

// ── Mobile design tokens ──────────────────────────────────────────────────────

const _kMobileBg = Color(0xFFFAF7F2);
const _kBorder   = Color(0x14000000); // rgba(28,25,23,0.08)
const _kOrange   = Color(0xFFEA580C);

// ── Shell ─────────────────────────────────────────────────────────────────────

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _avatarOpen = false;

  @override
  Widget build(BuildContext context) {
    final location      = GoRouterState.of(context).uri.path;
    final connectAsync  = ref.watch(connectivityProvider);
    final auth          = ref.watch(authProvider);
    final conflicts     = ref.watch(conflictCountProvider).asData?.value ?? 0;
    final avatarBytes   = ref.watch(avatarBytesProvider).valueOrNull;

    final isOnline = connectAsync.when(
      data:    (r) => r != ConnectivityResult.none,
      loading: ()  => true,
      error:   (_, __) => true,
    );

    final userName = auth.user?['nombre']       as String? ?? 'Director';
    final userRole = auth.user?['nivel_acceso'] as String? ?? 'director';
    final initials = userName.isNotEmpty
        ? userName.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'US';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final bodyContent = Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            if (isMobile)
              _MobileTopBar(
                isOnline:    isOnline,
                initials:    initials,
                userRole:    userRole,
                avatarBytes: avatarBytes,
                onAvatarTap: () => setState(() => _avatarOpen = !_avatarOpen),
                onExport:    () => _exportPdf(context, location),
              )
            else
              _buildDesktopHeader(location, isOnline, userName, userRole, initials),

            // ── Offline banner ───────────────────────────────────────────────
            if (!isOnline)
              Container(
                color: const Color(0xFFFEF3C7),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Row(children: [
                  Icon(Icons.wifi_off, size: 14, color: Color(0xFFD97706)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modo sin conexión activo — Los cambios se guardan localmente y se sincronizarán al recuperar conexión.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD97706)),
                    ),
                  ),
                ]),
              ),

            // ── Banners ──────────────────────────────────────────────────────
            if (userRole == 'visitante') const _SolicitarAccesoBanner(),
            if (conflicts > 0) _ConflictsBanner(count: conflicts),

            // ── Content ──────────────────────────────────────────────────────
            Expanded(child: widget.child),
          ],
        );

        return Scaffold(
          backgroundColor: isMobile ? _kMobileBg : AppTheme.stone50,
          bottomNavigationBar: isMobile
              ? _MobileBottomTabs(location: location, role: userRole)
              : null,
          body: Stack(
            children: [
              bodyContent,
              if (_avatarOpen && isMobile)
                Positioned.fill(
                  child: _AvatarMenuOverlay(
                    userName:    userName,
                    userRole:    userRole,
                    initials:    initials,
                    avatarBytes: avatarBytes,
                    onClose:     () => setState(() => _avatarOpen = false),
                    onNavigate:  (route) {
                      setState(() => _avatarOpen = false);
                      context.go(route);
                    },
                    onLogout: () {
                      setState(() => _avatarOpen = false);
                      ref.read(authProvider.notifier).logout();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Desktop header ─────────────────────────────────────────────────────────

  Widget _buildDesktopHeader(
    String location,
    bool isOnline,
    String userName,
    String userRole,
    String initials,
  ) {
    return Container(
      height: 60,
      color: Colors.white,
      child: Column(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const _BrandLogo(),
              const SizedBox(width: 24),
              Expanded(child: _ModeSwitcher(location: location)),
              const SizedBox(width: 12),
              _ConnBadge(isOnline: isOnline),
              const SizedBox(width: 10),
              const _ExportBtn(),
              const SizedBox(width: 10),
              _UserChip(name: userName, role: userRole, initials: initials),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout, size: 18, color: AppTheme.stone500),
                tooltip: 'Cerrar sesión',
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(width: 4),
            ]),
          ),
        ),
        Container(height: 1, color: AppTheme.stone200),
      ]),
    );
  }

  // ── PDF export (mobile) ────────────────────────────────────────────────────

  Future<void> _exportPdf(BuildContext context, String location) async {
    final userName = ref.read(authProvider).user?['nombre'] as String? ?? 'Funcionario';
    try {
      late final List<int> bytes;
      if (location == '/resumen') {
        bytes = await PdfExportService.generateResumenReport(
          ref.read(allElementsProvider), userName);
      } else if (location == '/tabla') {
        final elementos = ref.read(tablaFilteredProvider);
        bytes = await PdfExportService.generateReport(
          elementos, userName,
          title: 'LISTADO DE ELEMENTOS',
          filterInfo: {'Elementos mostrados': '${elementos.length}'},
        );
      } else if (location == '/scraping') {
        bytes = await PdfExportService.generateScrapingReport(
          userName,
          patentes: ref.read(scrapingFilteredPatenteProvider),
          permisos: ref.read(scrapingFilteredPermisoProvider),
          transito: ref.read(scrapingFilteredTransitoProvider),
          orgs:     ref.read(scrapingFilteredOrgProvider),
        );
      } else if (location == '/actividades') {
        bytes = await PdfExportService.generateActividadesReport(
          ref.read(filteredActividadesProvider), userName);
      } else if (location == '/users') {
        bytes = await PdfExportService.generateUsuariosReport(
          userName, usuarios: ref.read(usersProvider).valueOrNull ?? []);
      } else {
        bytes = await PdfExportService.generateReport(
          ref.read(filteredElementsProvider), userName,
          filterInfo: {
            'Capas activas': ref.read(activeLayersProvider).isEmpty
                ? 'Ninguna' : ref.read(activeLayersProvider).join(', '),
            'Peligro': ref.read(dangerFilterProvider),
            'Rango':   ref.read(dateRangeProvider) == 'all'
                ? 'Todos' : '${ref.read(dateRangeProvider)} dias',
          },
        );
      }
      await Printing.layoutPdf(onLayout: (_) async => Uint8List.fromList(bytes));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al generar el PDF')),
        );
      }
    }
  }
}

// ── Mobile top bar ────────────────────────────────────────────────────────────

class _MobileTopBar extends StatelessWidget {
  final bool isOnline;
  final String initials;
  final String userRole;
  final Uint8List? avatarBytes;
  final VoidCallback onAvatarTap;
  final VoidCallback onExport;

  const _MobileTopBar({
    required this.isOnline,
    required this.initials,
    required this.userRole,
    required this.avatarBytes,
    required this.onAvatarTap,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = userRole == 'director' ? AppTheme.orange700 : _kOrange;

    return Container(
      color: Colors.white,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(children: [
            // Brand emblem (oficial, mismo que escritorio)
            const SigespuEmblem(size: 32),
            const SizedBox(width: 9),

            // Title + online badge + subtitle
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Flexible(
                    child: Text(
                      'SIGESPU Lota',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1917), letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 5, height: 5,
                        decoration: BoxDecoration(
                          color: isOnline ? const Color(0xFF16A34A) : const Color(0xFFCA8A04),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isOnline ? 'En línea' : 'Sin conexión',
                        style: TextStyle(
                          fontSize: 9.5, fontWeight: FontWeight.w600,
                          color: isOnline ? const Color(0xFF166534) : const Color(0xFF92400E),
                        ),
                      ),
                    ]),
                  ),
                ]),
                const Text(
                  'I. Municipalidad de Lota',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF78716C)),
                ),
              ]),
            ),

            // Export button
            GestureDetector(
              onTap: onExport,
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _kBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.picture_as_pdf_outlined, size: 14, color: Color(0xFF1C1917)),
                  SizedBox(width: 4),
                  Text('PDF', style: TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF1C1917),
                  )),
                ]),
              ),
            ),
            const SizedBox(width: 8),

            // Avatar with dropdown indicator
            GestureDetector(
              onTap: onAvatarTap,
              child: Stack(clipBehavior: Clip.none, children: [
                _UserAvatar(
                  radius: 17,
                  initials: initials,
                  bgColor: avatarColor,
                  bytes: avatarBytes,
                  initialsFontSize: 11.5,
                ),
                Positioned(
                  bottom: -1, right: -1,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1917),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.keyboard_arrow_down, size: 8, color: Colors.white),
                  ),
                ),
              ]),
            ),
          ]),
        ),
        Container(height: 1, color: _kBorder),
      ]),
    );
  }
}

// ── Mobile bottom tabs ────────────────────────────────────────────────────────

class _MobileBottomTabs extends ConsumerWidget {
  final String location;
  final String role;
  const _MobileBottomTabs({required this.location, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actividadesCount = ref.watch(actividadesProvider).length;

    final items = [
      const _TabItem(id: '/map',         label: 'Mapa',      icon: Icons.map_outlined),
      const _TabItem(id: '/resumen',     label: 'Resumen',   icon: Icons.dashboard_outlined),
      const _TabItem(id: '/tabla',       label: 'Tabla',     icon: Icons.grid_on_outlined),
      const _TabItem(id: '/scraping',    label: 'Scraping',  icon: Icons.download_for_offline_outlined),
      _TabItem(
        id: '/actividades', label: 'Actividad',
        icon: Icons.view_kanban_outlined,
        badge: actividadesCount > 0 ? actividadesCount : null,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _kBorder)),
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: items.map((item) {
              final active = location == item.id;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.go(item.id),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(clipBehavior: Clip.none, children: [
                        Icon(
                          item.icon, size: 22,
                          color: active ? _kOrange : const Color(0xFF78716C),
                        ),
                        if (item.badge != null)
                          Positioned(
                            top: -4, right: -10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: _kOrange,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${item.badge}',
                                style: const TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ]),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? _kOrange : const Color(0xFF78716C),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String id;
  final String label;
  final IconData icon;
  final int? badge;
  const _TabItem({required this.id, required this.label, required this.icon, this.badge});
}

// ── Avatar menu overlay ───────────────────────────────────────────────────────

class _AvatarMenuOverlay extends StatelessWidget {
  final String userName;
  final String userRole;
  final String initials;
  final Uint8List? avatarBytes;
  final VoidCallback onClose;
  final void Function(String route) onNavigate;
  final VoidCallback onLogout;

  const _AvatarMenuOverlay({
    required this.userName,
    required this.userRole,
    required this.initials,
    required this.avatarBytes,
    required this.onClose,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = userRole == 'director' ? AppTheme.orange700 : _kOrange;
    final roleLabel = switch (userRole) {
      'director'  => 'Director',
      'operativo' => 'Operativo',
      _           => 'Visitante',
    };

    return GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.opaque,
      child: Stack(children: [
        // Backdrop
        Container(color: Colors.black.withValues(alpha: 0.30)),

        // Popover card
        Positioned(
          top: 62, right: 12, width: 280,
          child: GestureDetector(
            onTap: () {}, // prevent backdrop dismiss when tapping inside
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x36000000), blurRadius: 40, offset: Offset(0, 16)),
                  BoxShadow(color: Color(0x08000000), blurRadius: 1),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // User header
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: _kBorder)),
                  ),
                  child: Row(children: [
                    _UserAvatar(
                      radius: 20,
                      initials: initials,
                      bgColor: avatarColor,
                      bytes: avatarBytes,
                      initialsFontSize: 13,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1C1917),
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$roleLabel · Dir. Seguridad Pública',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF78716C)),
                        ),
                      ]),
                    ),
                  ]),
                ),

                // Menu items
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(children: [
                    if (userRole == 'director')
                      _AvatarMenuItem(
                        icon:  Icons.people_outline,
                        label: 'Gestión de usuarios',
                        sub:   'Aprobar y rechazar solicitudes',
                        onTap: () => onNavigate('/users'),
                      ),
                    _AvatarMenuItem(
                      icon:  Icons.shield_outlined,
                      label: 'Mi perfil',
                      sub:   'Cuenta y seguridad',
                      onTap: () {
                        onClose();
                        onNavigate('/profile');
                      },
                    ),
                  ]),
                ),

                // Logout
                Container(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: _kBorder)),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: _AvatarMenuItem(
                    icon:       Icons.logout,
                    label:      'Cerrar sesión',
                    sub:        'Salir del sistema',
                    iconBg:     const Color(0xFFFEE2E2),
                    iconColor:  const Color(0xFFDC2626),
                    labelColor: const Color(0xFFDC2626),
                    onTap:      onLogout,
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _AvatarMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color? iconBg;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  const _AvatarMenuItem({
    required this.icon,
    required this.label,
    required this.sub,
    this.iconBg,
    this.iconColor,
    this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = iconBg    ?? const Color(0xFFF3F4F6);
    final fg = iconColor ?? const Color(0xFF44403C);
    final lc = labelColor ?? const Color(0xFF1C1917);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 14, color: fg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: lc)),
              Text(sub,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF78716C))),
            ]),
          ),
          const Icon(Icons.chevron_right, size: 14, color: Color(0xFFA8A29E)),
        ]),
      ),
    );
  }
}

// ── Brand logo (desktop) ──────────────────────────────────────────────────────

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: 36, height: 36, child: CustomPaint(painter: _MunicipalLogoPainter())),
      const SizedBox(width: 8),
      const SigespuEmblem(size: 36),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SIGESPU Lota',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppTheme.stone900, letterSpacing: -0.2,
            ),
          ),
          const Text(
            'I. Municipalidad de Lota',
            style: TextStyle(fontSize: 10, color: AppTheme.stone500, letterSpacing: 0.08),
          ),
        ],
      ),
    ]);
  }
}

class _MunicipalLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48;
    canvas.drawCircle(Offset(24 * s, 24 * s), 22 * s, Paint()..color = const Color(0xFF44403C));
    canvas.drawPath(
      Path()
        ..moveTo(12 * s, 30 * s)..lineTo(12 * s, 20 * s)
        ..quadraticBezierTo(12 * s, 14 * s, 18 * s, 14 * s)
        ..lineTo(30 * s, 14 * s)
        ..quadraticBezierTo(36 * s, 14 * s, 36 * s, 20 * s)
        ..lineTo(36 * s, 30 * s)..close(),
      Paint()..color = const Color(0xFFEA580C),
    );
    final win = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(18 * s, 22 * s, 4 * s, 8 * s), Radius.circular(s)), win);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(26 * s, 22 * s, 4 * s, 8 * s), Radius.circular(s)), win);
    canvas.drawPath(
      Path()..moveTo(20 * s, 14 * s)..lineTo(24 * s, 10 * s)..lineTo(28 * s, 14 * s)..close(),
      Paint()..color = const Color(0xFFFED7AA),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Mode switcher (desktop) ───────────────────────────────────────────────────

class _ModeSwitcher extends ConsumerWidget {
  final String location;
  const _ModeSwitcher({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actividadesCount = ref.watch(actividadesProvider).length;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: AppTheme.stone100, borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _ModeBtn(label: 'Mapa',        icon: Icons.map_outlined,               route: '/map',         active: location == '/map'),
          _ModeBtn(label: 'Resumen',     icon: Icons.dashboard_outlined,          route: '/resumen',     active: location == '/resumen'),
          _ModeBtn(label: 'Tabla',       icon: Icons.grid_on_outlined,            route: '/tabla',       active: location == '/tabla'),
          _ModeBtn(label: 'Scraping',    icon: Icons.download_for_offline_outlined, route: '/scraping',  active: location == '/scraping'),
          _ModeBtn(label: 'Usuarios',    icon: Icons.people_outline,              route: '/users',       active: location == '/users'),
          _ModeBtnBadged(
            label: 'Actividades', icon: Icons.view_kanban_outlined,
            route: '/actividades', active: location == '/actividades',
            badge: '$actividadesCount',
          ),
        ]),
      ),
    );
  }
}

class _ModeBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final String route;
  final bool active;
  const _ModeBtn({required this.label, required this.icon, required this.route, required this.active});

  @override
  State<_ModeBtn> createState() => _ModeBtnState();
}

class _ModeBtnState extends State<_ModeBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(widget.route),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: widget.active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: widget.active
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 2, offset: const Offset(0, 1))]
                : [],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, size: 15, color: widget.active ? AppTheme.orange700 : AppTheme.stone600),
            const SizedBox(width: 6),
            Text(widget.label, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: widget.active ? AppTheme.orange700 : AppTheme.stone600,
            )),
          ]),
        ),
      ),
    );
  }
}

class _ModeBtnBadged extends StatefulWidget {
  final String label;
  final IconData icon;
  final String route;
  final bool active;
  final String badge;

  const _ModeBtnBadged({
    required this.label, required this.icon, required this.route,
    required this.active, required this.badge,
  });

  @override
  State<_ModeBtnBadged> createState() => _ModeBtnBadgedState();
}

class _ModeBtnBadgedState extends State<_ModeBtnBadged> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(widget.route),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: widget.active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: widget.active
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 2, offset: const Offset(0, 1))]
                : [],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, size: 15, color: widget.active ? AppTheme.orange700 : AppTheme.stone600),
            const SizedBox(width: 6),
            Text(widget.label, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: widget.active ? AppTheme.orange700 : AppTheme.stone600,
            )),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: widget.active ? AppTheme.orange100 : AppTheme.stone200,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(widget.badge, style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: widget.active ? AppTheme.orange700 : AppTheme.stone500,
              )),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Connectivity badge (desktop) ──────────────────────────────────────────────

class _ConnBadge extends StatelessWidget {
  final bool isOnline;
  const _ConnBadge({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final bg    = isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final fg    = isOnline ? const Color(0xFF15803D) : const Color(0xFFD97706);
    final label = isOnline ? 'En línea' : 'Sin conexión';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }
}

// ── Export button (desktop) ───────────────────────────────────────────────────

class _ExportBtn extends ConsumerWidget {
  const _ExportBtn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () => _exportPdf(context, ref),
      icon: const Icon(Icons.picture_as_pdf_outlined, size: 14),
      label: const Text('Exportar PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      style: TextButton.styleFrom(
        backgroundColor: AppTheme.stone100,
        foregroundColor: AppTheme.stone700,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    final location = GoRouterState.of(context).uri.path;
    final userName = ref.read(authProvider).user?['nombre'] as String? ?? 'Funcionario';

    try {
      late final List<int> bytes;
      if (location == '/resumen') {
        bytes = await PdfExportService.generateResumenReport(ref.read(allElementsProvider), userName);
      } else if (location == '/tabla') {
        final elementos = ref.read(tablaFilteredProvider);
        bytes = await PdfExportService.generateReport(elementos, userName,
          title: 'LISTADO DE ELEMENTOS',
          filterInfo: {'Elementos mostrados': '${elementos.length}'},
        );
      } else if (location == '/scraping') {
        bytes = await PdfExportService.generateScrapingReport(userName,
          patentes: ref.read(scrapingFilteredPatenteProvider),
          permisos: ref.read(scrapingFilteredPermisoProvider),
          transito: ref.read(scrapingFilteredTransitoProvider),
          orgs:     ref.read(scrapingFilteredOrgProvider),
        );
      } else if (location == '/actividades') {
        bytes = await PdfExportService.generateActividadesReport(
          ref.read(filteredActividadesProvider), userName);
      } else if (location == '/users') {
        bytes = await PdfExportService.generateUsuariosReport(userName,
          usuarios: ref.read(usersProvider).valueOrNull ?? []);
      } else {
        final activeLayers = ref.read(activeLayersProvider);
        final dateRange    = ref.read(dateRangeProvider);
        bytes = await PdfExportService.generateReport(
          ref.read(filteredElementsProvider), userName,
          filterInfo: {
            'Capas activas': activeLayers.isEmpty ? 'Ninguna' : activeLayers.join(', '),
            'Peligro': ref.read(dangerFilterProvider),
            'Rango':   dateRange == 'all' ? 'Todos' : '$dateRange dias',
          },
        );
      }
      await Printing.layoutPdf(onLayout: (_) async => Uint8List.fromList(bytes));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al generar el PDF')),
        );
      }
    }
  }
}

// ── User chip (desktop) ───────────────────────────────────────────────────────

class _UserChip extends StatelessWidget {
  final String name;
  final String role;
  final String initials;
  const _UserChip({required this.name, required this.role, required this.initials});

  @override
  Widget build(BuildContext context) {
    final avatarColor = role == 'director' ? AppTheme.orange700 : AppTheme.orange600;
    final roleLabel = switch (role) {
      'director'  => 'Director',
      'operativo' => 'Operativo',
      _           => 'Visitante',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
      decoration: BoxDecoration(color: AppTheme.stone100, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(
          radius: 14, backgroundColor: avatarColor,
          child: Text(initials, style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white,
          )),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.stone900)),
          Text(roleLabel, style: const TextStyle(fontSize: 10, color: AppTheme.stone500, letterSpacing: 0.05)),
        ]),
      ]),
    );
  }
}

// ── Conflicts banner ──────────────────────────────────────────────────────────

class _ConflictsBanner extends StatelessWidget {
  final int count;
  const _ConflictsBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final plural = count == 1 ? '' : 's';
    return Material(
      color: const Color(0xFFFEE2E2),
      child: InkWell(
        onTap: () => context.push('/conflicts'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            const Icon(Icons.merge_type_rounded, size: 16, color: AppTheme.redDanger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$count cambio$plural en conflicto — otra persona modificó '
                'esto${count == 1 ? '' : 's'} antes que tú. Tócame para revisar.',
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.redDanger,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.redDanger),
          ]),
        ),
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

class _SolicitarAccesoBannerState extends ConsumerState<_SolicitarAccesoBanner> {
  final _cargoCtrl     = TextEditingController();
  final _direccionCtrl = TextEditingController();
  bool _formVisible    = false;

  @override
  void dispose() {
    _cargoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth            = ref.watch(authProvider);
    final solicitudEstado = auth.user?['solicitud_operativo'] as String?;

    if (solicitudEstado == 'pendiente') {
      return _banner(bg: const Color(0xFFFEF3C7), fg: const Color(0xFFD97706),
        icon: Icons.hourglass_top,
        text: 'Solicitud en revisión — el Director aprobará tu acceso operativo.');
    }
    if (solicitudEstado == 'rechazada') {
      return _banner(
        bg: Color(AppTheme.redDanger.toARGB32()).withValues(alpha: 0.08),
        fg: AppTheme.redDanger, icon: Icons.cancel_outlined,
        text: 'Solicitud rechazada — contacta al Director directamente.');
    }
    if (_formVisible) return _buildForm(auth.isLoading);

    return _banner(
      bg: AppTheme.orange50, fg: AppTheme.orange700,
      icon: Icons.lock_open_outlined,
      text: 'Tienes acceso Visitante (solo lectura).',
      action: TextButton(
        onPressed: () => setState(() => _formVisible = true),
        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
        child: const Text('Solicitar acceso operativo →',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.orange700)),
      ),
    );
  }

  Widget _banner({
    required Color bg, required Color fg, required IconData icon,
    required String text, Widget? action,
  }) {
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(children: [
        Icon(icon, size: 14, color: fg),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg))),
        if (action != null) action,
      ]),
    );
  }

  Widget _buildForm(bool isLoading) {
    final cargoField = TextField(
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
    );
    final dependenciaField = TextField(
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
    );
    final enviarBtn = ElevatedButton(
      onPressed: isLoading
          ? null
          : () async {
              if (_cargoCtrl.text.trim().isEmpty ||
                  _direccionCtrl.text.trim().isEmpty) return;
              final ok = await ref
                  .read(authProvider.notifier)
                  .solicitarAcceso(
                      _cargoCtrl.text.trim(), _direccionCtrl.text.trim());
              if (ok && mounted) { setState(() => _formVisible = false); }
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
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : const Text('Enviar', style: TextStyle(fontSize: 13)),
    );
    final cancelarBtn = TextButton(
      onPressed: () => setState(() => _formVisible = false),
      child: const Text('Cancelar',
          style: TextStyle(fontSize: 12, color: AppTheme.stone500)),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 600;
        return Container(
          color: AppTheme.orange50,
          padding: EdgeInsets.fromLTRB(16, narrow ? 10 : 8, 16, narrow ? 10 : 8),
          child: narrow
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  cargoField,
                  const SizedBox(height: 6),
                  dependenciaField,
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: enviarBtn),
                    const SizedBox(width: 8),
                    cancelarBtn,
                  ]),
                ])
              : Row(children: [
                  Expanded(child: cargoField),
                  const SizedBox(width: 8),
                  Expanded(child: dependenciaField),
                  const SizedBox(width: 8),
                  enviarBtn,
                  const SizedBox(width: 4),
                  cancelarBtn,
                ]),
        );
      },
    );
  }
}

// ── User avatar (foto si existe, iniciales si no) ─────────────────────────────

class _UserAvatar extends StatelessWidget {
  final double radius;
  final String initials;
  final Color bgColor;
  final Uint8List? bytes;
  final double initialsFontSize;

  const _UserAvatar({
    required this.radius,
    required this.initials,
    required this.bgColor,
    required this.bytes,
    required this.initialsFontSize,
  });

  Widget _initialsBadge() => Container(
        width: radius * 2,
        height: radius * 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Text(
          initials,
          style: TextStyle(
            fontSize: initialsFontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (bytes == null) return _initialsBadge();
    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Image.memory(
          bytes!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsBadge(),
        ),
      ),
    );
  }
}

