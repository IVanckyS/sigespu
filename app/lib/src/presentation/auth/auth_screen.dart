import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_provider.dart';
import 'forgot_password_screen.dart';
import 'verification_screen.dart';
import '../legal/legal_screen.dart';

/// SIGESPU · Login — Cream Editorial
///
/// Implementa el mockup `SIGESPU-Login.html` (variantes 04 desktop + 05 mobile):
/// papel crema #F5EFE6, contornos topográficos, tipografía display Space
/// Grotesk + Inter, paleta terracota sin azules. El layout es responsive:
///
///   ≥ 980px: split editorial (display a la izquierda, card a la derecha)
///   < 980px: vertical compacto con header + hero + card + footer LAT/LON
///
/// Conserva la lógica de `authProvider.login/register` existente.

// ── Paleta ──────────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF5EFE6);
  static const card = Color(0xFFFFFEFB);
  static const cardBorder = Color(0xFFE7DFD0);
  static const ink = Color(0xFF1C1917);
  static const muted = Color(0xFF78716C);
  static const mutedSoft = Color(0xFF57534E);
  static const subtle = Color(0xFFA8A29E);
  static const accent = Color(0xFFEA580C);
  static const terracota = Color(0xFF9A3412);
  static const sun = Color(0xFFF97316);
  static const sandLight = Color(0xFFFED7AA);
  static const cream1 = Color(0xFFFFEDD5);
  static const cream2 = Color(0xFFFFF7ED);
  static const success = Color(0xFF16A34A);
  static const danger = Color(0xFFB91C1C);
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isRegisterMode = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _rememberMe = false;
  bool _termsAccepted = false;

  static const _allowedDomains = ['lota.cl', 'munilota.cl'];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nombreCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
    if (!val.contains('@')) return 'Correo inválido';
    final domain = val.split('@').last.toLowerCase();
    if (_isRegisterMode && !_allowedDomains.contains(domain)) {
      return 'Solo @lota.cl o @munilota.cl';
    }
    return null;
  }

  String? _validatePass(String? val) {
    if (val == null || val.isEmpty) return 'Ingresa tu contraseña';
    if (_isRegisterMode && val.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  String? _validateConfirm(String? val) {
    if (!_isRegisterMode) return null;
    if (val != _passwordCtrl.text) return 'No coincide';
    return null;
  }

  String? _validateNombre(String? val) {
    if (!_isRegisterMode) return null;
    if (val == null || val.trim().isEmpty) return 'Ingresa tu nombre';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isRegisterMode) {
      ref.read(authProvider.notifier).register(
            _nombreCtrl.text.trim(),
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
            termsAccepted: _termsAccepted,
          );
    } else {
      ref.read(authProvider.notifier).login(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
            rememberMe: _rememberMe,
          );
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _confirmCtrl.clear();
      _nombreCtrl.clear();
      _termsAccepted = false;
    });
  }

  void toggleTerms() => setState(() => _termsAccepted = !_termsAccepted);

  void togglePass() => setState(() => _obscurePass = !_obscurePass);
  void toggleConfirm() => setState(() => _obscureConfirm = !_obscureConfirm);
  void toggleRememberMe() => setState(() => _rememberMe = !_rememberMe);

  void _enterOffline() {
    ref.read(authProvider.notifier).enterOffline();
    context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.isAuthenticated) context.go('/map');
    });

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 980;
            if (authState.pendingEmail != null) {
              return Stack(
                children: [
                  const Positioned.fill(child: _TopoBackground()),
                  VerificationScreen(email: authState.pendingEmail!),
                ],
              );
            }
            return Stack(
              children: [
                const Positioned.fill(child: _TopoBackground()),
                if (isWide)
                  _DesktopLayout(state: this, authState: authState)
                else
                  _MobileLayout(state: this, authState: authState),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Desktop ──────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final _AuthScreenState state;
  final AuthState authState;
  const _DesktopLayout({required this.state, required this.authState});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sello esquina superior izquierda
        const Positioned(
          left: 48,
          top: 36,
          child: _BrandMark(emblemSize: 44, primarySize: 13.5),
        ),
        // Nav derecha
        const Positioned(
          right: 48,
          top: 40,
          child: _TopRightStrip(),
        ),
        // Contenido
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 100, 0, 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Columna izquierda — display
              Expanded(
                flex: 11,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(64, 40, 32, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _AccessLabel(),
                      const SizedBox(height: 24),
                      const _DisplayTitle(fontSize: 78, lineHeight: 0.95),
                      const SizedBox(height: 24),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: const _Acronym(fontSize: 15),
                      ),
                      const Spacer(),
                      const _CoordsFooter(monoSize: 11),
                    ],
                  ),
                ),
              ),
              // Columna derecha — card
              Expanded(
                flex: 10,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _LoginCard(state: state, authState: authState, compact: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Mobile ───────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final _AuthScreenState state;
  final AuthState authState;
  const _MobileLayout({required this.state, required this.authState});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: brand + status pills
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Row(
                children: [
                  _BrandMark(emblemSize: 36, primarySize: 13),
                  Spacer(),
                  _StatusPills(compact: true),
                ],
              ),
            ),
            // Hero
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 28, 4, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AccessLabel(),
                  SizedBox(height: 14),
                  _DisplayTitle(fontSize: 44, lineHeight: 0.95),
                  SizedBox(height: 14),
                  _Acronym(fontSize: 12),
                ],
              ),
            ),
            // Card
            _LoginCard(state: state, authState: authState, compact: true),
            // Footer coords
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 18, 4, 12),
              child: _CoordsFooter(monoSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Brand / Header pieces ────────────────────────────────────────────────────

class _BrandMark extends StatelessWidget {
  final double emblemSize;
  final double primarySize;
  const _BrandMark({required this.emblemSize, required this.primarySize});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HorizonteEmblem(size: emblemSize),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SIGESPU',
              style: GoogleFonts.spaceGrotesk(
                fontSize: primarySize,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.13,
                color: _C.ink,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'Ilustre Municipalidad de Lota',
              style: TextStyle(
                fontSize: primarySize * 0.72,
                color: _C.muted,
                letterSpacing: 0.18 * (primarySize * 0.72),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TopRightStrip extends StatelessWidget {
  const _TopRightStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Soporte',
          style: TextStyle(fontSize: 12.5, color: _C.mutedSoft),
        ),
        const SizedBox(width: 24),
        Text(
          'Estado del sistema',
          style: TextStyle(fontSize: 12.5, color: _C.mutedSoft),
        ),
        const SizedBox(width: 24),
        const _StatusPills(compact: false),
      ],
    );
  }
}

