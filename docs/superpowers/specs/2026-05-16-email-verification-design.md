# Verificación de correo en registro — Diseño

**Fecha:** 2026-05-16  
**Estado:** Aprobado  
**Contexto:** Sprint 0 — Auth

---

## Problema

El flujo de registro actual crea al usuario y devuelve JWT de inmediato, sin verificar que el correo institucional pertenezca realmente al funcionario. Cualquiera con acceso al formulario podría registrarse con un email `@lota.cl` o `@munilota.cl` falso.

---

## Alcance

- Afecta **únicamente** el registro de nuevos usuarios vía `POST /auth/register`.
- Los usuarios creados por seed (director y otros) tienen `activo = true` directamente en BD — no pasan por este flujo.
- El flujo de login (`POST /auth/login`) no cambia.

---

## Decisiones de diseño

| Decisión | Valor | Razón |
|---|---|---|
| Almacenamiento pending | Redis, TTL 15 min | Sin migración de BD; expiración automática |
| Código | 6 dígitos numéricos (0–9) | Fácil de escribir en móvil; sin ambigüedad O/0 I/1 |
| Intentos máximos | 5, luego se invalida la key | Anti-brute-force sobre 10^6 combinaciones |
| Reenvío | Sí, cooldown 60 seg | Genera nuevo código, resetea intentos y TTL |
| TTL del código | 15 minutos | Seguridad; correo institucional se revisa rápido |
| Envío email | `mailer` ^6.1 + Gmail SMTP (sigespulota@gmail.com) | Sin cuenta extra, sin OAuth2 |
| Email body | HTML cream editorial (igual al mockup `Correo de Activación.html`) | Consistencia de marca |
| Sender display | `SIGESPU Lota <sigespulota@gmail.com>` | Identificable en bandeja |
| Email enviado en | Background (no bloquea HTTP response) | UX más rápida; fallo de SMTP no bloquea flujo |

---

## Flujo completo

```
[App] Formulario registro (nombre + email + contraseña)
       ↓ POST /auth/register
[Backend]
  1. Valida dominio @lota.cl / @munilota.cl
  2. Verifica que no exista ya usuario con ese email en usuarios
  3. Verifica que no exista ya key "verif:{email}" en Redis (registro duplicado en curso)
  4. Hash bcrypt de la contraseña (cost 12)
  5. Genera código 6 dígitos aleatorios
  6. Hash SHA-256 del código
  7. Guarda en Redis key="verif:{email}":
       { nombre, password_hash, codigo_hash, intentos: 0, reenvio_at: null }
       TTL = 900 seg (15 min)
  8. Dispara envío de email en background (unawaited Future)
  9. Responde 200 { message: "Código enviado a {email}" }
       ↓
[App] Muestra VerificationScreen con email del destinatario
       ↓ Usuario ingresa 6 dígitos → POST /auth/verificar { email, codigo }
[Backend]
  1. Busca key "verif:{email}" en Redis
  2. Si no existe → 404 "El código expiró. Regístrate de nuevo."
  3. SHA-256 del codigo recibido vs codigo_hash almacenado
  4. Si no coincide:
       - incrementa intentos
       - si intentos >= 5 → elimina key → 429 "Demasiados intentos. Regístrate de nuevo."
       - si intentos < 5 → 401 "Código incorrecto. Intentos restantes: {5-intentos}"
  5. Si coincide:
       - INSERT INTO usuarios (email, nombre, password_hash, nivel_acceso='visitante', activo=true)
       - Si UNIQUE violation → 409 "El email ya está registrado" (race condition)
       - Elimina key "verif:{email}" de Redis
       - Genera access_token + refresh_token
       - Responde 200 { access_token, refresh_token, user }
       ↓
[App] Guarda tokens, autentica, redirige a /map

[Reenvío]
       ↓ POST /auth/reenviar-codigo { email }
[Backend]
  1. Busca key "verif:{email}" en Redis — si no existe → 404
  2. Verifica reenvio_at: si no es null y han pasado menos de 60 seg → 429 "Espera antes de reenviar" (si es null = primer reenvío, procede sin cooldown)
  3. Genera nuevo código, nuevo hash, resetea intentos a 0, actualiza reenvio_at
  4. Reescribe key con TTL fresco (900 seg)
  5. Dispara envío de email en background
  6. Responde 200 { message: "Código reenviado" }
```

---

## Cambios en backend

### Nueva dependencia: `backend/pubspec.yaml`
```yaml
mailer: ^6.1.0
```

### Nuevas variables de entorno: `.env` / `.env.example`
```
SMTP_USER=sigespulota@gmail.com
SMTP_PASS=<app-password-16-chars-sin-espacios>
```

