import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import 'auth_provider.dart';

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
    if (val == null || val.trim().isEmpty) return 'Requerido';
    if (!val.contains('@')) return 'Correo inválido';
    final domain = val.split('@').last;
    if (_isRegisterMode && !_allowedDomains.contains(domain)) {
      return 'Solo correos @lota.cl o @munilota.cl';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isRegisterMode) {
      ref.read(authProvider.notifier).register(
        _nombreCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    } else {
      ref.read(authProvider.notifier).login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.isAuthenticated) context.go('/map');
    });

    return Scaffold(
      backgroundColor: AppTheme.stone100,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Logo
                Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(
                      color: AppTheme.blue800, shape: BoxShape.circle),
                  child: const Icon(Icons.shield,
                      color: AppTheme.orange600, size: 36),
                ),
                const SizedBox(height: 20),
                const Text('SIGESPU Lota',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.stone900,
                        letterSpacing: -0.5)),
                const SizedBox(height: 6),
                const Text('Ilustre Municipalidad de Lota',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.stone400,
                        letterSpacing: 0.06)),
                const SizedBox(height: 28),

                // Título del modo
                Text(
                  _isRegisterMode
                      ? 'Crear cuenta municipal'
                      : 'Iniciar sesión',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.stone900),
                ),
                const SizedBox(height: 20),

                // Error banner
                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.redDanger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppTheme.redDanger.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.redDanger, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(authState.error!,
                              style: const TextStyle(
                                  color: AppTheme.redDanger, fontSize: 13))),
                    ]),
                  ),

                // Campo nombre (solo registro)
                if (_isRegisterMode) ...[
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requerido' : null,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),
                ],

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo institucional',
                    hintText: _isRegisterMode
                        ? 'funcionario@munilota.cl'
                        : null,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 14),

                // Password
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Requerido' : null,
                ),

                // Confirmar password (solo registro)
                if (_isRegisterMode) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) => v != _passwordCtrl.text
                        ? 'Las contraseñas no coinciden'
                        : null,
                  ),
                ],

                const SizedBox(height: 24),

                // Aviso de modo visitante (solo registro)
                if (_isRegisterMode)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.orange50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.orange100),
                    ),
                    child: const Text(
                      'Tu cuenta iniciará en modo Visitante (solo lectura). Para acceso operativo, solicítalo desde la app una vez dentro.',
                      style: TextStyle(
                          fontSize: 11.5, color: AppTheme.orange700),
                    ),
                  ),

                // Botón principal
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            _isRegisterMode
                                ? 'Crear cuenta'
                                : 'Iniciar sesión',
                            style: const TextStyle(fontSize: 15)),
                  ),
                ),

                const SizedBox(height: 16),

                // Toggle login/registro
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    _isRegisterMode
                        ? '¿Ya tienes cuenta?'
                        : '¿Primera vez?',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppTheme.stone500),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () => setState(() {
                      _isRegisterMode = !_isRegisterMode;
                      _formKey.currentState?.reset();
                      _emailCtrl.clear();
                      _passwordCtrl.clear();
                      _nombreCtrl.clear();
                      _confirmCtrl.clear();
                    }),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text(
                      _isRegisterMode
                          ? 'Inicia sesión'
                          : 'Regístrate con tu correo municipal',
                      style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.orange600,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
