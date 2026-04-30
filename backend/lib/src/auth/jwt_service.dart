import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';
import '../database/db_pool.dart';
import 'package:postgres/postgres.dart';

class JwtService {
  final DatabaseService _dbService;
  final String _secret = Platform.environment['JWT_SECRET'] ?? 'tu_secreto_super_seguro_cambiar_en_prod';
  final int _expMinutes = int.parse(Platform.environment['JWT_EXPIRATION_MINUTES'] ?? '15');
  final int _refreshExpDays = int.parse(Platform.environment['JWT_REFRESH_EXPIRATION_DAYS'] ?? '7');
  final _uuid = const Uuid();

  JwtService(this._dbService);

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
      await _dbService.redis.send_object(['SETEX', 'blacklist:\$token', ttl, '1']);
    }
  }

  Future<bool> isBlacklisted(String token) async {
    final reply = await _dbService.redis.send_object(['GET', 'blacklist:\$token']);
    return reply != null;
  }
}
