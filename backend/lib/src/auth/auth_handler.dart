import 'dart:convert';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import '../database/db_pool.dart';
import '../services/email_service.dart';
import 'jwt_service.dart';
import '../middleware/auth_middleware.dart';

class AuthHandler {
  final DatabaseService _dbService;
  final JwtService _jwtService;
  final EmailService _emailService;

  static const allowedDomains = ['lota.cl', 'munilota.cl'];
  static const _codeTtlSeconds = 900; // 15 min

  AuthHandler(this._dbService, this._jwtService, this._emailService);

  Router get router {
    final router = Router();

    // Public routes
    router.post('/register', _register);
    router.post('/verificar', _verificar);
    router.post('/reenviar-codigo', _reenviarCodigo);
    router.post('/login', _login);
    router.post('/refresh', _refresh);
    router.post('/logout', _logout);

    // Protected routes (requires valid JWT)
    final protectedRouter = Router();
    protectedRouter.post('/solicitar-acceso', _solicitarAcceso);
    
    // Director only routes
    final directorRouter = Router();
    directorRouter.get('/solicitudes', _listarSolicitudes);
    directorRouter.put('/solicitudes/<id>', _resolverSolicitud);

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
    final body = await req.readAsString();
    final data = jsonDecode(body);
    final emailRaw = data['email'] as String?;
    final nombre = data['nombre'] as String?;
    final password = data['password'] as String?;

    if (emailRaw == null || nombre == null || password == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Faltan campos requeridos'}));
    }

    final email = emailRaw.trim().toLowerCase();

    final domainParts = email.split('@');
    if (domainParts.length != 2 || !allowedDomains.contains(domainParts.last)) {
      return Response.forbidden(jsonEncode({'error': 'Solo funcionarios municipales de Lota pueden registrarse'}));
    }

    final hash = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));

    try {
      await _dbService.db.execute(
        Sql.named('INSERT INTO usuarios (email, nombre, password_hash, nivel_acceso, activo) VALUES (@email, @nombre, @hash, @nivel, false)'),
        parameters: {
          'email': email,
          'nombre': nombre,
          'hash': hash,
          'nivel': 'visitante',
        }
      );

      await _generarYEnviarCodigo(email, nombre);

      return Response.ok(
        jsonEncode({'message': 'Código de verificación enviado al correo'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      if (e.toString().contains('usuarios_email_key')) {
        return Response(409, body: jsonEncode({'error': 'El email ya está registrado'}));
      }
      print('[auth] Error en /register: $e');
      return Response.internalServerError(body: jsonEncode({'error': 'Error de servidor'}));
    }
  }

  Future<Response> _verificar(Request req) async {
    final body = await req.readAsString();
    final data = jsonDecode(body);
    final emailRaw = data['email'] as String?;
    final codigo = data['codigo'] as String?;

    if (emailRaw == null || codigo == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Faltan campos requeridos'}));
    }

    final email = emailRaw.trim().toLowerCase();
    final key = 'verification:$email';
    final stored = await _dbService.redis.send_object(['GET', key]);

    if (stored == null || stored is! String || stored != codigo) {
      return Response.unauthorized(jsonEncode({'error': 'Código incorrecto o expirado'}));
    }

    final result = await _dbService.db.execute(
      Sql.named('''
        UPDATE usuarios
        SET activo = true, updated_at = NOW()
        WHERE email = @email
        RETURNING id, nombre, nivel_acceso, solicitud_operativo
      '''),
      parameters: {'email': email},
    );

    if (result.isEmpty) {
      return Response.notFound(jsonEncode({'error': 'Usuario no encontrado'}));
    }

    await _dbService.redis.send_object(['DEL', key]);

    final row = result.first;
    final userId = row[0] as String;
    final nombre = row[1] as String;
    final nivelAcceso = row[2] as String;
    final solicitudOperativo = row[3] as String?;

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

  Future<Response> _reenviarCodigo(Request req) async {
    final body = await req.readAsString();
    final data = jsonDecode(body);
    final emailRaw = data['email'] as String?;

    if (emailRaw == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Falta email'}));
    }

    final email = emailRaw.trim().toLowerCase();

    final result = await _dbService.db.execute(
      Sql.named('SELECT nombre, activo FROM usuarios WHERE email = @email'),
      parameters: {'email': email},
    );

    if (result.isEmpty) {
      return Response.notFound(jsonEncode({'error': 'Usuario no encontrado'}));
    }

    final nombre = result.first[0] as String;
    final activo = result.first[1] as bool;

    if (activo) {
      return Response(409, body: jsonEncode({'error': 'La cuenta ya está verificada'}));
    }

    await _generarYEnviarCodigo(email, nombre);

    return Response.ok(jsonEncode({'message': 'Código reenviado'}));
  }

  Future<void> _generarYEnviarCodigo(String email, String nombre) async {
    final rng = Random.secure();
    final codigo = (rng.nextInt(900000) + 100000).toString(); // 6 dígitos
    await _dbService.redis.send_object([
      'SET', 'verification:$email', codigo, 'EX', '$_codeTtlSeconds',
    ]);
    await _emailService.sendVerificationCode(email, nombre, codigo);
  }

  Future<Response> _login(Request req) async {
    final body = await req.readAsString();
    final data = jsonDecode(body);
    final emailRaw = data['email'] as String?;
    final password = data['password'] as String?;

    if (emailRaw == null || password == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Faltan campos requeridos'}));
    }

    final email = emailRaw.trim().toLowerCase();

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
    final body = await req.readAsString();
    final data = jsonDecode(body);
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
    if (body.isNotEmpty) {
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

  Future<Response> _solicitarAcceso(Request req) async {
    final userId = req.context['user_id'] as String;
    final body = await req.readAsString();
    final data = jsonDecode(body);
    
    final cargo = data['cargo'] as String?;
    final direccion = data['direccion_municipal'] as String?;

    if (cargo == null || direccion == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Faltan campos requeridos'}));
    }

    final checkResult = await _dbService.db.execute(
      Sql.named('SELECT solicitud_operativo FROM usuarios WHERE id = @id'),
      parameters: {'id': userId}
    );

    if (checkResult.isEmpty) {
      return Response.notFound(jsonEncode({'error': 'Usuario no encontrado'}));
    }

    if (checkResult.first[0] != null) {
      return Response(409, body: jsonEncode({'error': 'Ya existe una solicitud previa registrada'}));
    }

    await _dbService.db.execute(
      Sql.named('''
        UPDATE usuarios 
        SET solicitud_operativo = 'pendiente', 
            solicitud_fecha = NOW(), 
            solicitud_cargo = @cargo, 
            solicitud_direccion_municipal = @direccion 
        WHERE id = @id
      '''),
      parameters: {
        'id': userId,
        'cargo': cargo,
        'direccion': direccion,
      }
    );

    return Response.ok(jsonEncode({'message': 'Solicitud enviada correctamente'}));
  }

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

  Future<Response> _resolverSolicitud(Request req, String id) async {
    final directorId = req.context['user_id'] as String;
    final body = await req.readAsString();
    final data = jsonDecode(body);
    
    final accion = data['accion'] as String?;

    if (accion != 'aprobar' && accion != 'rechazar') {
      return Response.badRequest(body: jsonEncode({'error': 'Acción inválida. Use "aprobar" o "rechazar"'}));
    }

    final estado = accion == 'aprobar' ? 'aprobada' : 'rechazada';

    final result = await _dbService.db.execute(
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
      }
    );

    if (result.isEmpty) {
      return Response.notFound(jsonEncode({'error': 'Solicitud no encontrada o ya procesada'}));
    }

    return Response.ok(jsonEncode({'message': 'Solicitud \$estado correctamente'}));
  }
}
