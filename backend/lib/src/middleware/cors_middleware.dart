import 'dart:io';
import 'package:shelf/shelf.dart';

/// Orígenes permitidos: localhost en dev, más el dominio de producción si se
/// configura mediante ALLOWED_ORIGIN (ej. https://sigespu.lota.cl).
Set<String> _buildAllowedOrigins() {
  final origins = <String>{
    'http://localhost',
    'http://localhost:8080',
    'http://127.0.0.1',
    'http://127.0.0.1:8080',
  };
  final envOrigin = Platform.environment['ALLOWED_ORIGIN'];
  if (envOrigin != null && envOrigin.isNotEmpty) {
    origins.add(envOrigin.trim());
  }
  return origins;
}

bool _isAllowedOrigin(String origin, Set<String> allowed) {
  if (origin.isEmpty) return false;
  final uri = Uri.tryParse(origin);
  if (uri == null) return false;
  return allowed.contains(origin);
}

Middleware corsMiddleware() {
  final allowedOrigins = _buildAllowedOrigins();

  return (Handler handler) {
    return (Request request) async {
      final origin = request.headers['origin'] ?? '';

      // Requests without Origin header (direct API calls, curl, Postman) no
      // reciben cabeceras CORS — el navegador exige Origin en cross-origin.
      if (origin.isEmpty) {
        if (request.method == 'OPTIONS') {
          return Response.ok('');
        }
        return handler(request);
      }

      final allowed = _isAllowedOrigin(origin, allowedOrigins);
      final corsOrigin = allowed ? origin : 'null';

      final corsHeaders = {
        'Access-Control-Allow-Origin': corsOrigin,
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS, PATCH',
        'Access-Control-Allow-Headers':
            'Content-Type, Authorization, X-Requested-With',
        'Access-Control-Allow-Credentials': 'true',
        'Access-Control-Max-Age': '86400',
        'Vary': 'Origin',
      };

      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }

      if (!allowed) {
        // Devuelve la respuesta real pero con Access-Control-Allow-Origin: null
        // para que el navegador bloquee el acceso desde ese origen no permitido.
        final response = await handler(request);
        return response.change(headers: corsHeaders);
      }

      final response = await handler(request);
      return response.change(headers: corsHeaders);
    };
  };
}
