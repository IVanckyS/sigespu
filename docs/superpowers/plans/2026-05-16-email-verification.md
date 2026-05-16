# Email Verification on Register — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Intercept the registration flow with a 6-digit email verification step before creating the user in the database.

**Architecture:** On `POST /auth/register`, the backend stores a pending registration (nombre + password_hash + code_hash) in Redis with 15-min TTL and fires an HTML email via Gmail SMTP. A new `POST /auth/verificar` endpoint validates the code and creates the user. The app renders a `VerificationScreen` with 6 auto-advancing digit fields when `authState.pendingEmail` is set.

**Tech Stack:** Dart/Shelf backend · `mailer ^6.1.0` (Gmail SMTP) · `redis` Command API · Flutter Riverpod · `TextEditingController` per digit

---

## File Map

| Action | File |
|---|---|
| CREATE | `backend/lib/src/services/email_service.dart` |
| MODIFY | `backend/lib/src/auth/auth_handler.dart` |
| MODIFY | `backend/bin/server.dart` |
| MODIFY | `backend/pubspec.yaml` |
| MODIFY | `.env` and `.env.example` |
| CREATE | `backend/test/email_service_test.dart` |
| MODIFY | `app/lib/src/presentation/auth/auth_provider.dart` |
| CREATE | `app/lib/src/presentation/auth/verification_screen.dart` |
| MODIFY | `app/lib/src/presentation/auth/auth_screen.dart` |

---

## Task 1: Backend — Add mailer dependency and SMTP env vars

**Files:**
- Modify: `backend/pubspec.yaml`
- Modify: `.env.example`
- Modify: `.env`

- [ ] **Step 1: Add mailer to pubspec.yaml**

In `backend/pubspec.yaml`, add under `dependencies:`:
```yaml
  mailer: ^6.1.0
```
Final dependencies block should look like:
```yaml
dependencies:
  shelf: ^1.4.1
  shelf_router: ^1.1.4
  postgres: ^3.1.1
  redis: ^3.0.0
  dart_jsonwebtoken: ^2.11.0
  bcrypt: ^1.1.3
  logger: ^2.0.2
  cron: ^0.6.0
  uuid: ^4.2.1
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  mailer: ^6.1.0
  shared:
    path: ../shared
  archive: ^3.6.0
  xml: ^6.5.0
  http: ^1.2.0
```

- [ ] **Step 2: Run dart pub get in backend**

```bash
cd backend && dart pub get
```
Expected: resolves mailer and prints `Changed N dependencies!`

- [ ] **Step 3: Add SMTP vars to .env.example**

Append to `.env.example`:
```
# Email (Gmail SMTP)
SMTP_USER=sigespulota@gmail.com
SMTP_PASS=<app-password-16-chars-sin-espacios>
```

- [ ] **Step 4: Add SMTP vars to .env**

Append to `.env` (real values, never commitear):
```
SMTP_USER=sigespulota@gmail.com
SMTP_PASS=<el-app-password-real-sin-espacios>
```

- [ ] **Step 5: Commit**

```bash
git add backend/pubspec.yaml backend/pubspec.lock .env.example
git commit -m "chore: add mailer dependency and SMTP env vars"
```

---

## Task 2: Backend — EmailService (SMTP + HTML template)

**Files:**
- Create: `backend/lib/src/services/email_service.dart`
- Create: `backend/test/email_service_test.dart`

- [ ] **Step 1: Create email_service.dart**

Create `backend/lib/src/services/email_service.dart`:

