import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import '../database/db_pool.dart';

final _log = Logger('rateLimit');

/// Rate limit con ventana fija de [windowSecs] segundos por IP+path+prefix.
///
/// Implementación atómica: `INCR` siempre incrementa y devuelve el contador
/// actual; cuando el valor retornado es 1 sabemos que es la primera request
/// de la ventana → seteamos `EXPIRE`. No usamos MULTI/EXEC (que en el cliente
/// Dart tienen comportamiento frágil sin pipelining real) — `INCR` solo ya
/// es atómico a nivel de Redis.
///
/// **Determinación de IP**: por defecto usa `x-forwarded-for` / `x-real-ip`
/// solo si el flag [trustForwardedHeaders] es true (Nginx delante). Si no,
/// usa la IP de la conexión directa. Esto evita spoofing trivial cuando se
/// expone el backend sin proxy reverso.
Middleware rateLimitMiddleware(
  DatabaseService dbService, {
  int limit = 100,
  int windowSecs = 60,
  String prefix = 'general',
  bool trustForwardedHeaders = true,
}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final ip = _clientIp(request, trustForwardedHeaders);
      final path = request.url.path;
      final key = 'ratelimit:$prefix:$ip:$path';

      try {
        // INCR es atómico y crea la key con valor 1 si no existía.
        final incrResult = await dbService.redis.send_object(['INCR', key]);
        final count = incrResult is int
            ? incrResult
            : int.tryParse(incrResult.toString()) ?? 0;

        // En la primera request de la ventana, fijar TTL.
        if (count == 1) {
          await dbService.redis.send_object(['EXPIRE', key, windowSecs]);
        }

        if (count > limit) {
          // Headers estándar para que el cliente sepa cuándo reintentar.
          final ttlRaw = await dbService.redis.send_object(['TTL', key]);
          final ttl = (ttlRaw is int && ttlRaw > 0) ? ttlRaw : windowSecs;
          return Response(
            429,
            body: jsonEncode({
              'error': 'Demasiadas solicitudes. Intenta nuevamente en $ttl segundos.',
            }),
            headers: {
              'content-type': 'application/json; charset=utf-8',
              'retry-after': '$ttl',
              'x-ratelimit-limit': '$limit',
              'x-ratelimit-remaining': '0',
            },
          );
        }

        return innerHandler(request);
      } catch (e, st) {
        // Si Redis falla, NO bloqueamos requests — degradamos a "pass-through"
        // y dejamos rastro en logs. Mejor disponibilidad que correctitud aquí.
        _log.warning('rate-limit pass-through (Redis falló) para $key', e, st);
        return innerHandler(request);
      }
    };
  };
}

/// Extrae la IP del cliente respetando [trustForwardedHeaders].
String _clientIp(Request request, bool trustHeaders) {
  if (trustHeaders) {
    final forwarded = request.headers['x-forwarded-for'];
    if (forwarded != null && forwarded.isNotEmpty) {
      // X-Forwarded-For puede tener una lista "cliente, proxy1, proxy2"
      return forwarded.split(',').first.trim();
    }
    final real = request.headers['x-real-ip'];
    if (real != null && real.isNotEmpty) return real;
  }
  // Fallback: shelf expone la IP del peer en el contexto bajo 'shelf.io.connection_info'.
  final info = request.context['shelf.io.connection_info'];
  if (info != null) {
    try {
      // ignore: avoid_dynamic_calls
      return (info as dynamic).remoteAddress.address as String;
    } catch (_) {}
  }
  return 'unknown_ip';
}
