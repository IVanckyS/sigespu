// Validators tipados para el body JSON de los endpoints. Lanzan
// HttpValidationException cuando el dato falta, tiene tipo equivocado, o
// excede los límites — el handler la captura via guard() y devuelve 400.

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'responses.dart';

/// Lee el body de la request y exige que sea un objeto JSON.
/// Si está vacío, devuelve un Map vacío (útil para PATCH con body opcional).
Future<Map<String, dynamic>> readJsonObject(Request req) async {
  final raw = await req.readAsString();
  if (raw.trim().isEmpty) return <String, dynamic>{};
  Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (_) {
    throw HttpValidationException('Body no es JSON válido');
  }
  if (decoded is! Map<String, dynamic>) {
    throw HttpValidationException('Body debe ser un objeto JSON');
  }
  return decoded;
}

/// Exige un string no vacío. `maxLen` recorta inputs abusivos.
String requireString(Map<String, dynamic> body, String key, {int maxLen = 1000}) {
  final v = body[key];
  if (v == null) throw HttpValidationException('Falta el campo "$key"');
  if (v is! String) throw HttpValidationException('"$key" debe ser texto');
  final s = v.trim();
  if (s.isEmpty) throw HttpValidationException('"$key" no puede estar vacío');
  if (s.length > maxLen) {
    throw HttpValidationException('"$key" excede $maxLen caracteres');
  }
  return s;
}

/// String opcional. Retorna null si falta o es cadena vacía.
String? optionalString(Map<String, dynamic> body, String key, {int maxLen = 1000}) {
  final v = body[key];
  if (v == null) return null;
  if (v is! String) throw HttpValidationException('"$key" debe ser texto');
  final s = v.trim();
  if (s.isEmpty) return null;
  if (s.length > maxLen) {
    throw HttpValidationException('"$key" excede $maxLen caracteres');
  }
  return s;
}

/// Exige un double dentro de rango. Acepta también ints (los convierte).
double requireDouble(Map<String, dynamic> body, String key,
    {double? min, double? max}) {
  final v = body[key];
  if (v == null) throw HttpValidationException('Falta el campo "$key"');
  final d = _toDouble(v, key);
  _checkRange(key, d, min, max);
  return d;
}

/// Double opcional. Retorna null si falta.
double? optionalDouble(Map<String, dynamic> body, String key,
    {double? min, double? max}) {
  final v = body[key];
  if (v == null) return null;
  final d = _toDouble(v, key);
  _checkRange(key, d, min, max);
  return d;
}

/// Atajo para latitud (-90..90), con el nombre estándar 'lat'.
double requireLat(Map<String, dynamic> body, {String key = 'lat'}) =>
    requireDouble(body, key, min: -90, max: 90);

/// Atajo para longitud (-180..180), con el nombre estándar 'lng'.
double requireLng(Map<String, dynamic> body, {String key = 'lng'}) =>
    requireDouble(body, key, min: -180, max: 180);

/// Exige un valor que esté en el conjunto de strings permitidos.
String requireEnum(Map<String, dynamic> body, String key, Set<String> allowed) {
  final v = requireString(body, key, maxLen: 64);
  if (!allowed.contains(v)) {
    throw HttpValidationException(
        '"$key" debe ser uno de: ${allowed.join(", ")}');
  }
  return v;
}

/// Exige un int dentro de rango.
int requireInt(Map<String, dynamic> body, String key, {int? min, int? max}) {
  final v = body[key];
  if (v == null) throw HttpValidationException('Falta el campo "$key"');
  if (v is! int) {
    if (v is num) return _checkIntRange(key, v.toInt(), min, max);
    throw HttpValidationException('"$key" debe ser entero');
  }
  return _checkIntRange(key, v, min, max);
}

/// Int opcional.
int? optionalInt(Map<String, dynamic> body, String key, {int? min, int? max}) {
  final v = body[key];
  if (v == null) return null;
  if (v is! int) {
    if (v is num) return _checkIntRange(key, v.toInt(), min, max);
    throw HttpValidationException('"$key" debe ser entero');
  }
  return _checkIntRange(key, v, min, max);
}

// ── helpers internos ────────────────────────────────────────────────────────

double _toDouble(Object v, String key) {
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  throw HttpValidationException('"$key" debe ser un número');
}

void _checkRange(String key, double v, double? min, double? max) {
  if (min != null && v < min) {
    throw HttpValidationException('"$key" debe ser >= $min');
  }
  if (max != null && v > max) {
    throw HttpValidationException('"$key" debe ser <= $max');
  }
}

int _checkIntRange(String key, int v, int? min, int? max) {
  if (min != null && v < min) {
    throw HttpValidationException('"$key" debe ser >= $min');
  }
  if (max != null && v > max) {
    throw HttpValidationException('"$key" debe ser <= $max');
  }
  return v;
}