```dart
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {
  final String _user;
  final String _pass;

  EmailService()
      : _user = Platform.environment['SMTP_USER'] ?? '',
        _pass = Platform.environment['SMTP_PASS'] ?? '';

  Future<void> sendVerificationCode(
      String toEmail, String nombre, String codigo) async {
    final smtpServer = gmail(_user, _pass);
    final message = Message()
      ..from = Address(_user, 'SIGESPU Lota')
      ..recipients.add(toEmail)
      ..subject = 'Activa tu cuenta SIGESPU · Código de verificación'
      ..html = buildHtml(nombre, codigo);

    try {
      await send(message, smtpServer);
    } catch (e) {
      print('[EmailService] Error al enviar correo a $toEmail: $e');
    }
  }

  static String buildHtml(String nombre, String codigo) {
    final now = DateTime.now();
    final expira = now.add(const Duration(minutes: 15));
    final ref =
        'REF–${now.year}-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    final expiraStr =
        '${expira.day} de ${months[expira.month - 1]} de ${expira.year}, '
        '${expira.hour.toString().padLeft(2, '0')}:${expira.minute.toString().padLeft(2, '0')}';

    final codeBoxes = codigo.split('').map((d) => '''
      <td style="width:48px;height:56px;background:#F5EFE6;border:1.5px solid #E7DFD0;
        border-radius:10px;text-align:center;vertical-align:middle;
        font-family:'Courier New',Courier,monospace;font-size:24px;
        font-weight:700;color:#1C1917;">$d</td>
      <td style="width:8px;"></td>
    ''').join();

    return '''
<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:32px;background:#E5E7EB;font-family:Arial,sans-serif;">
<div style="max-width:600px;margin:0 auto;background:#F5EFE6;border-radius:18px;border:1px solid #E7DFD0;overflow:hidden;">

  <div style="padding:20px 32px;border-bottom:1px solid #E7DFD0;">
    <table style="width:100%;border-spacing:0;"><tr>
      <td><div style="font-size:15px;font-weight:700;color:#1C1917;">SIGESPU</div>
          <div style="font-size:10px;color:#78716C;letter-spacing:0.18em;text-transform:uppercase;margin-top:2px;">Ilustre Municipalidad de Lota</div></td>
      <td style="text-align:right;"><span style="font-family:'Courier New',monospace;font-size:10px;color:#9A3412;background:#FFF7ED;padding:5px 10px;border-radius:6px;font-weight:600;border:1px solid #FED7AA;">$ref</span></td>
    </tr></table>
  </div>

  <div style="padding:40px 44px 28px;">
    <div style="font-size:10px;font-weight:700;letter-spacing:0.3em;text-transform:uppercase;color:#9A3412;margin-bottom:18px;">N° 001 · Activación de cuenta</div>
    <h1 style="font-size:44px;line-height:1;font-weight:700;letter-spacing:-0.03em;color:#1C1917;margin:0 0 18px 0;">
      Bienvenido,<br><span style="color:#EA580C;font-style:italic;font-weight:500;">$nombre</span>.
    </h1>
    <p style="font-size:15px;line-height:1.65;color:#44403C;margin:0;">
      Tu cuenta institucional en <strong style="color:#1C1917;">SIGESPU · Lota</strong> está lista.
      Ingresa el código de activación en la aplicación para completar tu registro.
    </p>
  </div>

  <div style="padding:0 32px 24px;">
    <div style="background:#FFFEFB;border:1px solid #E7DFD0;border-radius:16px;padding:28px;">
      <div style="font-size:14px;font-weight:700;color:#1C1917;margin-bottom:4px;">Código de verificación</div>
      <div style="font-size:12px;color:#78716C;margin-bottom:18px;">Válido por <strong style="color:#9A3412;">15 minutos</strong>. No lo compartas con nadie.</div>
      <table style="border-spacing:0;border-collapse:separate;"><tr>$codeBoxes</tr></table>
      <div style="margin-top:14px;font-size:12px;color:#78716C;">
        Vence el <strong style="color:#1C1917;">$expiraStr</strong>
      </div>
    </div>
  </div>

  <div style="padding:0 32px 24px;">
    <div style="background:#FFF7ED;border:1px solid #FED7AA;border-radius:12px;padding:14px 18px;font-size:12px;color:#7C2D12;line-height:1.55;">
      <strong>¿No solicitaste este acceso?</strong> Ignora este correo. Esta solicitud expirará automáticamente en 15 minutos.
    </div>
  </div>

  <div style="padding:22px 44px 26px;border-top:1px solid #E7DFD0;background:#EFE7DA;">
    <div style="font-size:11px;color:#78716C;line-height:1.7;">
      <strong style="font-size:12px;color:#1C1917;">Ilustre Municipalidad de Lota</strong><br>
      Dirección de Seguridad Pública · Aníbal Pinto 442, Lota · SIGESPU v1.0.0
    </div>
  </div>

</div>
</body>
</html>
''';
  }
}
```

