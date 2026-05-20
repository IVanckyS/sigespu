import 'dart:async' show unawaited;
import 'dart:convert';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import '../database/db_pool.dart';
import '../http/responses.dart';
import '../http/validators.dart';
import 'jwt_service.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/rate_limit_middleware.dart';
import '../services/email_service.dart';

class AuthHandler {
  final DatabaseService _dbService;
  final JwtService _jwtService;
  final EmailService _emailService;

  static const allowedDomains = ['lota.cl', 'munilota.cl'];

  AuthHandler(this._dbService, this._jwtService, this._emailService);

  /// Rate limit estricto para endpoints sensibles a abuso (brute-force,
  /// enumeración, spam de email). Cada uno usa su propio `prefix` en Redis
  /// para no compartir contador entre operaciones distintas — un atacante
  /// que abuse de `/login` no agota la cuota legítima de `/verificar` del
  /// mismo usuario.
  Handler _strict(int limit, String prefix, Handler inner) {
    return Pipeline()
        .addMiddleware(rateLimitMiddleware(
          _dbService,
          limit: limit,
          windowSecs: 60,
          prefix: 'auth_$prefix',
        ))
        .addHandler(inner);
  }

  Router get router {
    final router = Router();

    // Endpoints sensibles → rate limit por endpoint (más estricto que el global).
    // 5 intentos/min para credenciales (brute-force) y 3/min para los que
    // disparan emails (spam de bandeja).
    router.post('/register',         _strict(3, 'register', _register));
    router.post('/login',            _strict(5, 'login', _login));
    router.post('/verificar',        _strict(10, 'verificar', _verificar));
    router.post('/reenviar-codigo',  _strict(3, 'reenviar', _reenviarCodigo));
    router.post('/solicitar-reset',  _strict(3, 'reset_req', _solicitarReset));
    router.post('/reset-password',   _strict(5, 'reset_pw', _resetPassword));

    // Endpoints sin abuso real — sin limit extra (heredan el global de /auth)
    router.post('/refresh', _refresh);
    router.post('/logout', _logout);

    // Protected routes (requires valid JWT)
    final protectedRouter = Router();
    protectedRouter.post('/solicitar-acceso', _solicitarAcceso);
    
    // Director only routes
    final directorRouter = Router();
    directorRouter.get('/solicitudes', _listarSolicitudes);
    directorRouter.put('/solicitudes/<id>', _resolverSolicitud);
    directorRouter.get('/usuarios', _listarUsuarios);

    // Mount protected routers
    router.mount('/', Pipeline()
      .addMiddleware(authMiddleware(_jwtService))
      .addHandler(protectedRouter.call));
      
    router.mount('/', Pipeline()
      .addMiddleware(authMiddleware(_jwtService))
      .addMiddleware(requireRole(['director']))
      .addHandler(directorRouter.call));

    return router;
  }

