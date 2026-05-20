import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import '../database/db_pool.dart';
import 'package:postgres/postgres.dart';

final _log = Logger('Jwt');

/// Secret default solo para desarrollo. En producción se DEBE setear la env
/// var `JWT_SECRET`; si no lo está, el constructor fallará (ver _resolveSecret).
const _defaultDevSecret = 'dev_only_jwt_secret_DO_NOT_USE_IN_PROD';

class JwtService {
  final DatabaseService _dbService;
  final String _secret;
  final int _expMinutes = int.parse(Platform.environment['JWT_EXPIRATION_MINUTES'] ?? '15');
  final int _refreshExpDays = int.parse(Platform.environment['JWT_REFRESH_EXPIRATION_DAYS'] ?? '7');
  final _uuid = const Uuid();

  JwtService._(this._dbService, this._secret);

  /// Construye el servicio validando que en producción el secret venga por env.
  /// Llamar desde server.dart al arrancar — si fallamos aquí en prod, el
  /// proceso muere y nunca acepta requests con un secret débil.
  factory JwtService(DatabaseService db) {
    final secret = _resolveSecret();
    return JwtService._(db, secret);
  }

  static String _resolveSecret() {
    final envSecret = Platform.environment['JWT_SECRET'];
    final env = Platform.environment['APP_ENV']?.toLowerCase() ?? 'development';
    final isProd = env == 'production' || env == 'prod';

    if (envSecret != null && envSecret.isNotEmpty) {
      if (envSecret.length < 32 && isProd) {
        throw StateError(
            'JWT_SECRET debe tener al menos 32 caracteres en producción '
            '(actualmente: ${envSecret.length}). Genera uno con `openssl rand -hex 32`.');
      }
      return envSecret;
    }

    if (isProd) {
      throw StateError(
          'JWT_SECRET no está seteado y APP_ENV=production. Negándose a arrancar '
          'con un secret default — eso permitiría a cualquiera forjar tokens. '
          'Setea JWT_SECRET con un valor aleatorio de 32+ caracteres.');
    }
    _log.warning(
        'Usando JWT_SECRET de desarrollo. NO ES SEGURO EN PRODUCCIÓN — '
        'setea la env var JWT_SECRET antes de desplegar.');
    return _defaultDevSecret;
  }

  String generateAccessToken(String userId, String nivelAcceso) {
    final jwt = JWT({
      'user_id': userId,
      'nivel_acceso': nivelAcceso,
    });
    return jwt.sign(SecretKey(_secret), expiresIn: Duration(minutes: _expMinutes));
  }

  Future<Map<String, dynamic>> createRefreshToken(String userId, {String? familia}) async {
    final token = _uuid.v4();
    final bytes = utf8.encode(token);
    final digest = sha256.convert(bytes);
    final tokenHash = digest.toString();
    
    final family = familia ?? _uuid.v4();
    final expiraEn = DateTime.now().add(Duration(days: _refreshExpDays));

    await _dbService.db.execute(
      Sql.named('INSERT INTO refresh_tokens (usuario_id, token_hash, familia, expira_en) VALUES (@userId, @hash, @familia, @expiraEn)'),
      parameters: {
        'userId': userId,
        'hash': tokenHash,
        'familia': family,
        'expiraEn': expiraEn,
      },
    );

    return {
      'token': token,
      'familia': family,
    };
  }

  JWT? verifyAccessToken(String token) {
    try {
      return JWT.verify(token, SecretKey(_secret));
    } catch (e) {
      return null;
    }
  }

  Future<void> blacklistToken(String token) async {
    final jwt = verifyAccessToken(token);
    if (jwt == null) return;

    final exp = DateTime.fromMillisecondsSinceEpoch((jwt.payload['exp'] as int) * 1000);
    final ttl = exp.difference(DateTime.now()).inSeconds;

    if (ttl > 0) {
      // Hash el token antes de usarlo como key para no almacenar el JWT plano
      // en Redis (defensa en profundidad si alguien lee el dump).
      final key = 'blacklist:${_hashToken(token)}';
      await _dbService.redis.send_object(['SETEX', key, ttl, '1']);
    }
  }

  Future<bool> isBlacklisted(String token) async {
    final key = 'blacklist:${_hashToken(token)}';
    final reply = await _dbService.redis.send_object(['GET', key]);
    return reply != null;
  }

  static String _hashToken(String token) =>
      sha256.convert(utf8.encode(token)).toString();
}
