// Stub mínimo: wrapper sobre http.Client con un campo "cached".
// El recovery del 19-may esperaba un cliente de cache offline más complejo
// (cache-first via Drift); aquí cumplimos solo la firma para que compile.
// TODO(sprint-3): reimplementar caché real con Drift + ETag.

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class CachedResponse {
  final int statusCode;
  final String? body;
  final bool fromCache;
  final DateTime? cachedAt;

  CachedResponse({
    required this.statusCode,
    this.body,
    this.fromCache = false,
    this.cachedAt,
  });

  bool get hasData => body != null && statusCode >= 200 && statusCode < 300;

  /// Stub: marca el dato como "fresco" si vino directo de la red.
  /// El recovery esperaba TTL-aware cache; mientras no haya cache, todo es fresh.
  bool get isFresh => !fromCache;
}

class CachedApi {
  final http.Client _client = http.Client();

  Future<CachedResponse> get(
    Uri uri, {
    Map<String, String>? headers,
    String? cacheKey,
    Duration? timeout,
  }) async {
    try {
      final resp = await _client
          .get(uri, headers: headers)
          .timeout(timeout ?? const Duration(seconds: 15));
      return CachedResponse(statusCode: resp.statusCode, body: resp.body);
    } on SocketException {
      return CachedResponse(statusCode: 0, body: null);
    } catch (_) {
      return CachedResponse(statusCode: 0, body: null);
    }
  }
}

final cachedApiProvider = Provider<CachedApi>((ref) => CachedApi());