- [ ] **Step 2: Write unit test for buildHtml**

Create `backend/test/email_service_test.dart`:

```dart
import 'package:test/test.dart';
import '../lib/src/services/email_service.dart';

void main() {
  group('EmailService.buildHtml', () {
    test('contains nombre in output', () {
      final html = EmailService.buildHtml('Juan Pérez', '483920');
      expect(html, contains('Juan Pérez'));
    });

    test('renders each digit as a separate cell', () {
      final html = EmailService.buildHtml('Ana', '123456');
      for (final d in ['1', '2', '3', '4', '5', '6']) {
        expect(html, contains('>$d<'));
      }
    });

    test('contains 15 minutos expiry text', () {
      final html = EmailService.buildHtml('Luis', '000000');
      expect(html, contains('15 minutos'));
    });

    test('contains REF– reference', () {
      final html = EmailService.buildHtml('María', '111111');
      expect(html, contains('REF–'));
    });
  });
}
```

- [ ] **Step 3: Run the tests**

```bash
cd backend && dart test test/email_service_test.dart
```
Expected: `All tests passed.` (4 tests)

- [ ] **Step 4: Commit**

```bash
git add backend/lib/src/services/email_service.dart backend/test/email_service_test.dart
git commit -m "feat: add EmailService with Gmail SMTP and HTML cream editorial template"
```

---

## Task 3: Backend — Helper methods in AuthHandler

**Files:**
- Modify: `backend/lib/src/auth/auth_handler.dart`

Add the two helper methods and required imports to `AuthHandler`. These are used by Tasks 4, 5, and 6.

- [ ] **Step 1: Add imports at top of auth_handler.dart**

The file currently imports `dart:convert`, `package:shelf/shelf.dart`, etc. Add these two:

```dart
import 'dart:async' show unawaited;
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../services/email_service.dart';
```

(`crypto` is already a transitive dependency via `dart_jsonwebtoken`; add it explicitly to `pubspec.yaml` if `dart pub get` complains — add `crypto: ^3.0.3` under dependencies.)

- [ ] **Step 2: Add EmailService field and update constructor**

Change the class fields and constructor:

```dart
class AuthHandler {
  final DatabaseService _dbService;
  final JwtService _jwtService;
  final EmailService _emailService;

  static const allowedDomains = ['lota.cl', 'munilota.cl'];

  AuthHandler(this._dbService, this._jwtService, this._emailService);
```

- [ ] **Step 3: Add helper methods at the bottom of AuthHandler (before the closing `}`)**

```dart
  static String _generateCode() {
    final rng = Random.secure();
    return List.generate(6, (_) => rng.nextInt(10)).join();
  }

  static String _hashCode(String code) {
    final bytes = utf8.encode(code);
    return sha256.convert(bytes).toString();
  }
```

- [ ] **Step 4: Compile check**