  Future<Response> _register(Request req) async {
    final data = await readJsonObject(req);
    final emailRaw = requireString(data, 'email', maxLen: 254);
    final nombre = requireString(data, 'nombre', maxLen: 150);
    final password = requireString(data, 'password', maxLen: 128);

    final passwordError = _validatePasswordStrength(password);
    if (passwordError != null) {
      return Response.badRequest(body: jsonEncode({'error': passwordError}));
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

  Future<Response> _login(Request req) async {
    final data = await readJsonObject(req);
    final email = requireString(data, 'email', maxLen: 254).toLowerCase();
    final password = requireString(data, 'password', maxLen: 128);

    final result = await _dbService.db.execute(
      Sql.named('SELECT id, password_hash, nivel_acceso, activo, nombre, solicitud_operativo FROM usuarios WHERE email = @email'),
      parameters: {'email': email}
    );

    if (result.isEmpty) {
      return Response.unauthorized(jsonEncode({'error': 'Credenciales inválidas'}));
    }

    final row = result.first;
    final userId = row[0] as String;
    final hash = row[1] as String;
    final nivelAcceso = row[2] as String;
    final activo = row[3] as bool;
    final nombre = row[4] as String;
    final solicitudOperativo = row[5] as String?;

    if (!activo) {
      return Response.forbidden(jsonEncode({'error': 'Usuario inactivo'}));
    }

    if (!BCrypt.checkpw(password, hash)) {
      return Response.unauthorized(jsonEncode({'error': 'Credenciales inválidas'}));
    }

    final accessToken = _jwtService.generateAccessToken(userId, nivelAcceso);
    final refreshData = await _jwtService.createRefreshToken(userId);

    return Response.ok(jsonEncode({
      'access_token': accessToken,
      'refresh_token': refreshData['token'],
      'user': {
        'id': userId,
        'email': email,
        'nombre': nombre,
        'nivel_acceso': nivelAcceso,
        'solicitud_operativo': solicitudOperativo,
      }
    }), headers: {'Content-Type': 'application/json'});
  }

  Future<Response> _refresh(Request req) async {
    final data = await readJsonObject(req);
    final token = data['refresh_token'] as String?;

    if (token == null) return Response.badRequest(body: jsonEncode({'error': 'Se requiere refresh_token'}));

    final bytes = utf8.encode(token);
    final digest = sha256.convert(bytes);
    final tokenHash = digest.toString();

    final result = await _dbService.db.execute(
      Sql.named('SELECT id, usuario_id, familia, expira_en, revocado FROM refresh_tokens WHERE token_hash = @hash'),
      parameters: {'hash': tokenHash}
    );

    if (result.isEmpty) {
      return Response.unauthorized(jsonEncode({'error': 'Refresh token inválido'}));
    }

    final row = result.first;
    final tokenId = row[0] as String;
    final userId = row[1] as String;
    final familia = row[2] as String;
    final expiraEn = row[3] as DateTime;
    final revocado = row[4] as bool;

    if (revocado) {
      await _dbService.db.execute(
        Sql.named('UPDATE refresh_tokens SET revocado = true WHERE familia = @familia'),
        parameters: {'familia': familia}
      );
      return Response.unauthorized(jsonEncode({'error': 'Token reusado. Sesión terminada.'}));
    }

    if (expiraEn.isBefore(DateTime.now())) {
      return Response.unauthorized(jsonEncode({'error': 'Refresh token expirado'}));
    }

    await _dbService.db.execute(
      Sql.named('UPDATE refresh_tokens SET revocado = true WHERE id = @id'),
      parameters: {'id': tokenId}
    );

    final userResult = await _dbService.db.execute(
      Sql.named('SELECT nivel_acceso, activo FROM usuarios WHERE id = @id'),
      parameters: {'id': userId}
    );

    if (userResult.isEmpty || !(userResult.first[1] as bool)) {
      return Response.forbidden(jsonEncode({'error': 'Usuario inactivo o no existe'}));
    }

    final nivelAcceso = userResult.first[0] as String;

    final accessToken = _jwtService.generateAccessToken(userId, nivelAcceso);
    final refreshData = await _jwtService.createRefreshToken(userId, familia: familia);

    return Response.ok(jsonEncode({
      'access_token': accessToken,
      'refresh_token': refreshData['token'],
    }), headers: {'Content-Type': 'application/json'});
  }

  Future<Response> _logout(Request req) async {
    final authHeader = req.headers['authorization'];
    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      final token = authHeader.substring(7);
      await _jwtService.blacklistToken(token);
    }

    final body = await req.readAsString();
    if (body.isNotEmpty && body.length <= 64 * 1024) {
      try {
        final data = jsonDecode(body);
        final refreshToken = data['refresh_token'] as String?;
        if (refreshToken != null) {
          final bytes = utf8.encode(refreshToken);
          final digest = sha256.convert(bytes);
          final tokenHash = digest.toString();
          
          await _dbService.db.execute(
            Sql.named('UPDATE refresh_tokens SET revocado = true WHERE token_hash = @hash'),
            parameters: {'hash': tokenHash}
          );
        }
      } catch (_) {}
    }
    
    return Response.ok(jsonEncode({'message': 'Logged out'}));
  }

  Future<Response> _solicitarAcceso(Request req) => guard('solicitarAcceso', () async {
    final userId = req.context['user_id'] as String;
    final body = await readJsonObject(req);
    final cargo = requireString(body, 'cargo', maxLen: 200);
    final direccion = requireString(body, 'direccion_municipal', maxLen: 300);

    // Transacción: READ-CHECK-WRITE atómico para evitar que dos solicitudes
    // concurrentes del mismo usuario pasen el check y creen registros duplicados.
    return await _dbService.db.runTx<Response>((tx) async {
      final checkResult = await tx.execute(
        Sql.named('SELECT solicitud_operativo FROM usuarios WHERE id = @id FOR UPDATE'),
        parameters: {'id': userId},
      );

      if (checkResult.isEmpty) {
        return notFound('Usuario no encontrado');
      }
      if (checkResult.first[0] != null) {
        return conflict('Ya existe una solicitud previa registrada');
      }

      await tx.execute(
        Sql.named('''
          UPDATE usuarios
          SET solicitud_operativo = 'pendiente',
              solicitud_fecha = NOW(),
              solicitud_cargo = @cargo,
              solicitud_direccion_municipal = @direccion
          WHERE id = @id
        '''),
        parameters: {'id': userId, 'cargo': cargo, 'direccion': direccion},
      );

      return ok({'message': 'Solicitud enviada correctamente'});
    });
  });

  Future<Response> _listarSolicitudes(Request req) async {
    final result = await _dbService.db.execute('''
      SELECT id, email, nombre, solicitud_fecha, solicitud_cargo, solicitud_direccion_municipal, solicitud_operativo 
      FROM usuarios 
      WHERE solicitud_operativo IS NOT NULL 
      ORDER BY solicitud_fecha DESC
    ''');

    final solicitudes = result.map((row) => {
      'id': row[0],
      'email': row[1],
      'nombre': row[2],
      'fecha': (row[3] as DateTime).toIso8601String(),
      'cargo': row[4],
      'direccion': row[5],
      'estado': row[6],
    }).toList();

    return Response.ok(jsonEncode(solicitudes), headers: {'Content-Type': 'application/json'});
  }

  Future<Response> _listarUsuarios(Request req) async {
    final result = await _dbService.db.execute('''
      SELECT id, email, nombre, nivel_acceso, activo,
             solicitud_cargo, solicitud_direccion_municipal, updated_at
      FROM usuarios
      ORDER BY
        CASE nivel_acceso
          WHEN 'director' THEN 0
          WHEN 'operativo' THEN 1
          WHEN 'visitante' THEN 2
          ELSE 3
        END,
        nombre ASC
    ''');

    final usuarios = result.map((row) => {
      'id': row[0],
      'email': row[1],
      'nombre': row[2],
      'nivel_acceso': row[3],
      'activo': row[4],
      'cargo': row[5],
      'unidad': row[6] ?? 'Municipal',
      'rut': null,
      'ultima_sesion':
          row[7] == null ? null : (row[7] as DateTime).toIso8601String(),
    }).toList();

    return Response.ok(jsonEncode(usuarios),
        headers: {'Content-Type': 'application/json'});
  }

  /// Retorna un mensaje de error si la contraseña no cumple los requisitos,
  /// o null si es válida. Requisitos mínimos NIST-aligned:
  /// 8+ chars, al menos una mayúscula, una minúscula y un dígito.
  static String? _validatePasswordStrength(String password) {
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'La contraseña debe contener al menos una letra minúscula';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }
    return null;
  }

