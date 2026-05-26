import 'dart:io';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

final _log = Logger('CORS');

/// Orígenes permitidos: localhost en dev, más el dominio de producción si se
/// configura mediante ALLOWED_ORIGIN (ej. https://sigespu.lota.cl).
/// Soporta múltiples orígenes separados por coma.
Set<String> _buildAllowedOrigins() {
  final origins = <String>{
    'http://localhost',
    'http://localhost:8080',
    'http://127.0.0.1',
    'http://127.0.0.1:8080',
  };
  final envOrigin = Platform.environment['ALLOWED_ORIGIN'];
  if (envOrigin != null && envOrigin.isNotEmpty) {
    // Soporta "https://a.com,https://b.com" y normaliza trailing slash
    for (final raw in envOrigin.split(',')) {
      final cleaned = raw.trim().replaceAll(RegExp(r'/$'), '');
      if (cleaned.isNotEmpty) origins.add(cleaned);
    }
  }
  _log.info('Orígenes CORS permitidos: $origins');
  return origins;
}

bool _isAllowedOrigin(String origin, Set<String> allowed) {
  if (origin.isEmpty) return false;
  final uri = Uri.tryParse(origin);
  if (uri == null) return false;
  // Allow any localhost / 127.0.0.1 port (Flutter dev server uses a random port)
  if (uri.host == 'localhost' || uri.host == '127.0.0.1') return true;
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

      // Siempre añadir headers CORS, incluso si el handler lanza excepción.
      // Sin este try-catch, un 500 de Shelf no pasa por response.change()
      // y el navegador recibe la respuesta sin Access-Control-Allow-Origin.
      try {
        final response = await handler(request);
        return response.change(headers: corsHeaders);
      } catch (_) {
        return Response.internalServerError(
          body: '{"error":"Internal server error"}',
          headers: {
            ...corsHeaders,
            'content-type': 'application/json',
          },
        );
      }
    };
  };
}