```bash
cd backend && dart analyze lib/src/auth/auth_handler.dart
```
Expected: `No issues found!` (constructor arity error is expected until server.dart is updated in Task 7 — that's fine for now, analyze per-file)

- [ ] **Step 5: Commit**

```bash
git add backend/lib/src/auth/auth_handler.dart
git commit -m "feat: add _generateCode and _hashCode helpers + EmailService field to AuthHandler"
```

---

## Task 4: Backend — Rewrite _register to Redis-pending flow

**Files:**
- Modify: `backend/lib/src/auth/auth_handler.dart`

Replace the entire `_register` method body. The method signature stays the same.

- [ ] **Step 1: Replace _register method**

Replace the current `_register` method with:

```dart
  Future<Response> _register(Request req) async {
    final body = await req.readAsString();
    final data = jsonDecode(body);
    final emailRaw = data['email'] as String?;
    final nombre = data['nombre'] as String?;
    final password = data['password'] as String?;

    if (emailRaw == null || nombre == null || password == null) {
      return Response.badRequest(
          body: jsonEncode({'error': 'Faltan campos requeridos'}));
    }

    final email = emailRaw.trim().toLowerCase();
    final domainParts = email.split('@');
    if (domainParts.length != 2 ||
        !allowedDomains.contains(domainParts.last)) {
      return Response.forbidden(jsonEncode(
          {'error': 'Solo funcionarios municipales de Lota pueden registrarse'}));
    }

    // Reject if email already registered in usuarios table
    final existing = await _dbService.db.execute(
      Sql.named('SELECT id FROM usuarios WHERE email = @email'),
      parameters: {'email': email},
    );
    if (existing.isNotEmpty) {
      return Response(409,
          body: jsonEncode({'error': 'El email ya está registrado'}));
    }

    // Reject if there is already a pending verification for this email
    final pendingKey = 'verif:$email';
    final alreadyPending =
        await _dbService.redis.send_object(['GET', pendingKey]);
    if (alreadyPending != null) {
      return Response(409,
          body: jsonEncode({
            'error':
                'Ya hay un registro pendiente de verificación para este correo. Revisa tu bandeja de entrada o espera 15 minutos.'
          }));
    }

    final hash = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));
    final codigo = _generateCode();
    final codigoHash = _hashCode(codigo);

    final payload = jsonEncode({
      'nombre': nombre,
      'password_hash': hash,
      'codigo_hash': codigoHash,
      'intentos': 0,
      'reenvio_at': null,
    });

    await _dbService.redis
        .send_object(['SET', pendingKey, payload, 'EX', 900]);

    unawaited(_emailService.sendVerificationCode(email, nombre, codigo));

    return Response.ok(
      jsonEncode({'message': 'Código enviado a $email'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
```

- [ ] **Step 2: Verify no syntax errors**

```bash
cd backend && dart analyze lib/src/auth/auth_handler.dart
```
Expected: `No issues found!` (ignore the constructor arity issue in server.dart for now)

- [ ] **Step 3: Commit**

```bash
git add backend/lib/src/auth/auth_handler.dart
git commit -m "feat: register now stores pending in Redis and sends verification email"
```

---

## Task 5: Backend — Add _verificar endpoint

**Files:**
- Modify: `backend/lib/src/auth/auth_handler.dart`

- [ ] **Step 1: Add /verificar route to router getter**

In the `router` getter, after `router.post('/logout', _logout);`, add only this line (the `/reenviar-codigo` route is added in Task 6 after its method is defined):

```dart
    router.post('/verificar', _verificar);
```

- [ ] **Step 2: Add _verificar method**

Add this method to `AuthHandler` (before the closing `}` of the class):

```dart
  Future<Response> _verificar(Request req) async {
    final body = await req.readAsString();
    final data = jsonDecode(body);
    final emailRaw = data['email'] as String?;
    final codigo = data['codigo'] as String?;

    if (emailRaw == null || codigo == null) {
      return Response.badRequest(
          body: jsonEncode({'error': 'Faltan campos requeridos'}));
    }

    final email = emailRaw.trim().toLowerCase();
    final pendingKey = 'verif:$email';

    final raw =
        await _dbService.redis.send_object(['GET', pendingKey]);
    if (raw == null) {
      return Response.notFound(
          jsonEncode({'error': 'El código expiró. Regístrate de nuevo.'}));
    }

    final pending =
        jsonDecode(raw as String) as Map<String, dynamic>;
    final codigoHash = _hashCode(codigo);

    if (codigoHash != pending['codigo_hash']) {
      int intentos = (pending['intentos'] as int) + 1;

      if (intentos >= 5) {
        await _dbService.redis.send_object(['DEL', pendingKey]);
        return Response(429,
            body: jsonEncode(
                {'error': 'Demasiados intentos. Regístrate de nuevo.'}));
      }

      // Preserve remaining TTL when updating attempt count
      final ttlRaw =
          await _dbService.redis.send_object(['TTL', pendingKey]);
      final ttl = (ttlRaw as int) > 0 ? ttlRaw : 900;

      pending['intentos'] = intentos;
      await _dbService.redis.send_object(
          ['SET', pendingKey, jsonEncode(pending), 'EX', ttl]);

      return Response.unauthorized(jsonEncode({
        'error':
            'Código incorrecto. Intentos restantes: ${5 - intentos}',
      }));
    }

    // Code correct — create the user
    final nombre = pending['nombre'] as String;
    final passwordHash = pending['password_hash'] as String;

    try {
      final result = await _dbService.db.execute(
        Sql.named(
            'INSERT INTO usuarios (email, nombre, password_hash, nivel_acceso) '
            'VALUES (@email, @nombre, @hash, @nivel) '
            'RETURNING id, nivel_acceso, solicitud_operativo'),
        parameters: {
          'email': email,
          'nombre': nombre,
          'hash': passwordHash,
          'nivel': 'visitante',
        },
      );

      await _dbService.redis.send_object(['DEL', pendingKey]);

      final row = result.first;
      final userId = row[0] as String;
      final nivelAcceso = row[1] as String;
      final solicitudOperativo = row[2] as String?;

      final accessToken =
          _jwtService.generateAccessToken(userId, nivelAcceso);
      final refreshData =
          await _jwtService.createRefreshToken(userId);

      return Response.ok(
        jsonEncode({
          'access_token': accessToken,
          'refresh_token': refreshData['token'],
          'user': {
            'id': userId,
            'email': email,
            'nombre': nombre,
            'nivel_acceso': nivelAcceso,
            'solicitud_operativo': solicitudOperativo,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      if (e.toString().contains('usuarios_email_key')) {
        await _dbService.redis.send_object(['DEL', pendingKey]);
        return Response(409,
            body: jsonEncode({'error': 'El email ya está registrado'}));
      }
      return Response.internalServerError(
          body: jsonEncode({'error': 'Error de servidor'}));
    }
  }
```

- [ ] **Step 3: Commit**

```bash
git add backend/lib/src/auth/auth_handler.dart
git commit -m "feat: add POST /auth/verificar endpoint"
```

---

## Task 6: Backend — Add _reenviarCodigo endpoint + wire EmailService in server.dart

**Files:**
- Modify: `backend/lib/src/auth/auth_handler.dart`
- Modify: `backend/bin/server.dart`

- [ ] **Step 1: Add _reenviarCodigo method to AuthHandler**

Add to `AuthHandler` (before the closing `}`):

```dart
  Future<Response> _reenviarCodigo(Request req) async {
    final body = await req.readAsString();
    final data = jsonDecode(body);
    final emailRaw = data['email'] as String?;

    if (emailRaw == null) {
      return Response.badRequest(
          body: jsonEncode({'error': 'Falta el email'}));
    }

    final email = emailRaw.trim().toLowerCase();
    final pendingKey = 'verif:$email';

    final raw =
        await _dbService.redis.send_object(['GET', pendingKey]);
    if (raw == null) {
      return Response.notFound(jsonEncode(
          {'error': 'No hay registro pendiente para este correo'}));
    }

    final pending =
        jsonDecode(raw as String) as Map<String, dynamic>;

    final reenvioAt = pending['reenvio_at'] as String?;
    if (reenvioAt != null) {
      final lastSent = DateTime.parse(reenvioAt);
      final elapsed = DateTime.now().difference(lastSent).inSeconds;
      if (elapsed < 60) {
        return Response(429,
            body: jsonEncode({
              'error':
                  'Espera ${60 - elapsed} segundos antes de reenviar',
            }));
      }
    }

    final newCodigo = _generateCode();
    pending['codigo_hash'] = _hashCode(newCodigo);
    pending['intentos'] = 0;
    pending['reenvio_at'] = DateTime.now().toIso8601String();

    // Reset TTL to 900 on resend (user gets a fresh 15 minutes)
    await _dbService.redis.send_object(
        ['SET', pendingKey, jsonEncode(pending), 'EX', 900]);

    final nombre = pending['nombre'] as String;
    unawaited(_emailService.sendVerificationCode(email, nombre, newCodigo));

    return Response.ok(
      jsonEncode({'message': 'Código reenviado a $email'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
```

- [ ] **Step 2: Add /reenviar-codigo route to router getter**

In `auth_handler.dart`, inside the `router` getter, after `router.post('/verificar', _verificar);`, add:

```dart
    router.post('/reenviar-codigo', _reenviarCodigo);
```

- [ ] **Step 3: Update server.dart to instantiate and inject EmailService**

In `backend/bin/server.dart`, add the import:

```dart
import '../lib/src/services/email_service.dart';
```

Then in `main()`, change:

```dart
  final jwtService = JwtService(dbService);
  final authHandler = AuthHandler(dbService, jwtService);
```

to:

```dart
  final jwtService = JwtService(dbService);
  final emailService = EmailService();
  final authHandler = AuthHandler(dbService, jwtService, emailService);
```

- [ ] **Step 4: Full backend analyze**

```bash
cd backend && dart analyze
```
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add backend/lib/src/auth/auth_handler.dart backend/bin/server.dart
git commit -m "feat: add POST /auth/reenviar-codigo endpoint and wire EmailService into server"
```

---

## Task 7: App — Extend AuthState and AuthNotifier

**Files:**
- Modify: `app/lib/src/presentation/auth/auth_provider.dart`

- [ ] **Step 1: Replace AuthState class**

Replace the entire `AuthState` class with a version that supports `pendingEmail` and proper null-clearing via sentinel:

```dart
const _absent = Object();

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;
  final String? pendingEmail;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.pendingEmail,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    Object? error = _absent,
    Map<String, dynamic>? user,
    Object? pendingEmail = _absent,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _absent) ? this.error : error as String?,
      user: user ?? this.user,
      pendingEmail: identical(pendingEmail, _absent)
          ? this.pendingEmail
          : pendingEmail as String?,
    );
  }
}
```

- [ ] **Step 2: Update all existing copyWith calls in AuthNotifier**

The existing calls use `error: null` to clear errors. With the new sentinel, `error: null` correctly clears (since `null != _absent`). Scan the file and change the one call that sets `error: null` as a loading indicator:

```dart
// Change this pattern (in login, register, solicitarAcceso):
state = state.copyWith(isLoading: true, error: null);
// to:
state = state.copyWith(isLoading: true, error: null);
// No change needed — null now correctly clears error with the sentinel pattern.
```

- [ ] **Step 3: Replace register() method**

Replace the current `register()` method:

```dart
  Future<bool> register(String nombre, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'email': normalizeEmail(email),
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          pendingEmail: normalizeEmail(email),
          error: null,
        );
        return true;
      } else {
        final data = jsonDecode(response.body);
        state = state.copyWith(
            isLoading: false,
            error: data['error'] ?? 'Error al registrarse');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          error: 'Error de conexión con el servidor');
      return false;
    }
  }
