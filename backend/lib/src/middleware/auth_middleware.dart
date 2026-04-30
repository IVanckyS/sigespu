import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../auth/jwt_service.dart';

Middleware authMiddleware(JwtService jwtService) {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(jsonEncode({'error': 'Missing or invalid Authorization header'}));
      }
      
      final token = authHeader.substring(7);
      
      if (await jwtService.isBlacklisted(token)) {
        return Response.unauthorized(jsonEncode({'error': 'Token has been revoked'}));
      }
      
      final jwt = jwtService.verifyAccessToken(token);
      if (jwt == null) {
        return Response.unauthorized(jsonEncode({'error': 'Invalid or expired token'}));
      }
      
      final updatedRequest = request.change(context: {
        'user_id': jwt.payload['user_id'],
        'nivel_acceso': jwt.payload['nivel_acceso'],
      });
      
      return innerHandler(updatedRequest);
    };
  };
}

Middleware requireRole(List<String> roles) {
  return (Handler innerHandler) {
    return (Request request) async {
      final nivelAcceso = request.context['nivel_acceso'] as String?;
      if (nivelAcceso == null || !roles.contains(nivelAcceso)) {
        return Response.forbidden(jsonEncode({'error': 'No tienes permisos suficientes'}));
      }
      return innerHandler(request);
    };
  };
}
