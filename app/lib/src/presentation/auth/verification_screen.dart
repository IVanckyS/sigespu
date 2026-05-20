import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/sigespu_emblem.dart';
import 'auth_provider.dart';

// Paleta editorial cream — coherente con auth_screen
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
  static const danger     = Color(0xFFB91C1C);
}

class VerificationScreen extends ConsumerStatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int _resendSecondsLeft = 0;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _resendSecondsLeft = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSecondsLeft <= 1) {
        t.cancel();
        if (mounted) setState(() => _resendSecondsLeft = 0);
      } else {
        if (mounted) setState(() => _resendSecondsLeft--);
      }
    });
  }

  String get _currentCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isEmpty) {
      if (index > 0) _focusNodes[index - 1].requestFocus();
      return;
    }
    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
    if (_currentCode.length == 6 && !_submitted) _submit();
  }

  Future<void> _submit() async {
    if (_submitted) return;
    setState(() => _submitted = true);
    final ok = await ref
        .read(authProvider.notifier)
        .verificarCodigo(widget.email, _currentCode);
    if (!ok && mounted) {
      setState(() => _submitted = false);
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _resend() async {
    if (_resendSecondsLeft > 0) return;
    for (final c in _controllers) {
      c.clear();
    }
    setState(() => _submitted = false);
    await ref.read(authProvider.notifier).reenviarCodigo(widget.email);
    _startResendCooldown();
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= 980;
        return isWide ? _buildDesktop(context) : _buildMobile(context);
      },
    );
  }

  // ── Desktop: split editorial ────────────────────────────────────────────────
  Widget _buildDesktop(BuildContext context) {
    return Stack(
      children: [
        // Sello esquina superior izquierda
        const Positioned(
          left: 48,
          top: 36,
          child: _BrandMark(emblemSize: 44, primarySize: 13.5),
        ),
        // Volver al login
        Positioned(
          right: 48,
          top: 40,
          child: _BackToLoginLink(
            onTap: () => ref.read(authProvider.notifier).clearPendingEmail(),
          ),
        ),
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
                      const SizedBox(height: 28),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: _EmailHint(email: widget.email, large: true),
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
                      child: _verificationCard(compact: false),
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

  // ── Mobile: vertical compacto ───────────────────────────────────────────────
  Widget _buildMobile(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: _BrandMark(emblemSize: 36, primarySize: 13),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 28, 4, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AccessLabel(),
                  const SizedBox(height: 14),
                  const _DisplayTitle(fontSize: 44, lineHeight: 0.95),
                  const SizedBox(height: 14),
                  _EmailHint(email: widget.email, large: false),
                ],
              ),
            ),
            _verificationCard(compact: true),
            const SizedBox(height: 18),
            Center(
              child: _BackToLoginLink(
                onTap: () => ref.read(authProvider.notifier).clearPendingEmail(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _verificationCard({required bool compact}) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

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
            ],
          ),
          padding: const EdgeInsets.fromLTRB(22, 36, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (i) => _DigitBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    onChanged: (v) => _onDigitChanged(i, v),
                    enabled: !isLoading,
                  ),
                ),
              ),
              if (authState.error != null) ...[
                const SizedBox(height: 12),
                Container(
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
                          authState.error!,
                          style: const TextStyle(fontSize: 12, color: _C.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _SubmitButton(
                loading: isLoading,
                onPressed: isLoading || _currentCode.length < 6 ? null : _submit,
              ),
              const SizedBox(height: 12),
              const Divider(color: _C.cardBorder, height: 1),
              const SizedBox(height: 12),
              Center(
                child: _resendSecondsLeft > 0
                    ? Text(
                        'Reenviar código en ${_resendSecondsLeft}s',
                        style: const TextStyle(fontSize: 12.5, color: _C.subtle),
                      )
                    : InkWell(
                        onTap: _resend,
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
              'VERIFICAR',
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

// ── Componentes compartidos (espejan auth_screen) ───────────────────────────

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
              style: TextStyle(
                fontSize: primarySize * 0.72,
                color: _C.muted,
                height: 1.1,
              ),
            ),
          ],
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
      'N° 001 · Verificación',
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

class _DisplayTitle extends StatelessWidget {
  final double fontSize;
  final double lineHeight;
  const _DisplayTitle({required this.fontSize, required this.lineHeight});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Revisa\ntu correo.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: large ? 15 : 13.5,
              color: _C.mutedSoft,
              height: 1.55,
            ),
            children: [
              const TextSpan(text: 'Enviamos un código de 6 dígitos a '),
              TextSpan(
                text: email,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _C.ink,
                  fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Válido por 15 minutos.',
          style: TextStyle(fontSize: large ? 13 : 12, color: _C.subtle),
        ),
      ],
    );
  }
}

class _BackToLoginLink extends StatelessWidget {
  final VoidCallback onTap;
  const _BackToLoginLink({required this.onTap});

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
              'Volver al registro',
              style: TextStyle(
                fontSize: 12.5,
                color: _C.mutedSoft,
                fontWeight: FontWeight.w600,
              ),
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
        Container(
          width: 1,
          height: monoSize + 2,
          color: _C.cardBorder,
        ),
        const SizedBox(width: 14),
        Text(
          'Lota · Región del Biobío',
          style: TextStyle(
            fontSize: monoSize + 0.5,
            color: _C.muted,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ── Inputs y botones ────────────────────────────────────────────────────────

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
          color: const Color(0xFF1C1917),
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

class _SubmitButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  const _SubmitButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C1917).withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: -8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: onPressed == null ? const Color(0xFFA8A29E) : _C.ink,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFF7ED)),
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Verificar código',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFF7ED),
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward, size: 18, color: Color(0xFFFFF7ED)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
