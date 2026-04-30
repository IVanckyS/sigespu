import 'package:shelf/shelf.dart';

bool _isAllowedOrigin(String origin) {
  if (origin.isEmpty) return true;
  final uri = Uri.tryParse(origin);
  if (uri == null) return false;
  return uri.host == 'localhost' || uri.host == '127.0.0.1';
}

Middleware corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      final origin = request.headers['origin'] ?? '';
      final allowed = _isAllowedOrigin(origin);
      final corsOrigin = allowed ? (origin.isEmpty ? '*' : origin) : 'http://localhost';

      final corsHeaders = {
        'Access-Control-Allow-Origin': corsOrigin,
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS, PATCH',
        'Access-Control-Allow-Headers':
            'Content-Type, Authorization, X-Requested-With',
        'Access-Control-Allow-Credentials': 'true',
        'Access-Control-Max-Age': '86400',
      };

      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }

      final response = await handler(request);
      return response.change(headers: corsHeaders);
    };
  };
}