### Nuevo archivo: `backend/lib/src/services/email_service.dart`
- Clase `EmailService` con método `sendVerificationCode(String email, String nombre, String codigo)`
- Conecta a `smtp.gmail.com:587` con STARTTLS
- Genera HTML del correo (cream editorial, igual al mockup)
- Referencia dinámica: `REF–{año}-{mes}{dia}` (ej. `REF–2026-0516`)
- Subject: `Activa tu cuenta SIGESPU · Código de verificación`
- From: `SIGESPU Lota <sigespulota@gmail.com>`
- Se inyecta en `AuthHandler` como dependencia

### Cambios en `backend/lib/src/auth/auth_handler.dart`
- `_register`: cambia comportamiento — ya no inserta en `usuarios` ni devuelve JWT. Guarda en Redis y envía email.
- Nuevos endpoints:
  - `POST /verificar` → `_verificar`
  - `POST /reenviar-codigo` → `_reenviarCodigo`
- Se añade `EmailService` como campo del handler

### Cambios en `backend/bin/server.dart`
- Instancia `EmailService` y lo pasa a `AuthHandler`

---

## Cambios en app Flutter

### Cambios en `app/lib/src/presentation/auth/auth_provider.dart`
- `AuthState` agrega campo `pendingEmail: String?`
- `register()`: ya no guarda tokens. Si exitoso, setea `state.pendingEmail = email`
- Nuevo método `verificarCodigo(String email, String codigo)` → `POST /auth/verificar` → guarda tokens
- Nuevo método `reenviarCodigo(String email)` → `POST /auth/reenviar-codigo`

### Nuevo archivo: `app/lib/src/presentation/auth/verification_screen.dart`
- Paleta `_C` idéntica a `auth_screen.dart` (cream editorial)
- 6 `TextField` de 1 dígito numérico, auto-avance al siguiente
- Al completar los 6 dígitos llama automáticamente a `verificarCodigo()`
- Muestra: `"Código enviado a {email}"` + `"Válido por 15 minutos"`
- Timer countdown 60 seg → habilita botón "Reenviar código"
- Botón "Volver" → limpia `pendingEmail`, regresa al formulario
- Muestra errores del provider (código incorrecto, expirado, etc.)

### Cambios en `app/lib/src/presentation/auth/auth_screen.dart`
- Cuando `authState.pendingEmail != null`, renderiza `VerificationScreen` en lugar del formulario
- No requiere nueva ruta en go_router — es un estado dentro de `AuthScreen`

---

## Email HTML — estructura

```
┌─ Banda superior ─────────────────────────────┐
│  [Emblema SIGESPU]  SIGESPU               REF–2026-0516  │
├──────────────────────────────────────────────┤
│  № 001 · Activación de cuenta               │
│  Bienvenido,                                │
│  funcionario.          ← nombre del usuario │
│                                             │
│  Tu cuenta institucional en SIGESPU · Lota  │
│  ya está creada. Ingresa el código...       │
├─ Card blanca ────────────────────────────────┤
│  [🛡] Usa este código para activar tu cuenta │
│      Caduca en 15 minutos                   │
│                                             │
│  CÓDIGO DE VERIFICACIÓN                     │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐            │
│  │X │ │X │ │X │ │X │ │X │ │X │  ← 6 dígitos│
│  └──┘ └──┘ └──┘ └──┘ └──┘ └──┘            │
│  🕐 Vence el {fecha} a las {hora}           │
├─ Aviso seguridad ────────────────────────────┤
│  [🔒] ¿No solicitaste este acceso? Ignora...│
├─ Footer institucional ───────────────────────┤
│  Ilustre Municipalidad de Lota              │
│  Dirección de Seguridad Pública             │
│  LAT –37.0883°  LON –73.1567°              │
└──────────────────────────────────────────────┘
```

---

## Rate limiting

El endpoint `/auth/verificar` y `/auth/reenviar-codigo` quedan bajo el rate limit existente de `/auth/*`: 20 req/min por IP. El límite de intentos en Redis (5 max) es una segunda capa independiente del rate limiter.

---

## Lo que NO cambia

- Tabla `usuarios` — sin migraciones SQL
- Flujo de login
- Flujo de solicitud de acceso operativo
- Refresh token rotation
- Usuarios seed/director

---

## Archivos a crear/modificar

| Acción | Archivo |
|---|---|
| CREAR | `backend/lib/src/services/email_service.dart` |
| MODIFICAR | `backend/lib/src/auth/auth_handler.dart` |
| MODIFICAR | `backend/bin/server.dart` |
| MODIFICAR | `backend/pubspec.yaml` |
| MODIFICAR | `.env` y `.env.example` |
| CREAR | `app/lib/src/presentation/auth/verification_screen.dart` |
| MODIFICAR | `app/lib/src/presentation/auth/auth_provider.dart` |
| MODIFICAR | `app/lib/src/presentation/auth/auth_screen.dart` |