```

- [ ] **Step 4: Add verificarCodigo() method**

Add after `register()`:

```dart
  Future<bool> verificarCodigo(String email, String codigo) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verificar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'codigo': codigo}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(
            key: 'access_token', value: data['access_token']);
        await _storage.write(
            key: 'refresh_token', value: data['refresh_token']);
        await _storage.write(
            key: 'user_info', value: jsonEncode(data['user']));
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: data['user'] as Map<String, dynamic>,
          pendingEmail: null,
          error: null,
        );
        return true;
      } else {
        final data = jsonDecode(response.body);
        state = state.copyWith(
            isLoading: false,
            error: data['error'] ?? 'Error al verificar código');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          error: 'Error de conexión con el servidor');
      return false;
    }
  }
```

- [ ] **Step 5: Add reenviarCodigo() method**

Add after `verificarCodigo()`:

```dart
  Future<bool> reenviarCodigo(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reenviar-codigo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
```

- [ ] **Step 6: Add clearPendingEmail() method**

Add after `reenviarCodigo()` (used by the "Volver" button):

```dart
  void clearPendingEmail() {
    state = state.copyWith(pendingEmail: null, error: null);
  }
```

- [ ] **Step 7: Verify no analysis errors**

```bash
cd app && flutter analyze lib/src/presentation/auth/auth_provider.dart
```
Expected: `No issues found!`

- [ ] **Step 8: Commit**

```bash
git add app/lib/src/presentation/auth/auth_provider.dart
git commit -m "feat: add pendingEmail to AuthState, verificarCodigo and reenviarCodigo to AuthNotifier"
```

---

## Task 8: App — VerificationScreen widget

**Files:**
- Create: `app/lib/src/presentation/auth/verification_screen.dart`

- [ ] **Step 1: Create verification_screen.dart**

Create `app/lib/src/presentation/auth/verification_screen.dart`:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_provider.dart';

// Same palette as auth_screen.dart
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
                Text(
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
                    style: TextStyle(
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
                Text(
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
                              style: TextStyle(
                                  fontSize: 12.5, color: _C.subtle),
                            )
                          : InkWell(
                              onTap: _resend,
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
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
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back,
                        size: 14, color: _C.mutedSoft),
                    const SizedBox(width: 6),
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
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Verificar código',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFF7ED),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward,
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
```

- [ ] **Step 2: Verify**

```bash
cd app && flutter analyze lib/src/presentation/auth/verification_screen.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add app/lib/src/presentation/auth/verification_screen.dart
git commit -m "feat: add VerificationScreen with 6-digit auto-advancing input and resend timer"
```

---

## Task 9: App — Wire VerificationScreen into AuthScreen

**Files:**
- Modify: `app/lib/src/presentation/auth/auth_screen.dart`

- [ ] **Step 1: Add import for VerificationScreen**

At the top of `auth_screen.dart`, add:

```dart
import 'verification_screen.dart';
```

- [ ] **Step 2: Update the ref.listen block in _AuthScreenState.build()**

The current `ref.listen` only handles `isAuthenticated`. Update it so that when `pendingEmail` becomes non-null, the screen swaps to `VerificationScreen`. The swap is handled in the `build()` method:

Find this in `_AuthScreenState.build()`:

```dart
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 980;
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
```

Replace with:

```dart
    // Show verification screen when pending email is set
    if (authState.pendingEmail != null) {
      return Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: _TopoBackground()),
              VerificationScreen(email: authState.pendingEmail!),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 980;
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
```

- [ ] **Step 3: Full app analyze**

```bash
cd app && flutter analyze
```
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add app/lib/src/presentation/auth/auth_screen.dart
git commit -m "feat: show VerificationScreen when pendingEmail is set after registration"
```

---

## Task 10: Integration smoke test

Manual verification that the full flow works end-to-end.

- [ ] **Step 1: Start backend and dependencies**

```bash
docker compose up -d postgres redis
cd backend && dart run bin/server.dart
```
Expected: `Connected to PostgreSQL and Redis` and `Server listening on port 8080`

- [ ] **Step 2: Test register endpoint**

```bash
curl -s -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Test User","email":"test@lota.cl","password":"Test1234!"}' | jq .
```
Expected: `{ "message": "Código enviado a test@lota.cl" }`

- [ ] **Step 3: Check Redis for pending key**

```bash
docker compose exec redis redis-cli GET "verif:test@lota.cl"
```
Expected: JSON string with `nombre`, `password_hash`, `codigo_hash`, `intentos: 0`, `reenvio_at: null`

- [ ] **Step 4: Test wrong code (5 times)**

```bash
curl -s -X POST http://localhost:8080/auth/verificar \
  -H "Content-Type: application/json" \
  -d '{"email":"test@lota.cl","codigo":"000000"}' | jq .
```
Expected first 4 tries: `{ "error": "Código incorrecto. Intentos restantes: N" }`  
Expected 5th try: `{ "error": "Demasiados intentos. Regístrate de nuevo." }` (HTTP 429)

- [ ] **Step 5: Test blocked domain**

```bash
curl -s -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Ext","email":"test@gmail.com","password":"Test1234!"}' | jq .
```
Expected: HTTP 403 `{ "error": "Solo funcionarios municipales..." }`

- [ ] **Step 6: Run app and test full UI flow**

```bash
cd app && flutter run -d chrome
```
1. Click "Solicita acceso" to go to register form
2. Fill nombre, correo @lota.cl or @munilota.cl, contraseña
3. Submit → VerificationScreen appears with the correct email
4. Check the real inbox for the HTML email
5. Enter the 6-digit code → redirected to /map
6. Click "Volver al registro" → returns to the register form