  static String _generateCode() {
    final rng = Random.secure();
    return List.generate(6, (_) => rng.nextInt(10)).join();
  }

  static String _hashCode(String code) {
    final bytes = utf8.encode(code);
    return sha256.convert(bytes).toString();
  }

  Future<Response> _verificar(Request req) => guard('verificar', () async {
    final body = await readJsonObject(req);
    final email = requireString(body, 'email', maxLen: 254).toLowerCase();
    final codigo = requireString(body, 'codigo', maxLen: 12);
    if (codigo.length != 6 || !RegExp(r'^\d{6}$').hasMatch(codigo)) {
      return badRequest('El código debe ser de 6 dígitos');
    }

    final pendingKey = 'verif:$email';

    final raw = await _dbService.redis.send_object(['GET', pendingKey]);
    if (raw == null) {
      return notFound('El código expiró. Regístrate de nuevo.');
    }

    final pending = jsonDecode(raw as String) as Map<String, dynamic>;

    if (_hashCode(codigo) != pending['codigo_hash']) {
      final intentos = (pending['intentos'] as int) + 1;
      if (intentos >= 5) {
        await _dbService.redis.send_object(['DEL', pendingKey]);
        return tooManyRequests('Demasiados intentos. Regístrate de nuevo.');
      }
      final ttlRaw = await _dbService.redis.send_object(['TTL', pendingKey]);
      final ttl = (ttlRaw as int) > 0 ? ttlRaw : 900;
      pending['intentos'] = intentos;
      await _dbService.redis.send_object(
          ['SET', pendingKey, jsonEncode(pending), 'EX', ttl]);
      return unauthorized(
          'Código incorrecto. Intentos restantes: ${5 - intentos}');
    }

    // Código correcto — crea usuario + emite tokens en una transacción.
    // Si el INSERT viola la unique constraint del email, devolvemos 409 sin
    // exponer el detalle del driver (usuarios_email_key).
    final nombre = pending['nombre'] as String;
    final passwordHash = pending['password_hash'] as String;

    try {
      final result = await _dbService.db.runTx<List<List<Object?>>>((tx) async {
        return await tx.execute(
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
      });

      await _dbService.redis.send_object(['DEL', pendingKey]);

      final row = result.first;
      final userId = row[0] as String;
      final nivelAcceso = row[1] as String;
      final solicitudOperativo = row[2] as String?;

      final accessToken = _jwtService.generateAccessToken(userId, nivelAcceso);
      final refreshData = await _jwtService.createRefreshToken(userId);

      return ok({
        'access_token': accessToken,
        'refresh_token': refreshData['token'],
        'user': {
          'id': userId,
          'email': email,
          'nombre': nombre,
          'nivel_acceso': nivelAcceso,
          'solicitud_operativo': solicitudOperativo,
        },
      });
    } on ServerException catch (e) {
      // Unique violation en usuarios.email — la cuenta se creó por otra vía
      // (ej. otro flow de verificación) mientras este código estaba pendiente.
      if (e.code == '23505') {
        await _dbService.redis.send_object(['DEL', pendingKey]);
        return conflict('El email ya está registrado');
      }
      rethrow; // El guard() lo traduce a 500 sanitizado.
    }
  });

  Future<Response> _reenviarCodigo(Request req) async {
    final body = await readJsonObject(req);
    final email = requireString(body, 'email', maxLen: 254).toLowerCase();
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

  // ── Recuperación de contraseña ──────────────────────────────────────────────

  /// Anti-enumeración: SIEMPRE responde 200 con mensaje genérico, exista o no
  /// el usuario. Solo dispara el email cuando la cuenta existe y está activa.
  Future<Response> _solicitarReset(Request req) => guard('solicitarReset', () async {
    const genericMsg =
        'Si la cuenta existe, recibirás un código por correo en unos minutos.';

    final body = await readJsonObject(req);
    final emailRaw = optionalString(body, 'email', maxLen: 254);
    if (emailRaw == null) {
      return badRequest('Falta el email');
    }
    final email = emailRaw.toLowerCase();

    // Validación de dominio en silencio (no revela si está permitido o no).
    final domainParts = email.split('@');
    if (domainParts.length != 2 || !allowedDomains.contains(domainParts.last)) {
      return ok({'message': genericMsg});
    }

    final result = await _dbService.db.execute(
      Sql.named('SELECT id, nombre, activo FROM usuarios WHERE email = @email'),
      parameters: {'email': email},
    );

    if (result.isEmpty || !(result.first[2] as bool)) {
      return ok({'message': genericMsg});
    }

    final nombre = result.first[1] as String;
    final resetKey = 'reset:$email';

    // Cooldown 60s entre solicitudes para evitar spam de correo.
    final existingRaw = await _dbService.redis.send_object(['GET', resetKey]);
    if (existingRaw != null) {
      try {
        final existing =
            jsonDecode(existingRaw as String) as Map<String, dynamic>;
        final reenvioAt = existing['reenvio_at'] as String?;
        if (reenvioAt != null) {
          final last = DateTime.parse(reenvioAt);
          if (DateTime.now().difference(last).inSeconds < 60) {
            return ok({'message': genericMsg});
          }
        }
      } catch (_) {}
    }

    final codigo = _generateCode();
    final payload = jsonEncode({
      'codigo_hash': _hashCode(codigo),
      'intentos': 0,
      'reenvio_at': DateTime.now().toIso8601String(),
    });

    await _dbService.redis.send_object(['SET', resetKey, payload, 'EX', 900]);
    unawaited(_emailService.sendPasswordResetCode(email, nombre, codigo));

    return ok({'message': genericMsg});
  });

  Future<Response> _resetPassword(Request req) => guard('resetPassword', () async {
    final body = await readJsonObject(req);
    final email = requireString(body, 'email', maxLen: 254).toLowerCase();
    final codigo = requireString(body, 'codigo', maxLen: 12);
    final newPassword = requireString(body, 'password', maxLen: 128);

    final pwError = _validatePasswordStrength(newPassword);
    if (pwError != null) return badRequest(pwError);
    if (codigo.length != 6 || !RegExp(r'^\d{6}$').hasMatch(codigo)) {
      return badRequest('El código debe ser de 6 dígitos');
    }

    final resetKey = 'reset:$email';

    final raw = await _dbService.redis.send_object(['GET', resetKey]);
    if (raw == null) {
      return notFound('El código expiró o es inválido. Solicita uno nuevo.');
    }

    final pending = jsonDecode(raw as String) as Map<String, dynamic>;

    if (_hashCode(codigo) != pending['codigo_hash']) {
      final intentos = (pending['intentos'] as int) + 1;
      if (intentos >= 5) {
        await _dbService.redis.send_object(['DEL', resetKey]);
        return tooManyRequests('Demasiados intentos. Solicita un código nuevo.');
      }
      final ttlRaw = await _dbService.redis.send_object(['TTL', resetKey]);
      final ttl = (ttlRaw as int) > 0 ? ttlRaw : 900;
      pending['intentos'] = intentos;
      await _dbService.redis.send_object(
          ['SET', resetKey, jsonEncode(pending), 'EX', ttl]);
      return unauthorized('Código incorrecto. Intentos restantes: ${5 - intentos}');
    }

    // Código correcto: UPDATE password + revoca refresh tokens en una sola
    // transacción. Si falla la segunda operación, la primera también se
    // revierte → no quedan tokens viejos válidos contra una password nueva.
    final newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(logRounds: 12));

    final response = await _dbService.db.runTx<Response>((tx) async {
      final result = await tx.execute(
        Sql.named(
            'UPDATE usuarios SET password_hash = @hash, updated_at = NOW() '
            'WHERE email = @email AND activo = true RETURNING id'),
        parameters: {'hash': newHash, 'email': email},
      );

      if (result.isEmpty) {
        return notFound('Usuario no encontrado');
      }

      final userId = result.first[0] as String;

      await tx.execute(
        Sql.named(
            'UPDATE refresh_tokens SET revocado = true WHERE usuario_id = @id'),
        parameters: {'id': userId},
      );

      return ok({
        'message': 'Contraseña actualizada. Inicia sesión con tu nueva clave.',
      });
    });

    // Solo limpiamos Redis si el cambio en BD fue exitoso (200).
    if (response.statusCode == 200) {
      await _dbService.redis.send_object(['DEL', resetKey]);
    }
    return response;
  });

  Future<Response> _resolverSolicitud(Request req, String id) async {
    final directorId = req.context['user_id'] as String;
    final body = await readJsonObject(req);
    final accion = requireEnum(body, 'accion', {'aprobar', 'rechazar'});
    final estado = accion == 'aprobar' ? 'aprobada' : 'rechazada';

    final ipAddr = _clientIp(req);
    final userAgent = req.headers['user-agent'] ?? '';

    return await _dbService.db.runTx<Response>((tx) async {
      final result = await tx.execute(
        Sql.named('''
          UPDATE usuarios
          SET solicitud_operativo = @estado,
              nivel_acceso = CASE WHEN @estado = 'aprobada' THEN 'operativo' ELSE nivel_acceso END,
              solicitud_revisada_por = @directorId,
              solicitud_revisada_at = NOW()
          WHERE id = @id AND solicitud_operativo = 'pendiente'
          RETURNING id
        '''),
        parameters: {
          'id': id,
          'estado': estado,
          'directorId': directorId,
        },
      );

      if (result.isEmpty) {
        return Response.notFound(
            jsonEncode({'error': 'Solicitud no encontrada o ya procesada'}));
      }

      await tx.execute(
        Sql.named('''
          INSERT INTO audit_log (usuario_id, accion, entidad, entidad_id,
                                 ip_address, user_agent, payload_despues)
          VALUES (@userId, @accion, 'usuarios', @entidadId,
                  @ip, @ua, @payload::jsonb)
        '''),
        parameters: {
          'userId': directorId,
          'accion': 'solicitud_$accion',
          'entidadId': id,
          'ip': ipAddr,
          'ua': userAgent,
          'payload': jsonEncode({'accion': accion, 'estado_resultante': estado}),
        },
      );

      return Response.ok(
          jsonEncode({'message': 'Solicitud $estado correctamente'}));
    });
  }

  /// Extrae IP del cliente respetando encabezado X-Forwarded-For de nginx.
  static String _clientIp(Request req) {
    final forwarded = req.headers['x-forwarded-for'];
    if (forwarded != null && forwarded.isNotEmpty) {
      return forwarded.split(',').first.trim();
    }
    final real = req.headers['x-real-ip'];
    if (real != null && real.isNotEmpty) return real;
    return 'unknown';
  }
}