class _StatusPills extends StatelessWidget {
  final bool compact;
  const _StatusPills({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 7 : 9,
            vertical: compact ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: _C.cream2,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: _C.sandLight),
          ),
          child: Text(
            'v1.0.0',
            style: GoogleFonts.jetBrainsMono(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: _C.terracota,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 9 : 10,
            vertical: compact ? 4 : 5,
          ),
          decoration: BoxDecoration(
            color: _C.cream1,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 5 : 6,
                height: compact ? 5 : 6,
                decoration: const BoxDecoration(
                  color: _C.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                compact ? 'Activo' : 'Sistema activo',
                style: TextStyle(
                  fontSize: compact ? 10 : 11,
                  color: _C.terracota,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccessLabel extends StatelessWidget {
  const _AccessLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      '№ 001 · Acceso',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 3.3,
        color: _C.terracota,
      ),
    );
  }
}

class _DisplayTitle extends StatelessWidget {
  final double fontSize;
  final double lineHeight;
  const _DisplayTitle({required this.fontSize, required this.lineHeight});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.spaceGrotesk(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: -fontSize * 0.04,
          color: _C.ink,
          height: lineHeight,
        ),
        children: [
          const TextSpan(text: 'Tu ciudad,\n'),
          const TextSpan(text: 'bajo\n'),
          TextSpan(
            text: 'resguardo',
            style: GoogleFonts.spaceGrotesk(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: _C.accent,
              fontStyle: FontStyle.italic,
              height: lineHeight,
              letterSpacing: -fontSize * 0.04,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}

class _Acronym extends StatelessWidget {
  final double fontSize;
  const _Acronym({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(
      fontSize: fontSize,
      color: _C.mutedSoft,
      height: 1.65,
    );
    final highlight = TextStyle(
      fontSize: fontSize,
      color: _C.accent,
      fontWeight: FontWeight.w700,
      height: 1.65,
    );
    return RichText(
      text: TextSpan(
        style: muted,
        children: [
          TextSpan(text: 'SI', style: highlight),
          const TextSpan(text: 'stema de Información '),
          TextSpan(text: 'GE', style: highlight),
          const TextSpan(text: 'oespacial de '),
          TextSpan(text: 'S', style: highlight),
          const TextSpan(text: 'eguridad '),
          TextSpan(text: 'PÚ', style: highlight),
          const TextSpan(text: 'blica.'),
        ],
      ),
    );
  }
}

class _CoordsFooter extends StatelessWidget {
  final double monoSize;
  const _CoordsFooter({required this.monoSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Coord(label: 'LAT', value: '–37.0883°', size: monoSize),
        _Coord(label: 'LON', value: '–73.1567°', size: monoSize),
        _Coord(label: 'POB', value: '45.123', size: monoSize),
        _Coord(label: 'ALT', value: '122 m', size: monoSize),
      ],
    );
  }
}

class _Coord extends StatelessWidget {
  final String label;
  final String value;
  final double size;
  const _Coord({required this.label, required this.value, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _C.subtle,
            fontSize: size - 2,
            letterSpacing: size * 0.06,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: size,
            color: _C.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Card ─────────────────────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  final _AuthScreenState state;
  final AuthState authState;
  final bool compact;
  const _LoginCard({
    required this.state,
    required this.authState,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = compact ? 22.0 : 26.0;
    final padH = compact ? 22.0 : 38.0;
    final padTop = compact ? 28.0 : 40.0;
    final isLoading = authState.isLoading;
    final isRegister = state._isRegisterMode;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.cardBorder),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C2D12).withValues(alpha: 0.22),
                blurRadius: compact ? 40 : 60,
                offset: Offset(0, compact ? 20 : 30),
                spreadRadius: -20,
              ),
              BoxShadow(
                color: const Color(0xFF7C2D12).withValues(alpha: 0.10),
                blurRadius: compact ? 16 : 20,
                offset: Offset(0, compact ? 6 : 8),
                spreadRadius: -8,
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(padH, padTop, padH, padTop * 0.6),
          child: Form(
            key: state._formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRegister ? 'Crear cuenta' : 'Inicia sesión',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -titleSize * 0.02,
                    color: _C.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isRegister
                      ? 'Solo funcionarios @lota.cl o @munilota.cl'
                      : 'Usa tu correo @munilota.cl',
                  style: TextStyle(
                    color: _C.muted,
                    fontSize: compact ? 12.5 : 13.5,
                  ),
                ),
                SizedBox(height: compact ? 20 : 26),

                if (isRegister) ...[
                  _FloatingField(
                    controller: state._nombreCtrl,
                    label: 'Nombre completo',
                    icon: Icons.person_outline,
                    validator: state._validateNombre,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                ],

                _FloatingField(
                  controller: state._emailCtrl,
                  label: 'Correo institucional',
                  icon: Icons.alternate_email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  inputFormatters: const [
                    // bloquea espacios en el email
                  ],
                  validator: state._validateEmail,
                ),
                const SizedBox(height: 12),

                _FloatingField(
                  controller: state._passwordCtrl,
                  label: 'Contraseña',
                  icon: Icons.lock_outline,
                  obscureText: state._obscurePass,
                  onToggleObscure: state.togglePass,
                  validator: state._validatePass,
                  textInputAction: isRegister
                      ? TextInputAction.next
                      : TextInputAction.done,
                  onSubmitted: isRegister ? null : (_) => state._submit(),
                ),

                if (isRegister) ...[
                  const SizedBox(height: 12),
                  _FloatingField(
                    controller: state._confirmCtrl,
                    label: 'Confirmar contraseña',
                    icon: Icons.lock_outline,
                    obscureText: state._obscureConfirm,
                    onToggleObscure: state.toggleConfirm,
                    validator: state._validateConfirm,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => state._submit(),
                  ),
                  const SizedBox(height: 14),
                  _TermsCheckboxRow(
                    value: state._termsAccepted,
                    onTap: state.toggleTerms,
                    compact: compact,
                  ),
                ],

                if (!isRegister) ...[
                  const SizedBox(height: 12),
                  _RememberMeRow(
                    value: state._rememberMe,
                    onTap: state.toggleRememberMe,
                    compact: compact,
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Recuperar contraseña',
                              style: TextStyle(
                                fontSize: compact ? 11.5 : 12,
                                color: _C.terracota,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              size: 12,
                              color: _C.terracota,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                if (authState.error != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 14, color: _C.danger),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _C.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: compact ? 14 : 16),

                // Botón principal (negro)
                _PrimaryButton(
                  label: isRegister ? 'Crear cuenta' : 'Iniciar sesión',
                  loading: isLoading,
                  onPressed: (isLoading || (isRegister && !state._termsAccepted))
                      ? null
                      : state._submit,
                ),

                // Acceso sin conexión (solo móvil + solo en login)
                if (compact && !isRegister) ...[
                  const SizedBox(height: 16),
                  const _Divider(label: 'o sin red'),
                  const SizedBox(height: 10),
                  _OfflineButton(onPressed: state._enterOffline),
                ],

                SizedBox(height: compact ? 18 : 24),
                _Footer(
                  isRegister: isRegister,
                  onToggle: state._toggleMode,
                  compact: compact,
                ),
              ],
            ),
          ),
        ),
        // Tag flotante
        Positioned(
          top: -14,
          right: compact ? 20 : 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _C.ink,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isRegister ? 'REGISTRO' : 'ENTRAR',
              style: GoogleFonts.jetBrainsMono(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: _C.sandLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Inputs ───────────────────────────────────────────────────────────────────

class _FloatingField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const _FloatingField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onSubmitted,
  });

  @override
  State<_FloatingField> createState() => _FloatingFieldState();
}

class _FloatingFieldState extends State<_FloatingField> {
  late final FocusNode _focus;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(_onFocus);
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onFocus() => setState(() => _hasFocus = _focus.hasFocus);
  void _onText() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.controller.text.isNotEmpty;
    final lifted = _hasFocus || hasValue;
    final borderColor = _hasFocus ? _C.accent : _C.cardBorder;
    final iconColor = _hasFocus ? _C.accent : _C.muted;

    return FormField<String>(
      validator: (_) => widget.validator?.call(widget.controller.text),
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.fromLTRB(44, 14, 14, 14),
              decoration: BoxDecoration(
                color: _C.card,
                border: Border.all(color: borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: _hasFocus
                    ? [
                        BoxShadow(
                          color: _C.accent.withValues(alpha: 0.13),
                          blurRadius: 0,
                          spreadRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  // Ícono
                  Positioned(
                    left: -30,
                    top: 0,
                    bottom: 0,
                    child: Icon(widget.icon, size: 18, color: iconColor),
                  ),
                  // Label flotante
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    left: 0,
                    top: lifted ? -22 : 0,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        fontSize: lifted ? 11 : 14,
                        fontWeight:
                            lifted ? FontWeight.w600 : FontWeight.w400,
                        letterSpacing: lifted ? 0.55 : 0,
                        color: iconColor,
                      ),
                      child: Container(
                        padding: lifted
                            ? const EdgeInsets.symmetric(horizontal: 6)
                            : EdgeInsets.zero,
                        decoration: lifted
                            ? BoxDecoration(
                                color: _C.card,
                                borderRadius: BorderRadius.circular(4),
                              )
                            : null,
                        child: Text(
                          lifted
                              ? widget.label.toUpperCase()
                              : widget.label,
                        ),
                      ),
                    ),
                  ),
                  // Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _focus,
                          obscureText: widget.obscureText,
                          keyboardType: widget.keyboardType,
                          textInputAction: widget.textInputAction,
                          inputFormatters: widget.inputFormatters,
                          onSubmitted: widget.onSubmitted,
                          onChanged: (_) => field.didChange(widget.controller.text),
                          style: const TextStyle(
                            fontSize: 14,
                            color: _C.ink,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (widget.onToggleObscure != null)
                        InkWell(
                          onTap: widget.onToggleObscure,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              widget.obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: _C.muted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 0, 0),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _C.danger,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Botones ─────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _C.ink.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: -8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: _C.ink,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_C.cream2),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.14,
                            color: _C.cream2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward,
                            size: 18, color: _C.cream2),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfflineButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _OfflineButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _C.cream2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: _C.sandLight, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _C.sandLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.wifi_off_outlined,
                  size: 15,
                  color: _C.terracota,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Entrar sin conexión',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C2D12),
                      ),
                    ),
                    Text(
                      'Solo información base · sin sincronizar',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: _C.terracota,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, size: 16, color: _C.terracota),
            ],
          ),
        ),
      ),
    );
  }
}

