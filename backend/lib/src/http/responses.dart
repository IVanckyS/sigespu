// Helpers de respuesta HTTP usados por todos los routes del backend.
// Centralizan el formato JSON y el manejo de errores para que los handlers
// queden declarativos: `return ok(items)` en vez de armar Response a mano.

import 'dart:convert';
import 'package:shelf/shelf.dart';

const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

/// Excepción de validación de entrada — la captura `guard()` y la convierte
/// en 400. Cualquier validator (validators.dart) la lanza con un mensaje
/// orientado al cliente.
class HttpValidationException implements Exception {
  final String message;
  final int statusCode;
  HttpValidationException(this.message, {this.statusCode = 400});
  @override
  String toString() => 'HttpValidationException($statusCode): $message';
}

/// 200 OK con cuerpo JSON.
Response ok(Object? data) =>
    Response.ok(jsonEncode(data), headers: _jsonHeaders);

/// 201 Created con cuerpo JSON.
Response created(Object? data) =>
    Response(201, body: jsonEncode(data), headers: _jsonHeaders);

/// 204 No Content.
Response noContent() => Response(204);

/// 400 Bad Request con mensaje de error.
Response badRequest(String message) => Response(
      400,
      body: jsonEncode({'error': message}),
      headers: _jsonHeaders,
    );

/// 404 Not Found.
Response notFound(String message) => Response.notFound(
      jsonEncode({'error': message}),
      headers: _jsonHeaders,
    );

/// 409 Conflict — usado típicamente para conflictos de versión en updates.
Response conflict(String message) => Response(
      409,
      body: jsonEncode({'error': message}),
      headers: _jsonHeaders,
    );

/// 500 Internal Server Error.
///
/// Si se pasan `error` y `stackTrace`, loggea con el `label` antes de
/// responder (formato `[label] error\nstack`). El cliente solo ve un
/// mensaje genérico — los detalles quedan en el log del servidor.
Response serverError(String labelOrMessage, [Object? error, StackTrace? stackTrace]) {
  if (error != null) {
    print('[$labelOrMessage] $error${stackTrace != null ? '\n$stackTrace' : ''}');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Error interno'}),
      headers: _jsonHeaders,
    );
  }
  return Response.internalServerError(
    body: jsonEncode({'error': labelOrMessage}),
    headers: _jsonHeaders,
  );
}

/// Envuelve un handler async para capturar errores de validación y
/// excepciones inesperadas, devolviendo una respuesta JSON consistente.
///
///   router.post('/foo', (req) => guard('createFoo', () async {
///     final body = await readJsonObject(req);
///     final name = requireString(body, 'name', maxLen: 100);
///     ...
///     return created({'id': id});
///   }));
///
/// Si algún `require*` falla, devuelve 400 con `{"error":"<mensaje>"}`.
/// Si hay una excepción no controlada, loggea y devuelve 500.
Future<Response> guard(String label, Future<Response> Function() handler) async {
  try {
    return await handler();
  } on HttpValidationException catch (e) {
    return Response(
      e.statusCode,
      body: jsonEncode({'error': e.message}),
      headers: _jsonHeaders,
    );
  } catch (e, st) {
    print('[$label] $e\n$st');
    return serverError('Error interno');
  }
}
