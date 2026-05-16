import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_provider.dart';

// Same palette as auth_screen.dart — some entries reserved for future use
// ignore_for_file: unused_field
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
  static const sandLight = Color(0xFFFED7AA);
  static const cream1 = Color(0xFFFFEDD5);
  static const cream2 = Color(0xFFFFF7ED);
  static const danger = Color(0xFFB91C1C);
  static const success = Color(0xFF16A34A);
}

class VerificationScreen extends ConsumerStatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  ConsumerState<VerificationScreen> createState() =>
      _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

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
    _resendTimer =
        Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSecondsLeft <= 1) {
        t.cancel();
        if (mounted) setState(() => _resendSecondsLeft = 0);
      } else {
        if (mounted) setState(() => _resendSecondsLeft--);
      }
    });
  }

  String get _currentCode =>
      _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isEmpty) {
      // Backspace: move to previous field
      if (index > 0) _focusNodes[index - 1].requestFocus();
      return;
    }
    // Auto-advance
    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
    // Auto-submit when all 6 are filled
    if (_currentCode.length == 6 && !_submitted) {
      _submit();
    }
  }

  Future<void> _submit() async {
    if (_submitted) return;
    setState(() => _submitted = true);
    final ok = await ref
        .read(authProvider.notifier)
        .verificarCodigo(widget.email, _currentCode);
    if (!ok && mounted) {
      setState(() => _submitted = false);
      // Clear fields on error
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
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'N° 001 · Verificación',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.3,
                    color: _C.terracota,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Revisa\ntu correo.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -44 * 0.04,
                    color: _C.ink,
                    height: 0.95,
                  ),
                ),
                const SizedBox(height: 14),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 13.5,
                        color: _C.mutedSoft,
                        height: 1.5),
                    children: [
                      const TextSpan(text: 'Enviamos un código de 6 dígitos a '),
                      TextSpan(
                        text: widget.email,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _C.ink,
                          fontFamily:
                              GoogleFonts.jetBrainsMono().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Válido por 15 minutos.',
                  style: TextStyle(fontSize: 12, color: _C.subtle),
                ),
              ],
            ),
          ),

          // Card
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _C.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _C.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C2D12)
                          .withValues(alpha: 0.22),
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
                    // 6 digit inputs
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

                    // Error
                    if (authState.error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFFCA5A5)),
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
                                    fontSize: 12, color: _C.danger),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Submit button
                    _SubmitButton(
                      loading: isLoading,
                      onPressed:
                          isLoading || _currentCode.length < 6
                              ? null
                              : _submit,
                    ),

                    const SizedBox(height: 16),

                    // Resend
                    Center(
                      child: _resendSecondsLeft > 0
                          ? Text(
                              'Reenviar código en ${_resendSecondsLeft}s',
                              style: const TextStyle(
                                  fontSize: 12.5, color: _C.subtle),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
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
          ),

          const SizedBox(height: 20),

          // Back link
          Center(
            child: InkWell(
              onTap: () =>
                  ref.read(authProvider.notifier).clearPendingEmail(),
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back,
                        size: 14, color: _C.mutedSoft),
                    SizedBox(width: 6),
                    Text(
                      'Volver al registro',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: _C.mutedSoft,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
          fillColor: const Color(0xFFF5EFE6),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: Color(0xFFE7DFD0), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: Color(0xFFEA580C), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: Color(0xFFE7DFD0), width: 1.5),
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
        color: onPressed == null
            ? const Color(0xFFA8A29E)
            : const Color(0xFF1C1917),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 15),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFF7ED)),
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
                        Icon(Icons.arrow_forward,
                            size: 18, color: Color(0xFFFFF7ED)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
