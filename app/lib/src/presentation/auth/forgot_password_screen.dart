import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../shared/sigespu_emblem.dart';
import 'auth_provider.dart';

// ── Paleta (espeja auth_screen / verification_screen) ────────────────────────
class _C {
  static const bg         = Color(0xFFF5EFE6);
  static const card       = Color(0xFFFFFEFB);
  static const cardBorder = Color(0xFFE7DFD0);
  static const ink        = Color(0xFF1C1917);
  static const muted      = Color(0xFF78716C);
  static const mutedSoft  = Color(0xFF57534E);
  static const subtle     = Color(0xFFA8A29E);
  static const accent     = Color(0xFFEA580C);
  static const terracota  = Color(0xFF9A3412);
  static const sandLight  = Color(0xFFFED7AA);
  static const cream2     = Color(0xFFFFF7ED);
  static const danger     = Color(0xFFB91C1C);
  static const success    = Color(0xFF16A34A);
}

enum _ResetStep { email, code, password }

// ─────────────────────────────────────────────────────────────────────────────

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  _ResetStep _step = _ResetStep.email;

  // Step 1
  final _emailCtrl    = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();

  // Step 2
  final List<TextEditingController> _digitCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _digitNodes = List.generate(6, (_) => FocusNode());
  Timer? _resendTimer;
  int _resendLeft = 0;

  // Step 3
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _passFormKey  = GlobalKey<FormState>();
  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  bool    _loading   = false;
  String? _error;
  bool    _done      = false;

  String get _email       => _emailCtrl.text.trim();
  String get _currentCode => _digitCtrls.map((c) => c.text).join();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _resendTimer?.cancel();
    for (final c in _digitCtrls) { c.dispose(); }
    for (final f in _digitNodes) { f.dispose(); }
    super.dispose();
  }

  // ── Step 1 ──────────────────────────────────────────────────────────────────
  Future<void> _sendCode() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final ok = await ref.read(authProvider.notifier).solicitarReset(_email);
    if (!mounted) return;
    if (ok) {
      setState(() { _step = _ResetStep.code; _loading = false; });
      _startCooldown();
    } else {
      setState(() {
        _loading = false;
        _error = ref.read(authProvider).error ?? 'No se pudo enviar el código';
      });
    }
  }

  // ── Step 2 ──────────────────────────────────────────────────────────────────
  void _startCooldown() {
    setState(() => _resendLeft = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendLeft <= 1) {
        t.cancel();
        if (mounted) setState(() => _resendLeft = 0);
      } else {
        if (mounted) setState(() => _resendLeft--);
      }
    });
  }

  void _onDigit(int index, String value) {
    if (value.isEmpty) {
      if (index > 0) _digitNodes[index - 1].requestFocus();
      return;
    }
    if (index < 5) {
      _digitNodes[index + 1].requestFocus();
    } else {
      _digitNodes[index].unfocus();
    }
    if (_currentCode.length == 6) {
      setState(() { _step = _ResetStep.password; _error = null; });
    }
  }

  Future<void> _resendCode() async {
    if (_resendLeft > 0) return;
    for (final c in _digitCtrls) { c.clear(); }
    setState(() => _error = null);
    await ref.read(authProvider.notifier).solicitarReset(_email);
    _startCooldown();
    _digitNodes[0].requestFocus();
  }

  // ── Step 3 ──────────────────────────────────────────────────────────────────
  Future<void> _resetPassword() async {
    if (!_passFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final ok = await ref
        .read(authProvider.notifier)
        .resetPassword(_email, _currentCode, _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      setState(() { _loading = false; _done = true; });
    } else {
      final msg = ref.read(authProvider).error ?? 'No se pudo restablecer la contraseña';
      // Si el error menciona código incorrecto, volver al paso 2
      final isCodeError = msg.toLowerCase().contains('código') ||
          msg.toLowerCase().contains('inválido') ||
          msg.toLowerCase().contains('invalido') ||
          msg.toLowerCase().contains('expirado');
      setState(() {
        _loading = false;
        _error   = msg;
        if (isCodeError) {
          _step = _ResetStep.code;
          for (final c in _digitCtrls) { c.clear(); }
        }
      });
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => Stack(
            children: [
              const Positioned.fill(child: _TopoBackground()),
              c.maxWidth >= 980
                  ? _buildDesktop(context)
                  : _buildMobile(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          left: 48, top: 36,
          child: _BrandMark(emblemSize: 44, primarySize: 13.5),
        ),
        Positioned(
          right: 48, top: 40,
          child: _BackLink(onTap: () => Navigator.of(context).pop()),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 100, 0, 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 11,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(64, 40, 32, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StepLabel(step: _step, done: _done),
                      const SizedBox(height: 24),
                      _StepTitle(step: _step, done: _done, fontSize: 78, lineHeight: 0.95),
                      if (_step != _ResetStep.email && !_done) ...[
                        const SizedBox(height: 28),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: _EmailHint(email: _email, large: true),
                        ),
                      ],
                      const Spacer(),
                      const _CoordsFooter(monoSize: 11),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _buildCard(compact: false),
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

  Widget _buildMobile(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Row(
                children: [
                  const _BrandMark(emblemSize: 36, primarySize: 13),
                  const Spacer(),
                  _BackLink(onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 28, 4, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepLabel(step: _step, done: _done),
                  const SizedBox(height: 14),
                  _StepTitle(step: _step, done: _done, fontSize: 44, lineHeight: 0.95),
                  if (_step != _ResetStep.email && !_done) ...[
                    const SizedBox(height: 14),
                    _EmailHint(email: _email, large: false),
                  ],
                ],
              ),
            ),
            _buildCard(compact: true),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required bool compact}) {
    if (_done) return _buildDoneCard(compact: compact);
    switch (_step) {
      case _ResetStep.email:    return _buildEmailCard(compact: compact);
      case _ResetStep.code:     return _buildCodeCard(compact: compact);
      case _ResetStep.password: return _buildPasswordCard(compact: compact);
    }
  }

  // ── Email card ───────────────────────────────────────────────────────────────
  Widget _buildEmailCard({required bool compact}) {
    final pH = compact ? 22.0 : 38.0;
    final pT = compact ? 28.0 : 40.0;
    return _CardShell(
      tag: 'RECUPERAR',
      child: Padding(
        padding: EdgeInsets.fromLTRB(pH, pT, pH, pT * 0.7),
        child: Form(
          key: _emailFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Recuperar contraseña',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: compact ? 22 : 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: _C.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ingresa tu correo institucional y te enviaremos un código de 6 dígitos.',
                style: TextStyle(
                  fontSize: compact ? 12.5 : 13.5,
                  color: _C.muted,
                  height: 1.5,
                ),
              ),
              SizedBox(height: compact ? 20 : 26),
              _ResetField(
                controller: _emailCtrl,
                label: 'Correo institucional',
                icon: Icons.alternate_email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _sendCode(),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                  if (!v.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                _ErrorBanner(message: _error!),
              ],
              SizedBox(height: compact ? 14 : 16),
              _ActionButton(
                label: 'Enviar código',
                loading: _loading,
                onPressed: _loading ? null : _sendCode,
              ),
              SizedBox(height: compact ? 14 : 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Code card ────────────────────────────────────────────────────────────────
  Widget _buildCodeCard({required bool compact}) {
    return _CardShell(
      tag: 'CÓDIGO',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 36, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (i) => _DigitBox(
                  controller: _digitCtrls[i],
                  focusNode: _digitNodes[i],
                  onChanged: (v) => _onDigit(i, v),
                  enabled: !_loading,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: _error!),
            ],
            const SizedBox(height: 20),
            _ActionButton(
              label: 'Continuar',
              loading: _loading,
              onPressed: _currentCode.length < 6
                  ? null
                  : () => setState(() { _step = _ResetStep.password; _error = null; }),
            ),
            const SizedBox(height: 12),
            const Divider(color: _C.cardBorder, height: 1),
            const SizedBox(height: 12),
            Center(
              child: _resendLeft > 0
                  ? Text(
                      'Reenviar código en ${_resendLeft}s',
                      style: const TextStyle(fontSize: 12.5, color: _C.subtle),
                    )
                  : InkWell(
                      onTap: _resendCode,
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          'Reenviar código',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _C.terracota,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Password card ────────────────────────────────────────────────────────────
  Widget _buildPasswordCard({required bool compact}) {
    final pH = compact ? 22.0 : 38.0;
    final pT = compact ? 28.0 : 40.0;
    return _CardShell(
      tag: 'NUEVA CLAVE',
      child: Padding(
        padding: EdgeInsets.fromLTRB(pH, pT, pH, pT * 0.7),
        child: Form(
          key: _passFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nueva contraseña',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: compact ? 22 : 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: _C.ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Elige una contraseña segura de al menos 8 caracteres.',
                style: TextStyle(fontSize: 13, color: _C.muted, height: 1.5),
              ),
              SizedBox(height: compact ? 20 : 26),
              _ResetField(
                controller: _passCtrl,
                label: 'Nueva contraseña',
                icon: Icons.lock_outline,
                obscureText: _obscurePass,
                onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                  if (v.length < 8) return 'Mínimo 8 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _ResetField(
                controller: _confirmCtrl,
                label: 'Confirmar contraseña',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirm,
                onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _resetPassword(),
                validator: (v) {
                  if (v != _passCtrl.text) return 'No coincide';
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                _ErrorBanner(message: _error!),
              ],
              SizedBox(height: compact ? 14 : 16),
              _ActionButton(
                label: 'Restablecer contraseña',
                loading: _loading,
                onPressed: _loading ? null : _resetPassword,
              ),
              SizedBox(height: compact ? 14 : 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Done card ────────────────────────────────────────────────────────────────
  Widget _buildDoneCard({required bool compact}) {
    final pH = compact ? 22.0 : 38.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: pH, vertical: 40),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C2D12).withValues(alpha: 0.22),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.check_rounded, size: 28, color: _C.success),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Contraseña restablecida!',
            style: GoogleFonts.spaceGrotesk(
              fontSize: compact ? 20 : 22,
              fontWeight: FontWeight.w700,
              color: _C.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ya puedes iniciar sesión con\ntu nueva contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: _C.muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          _ActionButton(
            label: 'Ir al inicio de sesión',
            loading: false,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// ── Componentes de UI ─────────────────────────────────────────────────────────

class _StepLabel extends StatelessWidget {
  final _ResetStep step;
  final bool done;
  const _StepLabel({required this.step, required this.done});

  @override
  Widget build(BuildContext context) {
    final labels = {
      _ResetStep.email:    'N° 001 · Recuperación',
      _ResetStep.code:     'N° 002 · Verificación',
      _ResetStep.password: 'N° 003 · Nueva clave',
    };
    final text = done ? 'N° 003 · Completado' : labels[step]!;
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 3.3,
        color: _C.terracota,
        fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  final _ResetStep step;
  final bool done;
  final double fontSize;
  final double lineHeight;
  const _StepTitle({
    required this.step,
    required this.done,
    required this.fontSize,
    required this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    final texts = {
      _ResetStep.email:    'Recupera\ntu acceso.',
      _ResetStep.code:     'Revisa\ntu correo.',
      _ResetStep.password: 'Nueva\ncontraseña.',
    };
    final text = done ? '¡Listo!\nAcceso\nrestaurado.' : texts[step]!;
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: -fontSize * 0.04,
        color: _C.ink,
        height: lineHeight,
      ),
    );
  }
}

class _EmailHint extends StatelessWidget {
  final String email;
  final bool large;
  const _EmailHint({required this.email, required this.large});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: large ? 15 : 13.5,
          color: _C.mutedSoft,
          height: 1.55,
        ),
        children: [
          const TextSpan(text: 'Código enviado a '),
          TextSpan(
            text: email,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _C.ink,
              fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
            ),
          ),
          const TextSpan(text: '. Válido 15 min.'),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final String tag;
  final Widget child;
  const _CardShell({required this.tag, required this.child});

  @override
  Widget build(BuildContext context) {
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
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: -20,
              ),
              BoxShadow(
                color: const Color(0xFF7C2D12).withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -8,
              ),
            ],
          ),
          child: child,
        ),
        Positioned(
          top: -14,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _C.ink,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              tag,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
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

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: _C.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: _C.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  const _ActionButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: _C.ink.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: -8,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Material(
        color: enabled ? _C.ink : const Color(0xFFA8A29E),
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
                        valueColor: AlwaysStoppedAnimation<Color>(_C.cream2),
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
                            color: _C.cream2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward, size: 18, color: _C.cream2),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Text field compacto ───────────────────────────────────────────────────────

class _ResetField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;

  const _ResetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
  });

  @override
  State<_ResetField> createState() => _ResetFieldState();
}

class _ResetFieldState extends State<_ResetField> {
  late final FocusNode _focus;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(() => setState(() => _hasFocus = _focus.hasFocus));
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lifted = _hasFocus || widget.controller.text.isNotEmpty;
    final borderColor = _hasFocus ? _C.accent : _C.cardBorder;
    final iconColor   = _hasFocus ? _C.accent : _C.muted;

    return FormField<String>(
      validator: (_) => widget.validator?.call(widget.controller.text),
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.fromLTRB(44, 14, 14, 14),
            decoration: BoxDecoration(
              color: _C.card,
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _hasFocus
                  ? [BoxShadow(color: _C.accent.withValues(alpha: 0.13), blurRadius: 0, spreadRadius: 4)]
                  : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -30, top: 0, bottom: 0,
                  child: Icon(widget.icon, size: 18, color: iconColor),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  left: 0,
                  top: lifted ? -22 : 0,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextStyle(
                      fontSize: lifted ? 11 : 14,
                      fontWeight: lifted ? FontWeight.w600 : FontWeight.w400,
                      letterSpacing: lifted ? 0.55 : 0,
                      color: iconColor,
                    ),
                    child: Container(
                      padding: lifted
                          ? const EdgeInsets.symmetric(horizontal: 6)
                          : EdgeInsets.zero,
                      decoration: lifted
                          ? BoxDecoration(color: _C.card, borderRadius: BorderRadius.circular(4))
                          : null,
                      child: Text(lifted ? widget.label.toUpperCase() : widget.label),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focus,
                        obscureText: widget.obscureText,
                        keyboardType: widget.keyboardType,
                        textInputAction: widget.textInputAction,
                        onSubmitted: widget.onSubmitted,
                        onChanged: (_) => field.didChange(widget.controller.text),
                        style: const TextStyle(fontSize: 14, color: _C.ink),
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
                style: const TextStyle(fontSize: 11, color: _C.danger, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Digit box (OTP) ───────────────────────────────────────────────────────────

class _DigitBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool enabled;
  const _DigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _C.ink,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: _C.bg,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.cardBorder, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.accent, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.cardBorder, width: 1.5),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

// ── Decoración / Header ───────────────────────────────────────────────────────

class _BrandMark extends StatelessWidget {
  final double emblemSize;
  final double primarySize;
  const _BrandMark({required this.emblemSize, required this.primarySize});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SigespuEmblem(size: emblemSize),
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
              style: TextStyle(fontSize: primarySize * 0.72, color: _C.muted, height: 1.1),
            ),
          ],
        ),
      ],
    );
  }
}

class _BackLink extends StatelessWidget {
  final VoidCallback onTap;
  const _BackLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, size: 14, color: _C.mutedSoft),
            SizedBox(width: 6),
            Text(
              'Volver al login',
              style: TextStyle(fontSize: 12.5, color: _C.mutedSoft, fontWeight: FontWeight.w600),
            ),
          ],
        ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '37°05′22″S · 73°09′30″W',
          style: GoogleFonts.jetBrainsMono(
            fontSize: monoSize,
            color: _C.subtle,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: 14),
        Container(width: 1, height: monoSize + 2, color: _C.cardBorder),
        const SizedBox(width: 14),
        Text(
          'Lota · Región del Biobío',
          style: TextStyle(fontSize: monoSize + 0.5, color: _C.muted, letterSpacing: 0.2),
        ),
      ],
    );
  }
}

class _TopoBackground extends StatelessWidget {
  const _TopoBackground();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(painter: _TopoPainter(), size: Size.infinite),
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
  bool shouldRepaint(_TopoPainter old) => false;
}
