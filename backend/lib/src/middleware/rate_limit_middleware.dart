import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../database/db_pool.dart';

Middleware rateLimitMiddleware(DatabaseService dbService, {int limit = 100, int windowSecs = 60, String prefix = 'general'}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final ip = request.headers['x-real-ip'] ?? request.headers['x-forwarded-for'] ?? 'unknown_ip';
      final path = request.url.path;
      final key = 'ratelimit:$prefix:$ip:$path';
      
      final currentOpt = await dbService.redis.send_object(['GET', key]);
      int current = currentOpt != null ? int.parse(currentOpt.toString()) : 0;
      
      if (current >= limit) {
        return Response(429, body: jsonEncode({'error': 'Too many requests. Please try again later.'}), headers: {'Content-Type': 'application/json'});
      }
      
      dbService.redis.send_object(['MULTI']);
      dbService.redis.send_object(['INCR', key]);
      if (current == 0) {
        dbService.redis.send_object(['EXPIRE', key, windowSecs]);
      }
      await dbService.redis.send_object(['EXEC']);
      
      return innerHandler(request);
    };
  };
}