class _RememberMeRow extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  final bool compact;
  const _RememberMeRow({
    required this.value,
    required this.onTap,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: (_) => onTap(),
                activeColor: _C.accent,
                checkColor: Colors.white,
                side: const BorderSide(color: _C.cardBorder, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Recordarme',
                  style: TextStyle(
                    fontSize: compact ? 12.5 : 13,
                    color: _C.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Mantener sesión por 30 días',
                  style: TextStyle(
                    fontSize: compact ? 10 : 10.5,
                    color: _C.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final String label;
  const _Divider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: _C.bg, height: 1, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: _C.subtle,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: _C.bg, height: 1, thickness: 1)),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final bool isRegister;
  final VoidCallback onToggle;
  final bool compact;
  const _Footer({
    required this.isRegister,
    required this.onToggle,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: compact ? 14 : 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _C.bg)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isRegister ? '¿Ya tienes cuenta?' : '¿Sin cuenta?',
            style: const TextStyle(fontSize: 12.5, color: _C.muted),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Text(
                isRegister ? 'Inicia sesión' : 'Solicita acceso',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: _C.terracota,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background & Emblem (CustomPaint) ────────────────────────────────────────

/// Líneas topográficas suaves (9 curvas en zigzag suave) sobre el fondo crema.
class _TopoBackground extends StatelessWidget {
  const _TopoBackground();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _TopoPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _TopoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF78350F).withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // El viewBox del SVG era 800×600; escalamos al tamaño real preservando aspect.
    final sx = size.width / 800;
    final sy = size.height / 600;
    final s = sx > sy ? sx : sy;

    Offset p(double x, double y) => Offset(
          (x - 400) * s + size.width / 2,
          (y - 300) * s + size.height / 2,
        );

    for (int i = 0; i < 9; i++) {
      final path = Path();
      final y0 = 100.0 + i * 55;
      path.moveTo(p(0, y0).dx, p(0, y0).dy);
      path.cubicTo(
        p(120, 70 + i * 55).dx, p(120, 70 + i * 55).dy,
        p(280, 150 + i * 55).dx, p(280, 150 + i * 55).dy,
        p(420, 110 + i * 55).dx, p(420, 110 + i * 55).dy,
      );
      path.cubicTo(
        p(560, 70 + i * 55).dx, p(560, 70 + i * 55).dy,
        p(700, 60 + i * 55).dx, p(700, 60 + i * 55).dy,
        p(820, 130 + i * 55).dx, p(820, 130 + i * 55).dy,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_TopoPainter oldDelegate) => false;
}

/// Emblema "Horizonte": badge cuadrado oscuro + sol + 3 arcos.
class _HorizonteEmblem extends StatelessWidget {
  final double size;
  const _HorizonteEmblem({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _EmblemPainter()),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final s = w / 64; // el SVG original era 64×64

    // Badge
    final radius = Radius.circular(16 * s);
    final badge = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, w), radius);
    canvas.drawRRect(badge, Paint()..color = _C.ink);

    // Sol
    canvas.drawCircle(
      Offset(32 * s, 22 * s),
      6 * s,
      Paint()..color = _C.sun,
    );

    // Arcos
    void arc(double y1, double y2, Color color, double w, double opacity) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * s
        ..color = color.withValues(alpha: opacity);
      final path = Path()
        ..moveTo(_l(10) * s, y1 * s)
        ..quadraticBezierTo(32 * s, y2 * s, _l(54) * s, y1 * s);
      canvas.drawPath(path, p);
    }

    arc(42, 30, _C.sandLight, 2.2, 0.55);
    arc(48, 34, _C.sandLight, 2.6, 0.80);
    final p3 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3 * s
      ..color = _C.accent;
    final path3 = Path()
      ..moveTo(6 * s, 54 * s)
      ..quadraticBezierTo(32 * s, 38 * s, 58 * s, 54 * s);
    canvas.drawPath(path3, p3);
  }

  double _l(double v) => v;

  @override
  bool shouldRepaint(_EmblemPainter oldDelegate) => false;
}

// ── Checkbox Términos ────────────────────────────────────────────────────────

class _TermsCheckboxRow extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  final bool compact;
  const _TermsCheckboxRow({
    required this.value,
    required this.onTap,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: (_) => onTap(),
                activeColor: _C.accent,
                checkColor: Colors.white,
                side: const BorderSide(color: _C.cardBorder, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: compact ? 11.5 : 12.5,
                    color: _C.muted,
                    height: 1.45,
                  ),
                  children: [
                    const TextSpan(text: 'He leído y acepto los '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LegalTextScreen(
                              tipo: TipoLegal.terminos,
                            ),
                          ),
                        ),
                        child: Text(
                          'Términos de Uso',
                          style: TextStyle(
                            fontSize: compact ? 11.5 : 12.5,
                            color: _C.terracota,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' y la '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LegalTextScreen(
                              tipo: TipoLegal.privacidad,
                            ),
                          ),
                        ),
                        child: Text(
                          'Política de Privacidad',
                          style: TextStyle(
                            fontSize: compact ? 11.5 : 12.5,
                            color: _C.terracota,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' de SIGESPU Lota.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
