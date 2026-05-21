// Helper HTTP autenticado con refresh-on-401 automático.
//
// Cuando el backend devuelve 401, intenta refrescar el access token via
// AuthNotifier.tryRefresh y reintenta la request una vez. Si el refresh
// falla, propaga el 401 — el caller decide qué hacer (típicamente Riverpod
// FutureProvider lo expone como AsyncError y la UI muestra estado vacío).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../presentation/auth/auth_provider.dart';

class AuthedHttp {
  final Ref _ref;
  AuthedHttp(this._ref);

  /// GET autenticado. Adjunta el Bearer token y reintenta una vez tras 401.
  Future<http.Response> get(Uri url, {Map<String, String>? extraHeaders}) async {
    return _retryOn401(() async {
      final headers = await _authHeaders(extraHeaders);
      return http.get(url, headers: headers);
    });
  }

  /// POST autenticado con body opcional.
  Future<http.Response> post(
    Uri url, {
    Object? body,
    Map<String, String>? extraHeaders,
  }) async {
    return _retryOn401(() async {
      final headers = await _authHeaders({
        if (body != null) 'Content-Type': 'application/json',
        ...?extraHeaders,
      });
      return http.post(url, headers: headers, body: body);
    });
  }

  Future<Map<String, String>> _authHeaders(Map<String, String>? extra) async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.read(key: 'access_token');
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      ...?extra,
    };
  }

  Future<http.Response> _retryOn401(
      Future<http.Response> Function() send) async {
    final first = await send();
    if (first.statusCode != 401) return first;

    final refreshed = await _ref.read(authProvider.notifier).tryRefresh();
    if (!refreshed) return first;

    return send();
  }
}

final authedHttpProvider = Provider<AuthedHttp>((ref) => AuthedHttp(ref));
