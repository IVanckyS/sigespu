import 'dart:convert';

/// Lleva el estado del scraping en Redis bajo la key `scraping:status`.
///
/// Formato JSON:
/// ```json
/// {
///   "running": true,
///   "modo": "actual" | "historico",
///   "fuente": "patentes",
///   "fuente_label": "Patentes comerciales 2026 S1",
///   "step": 3,
///   "totalSteps": 12,
///   "progress": 0.25,
///   "started_at": "2026-04-25T14:00:00Z",
///   "finished_at": null,
///   "ok": 0,
///   "errores": 0
/// }
/// ```
/// Excepción lanzada cuando el operador pide detener el scraping en curso.
/// La capturan runScrapingActual / runScrapingHistorico para hacer finish()
/// con error="cancelado por usuario" en vez de propagarla.
class ScrapingCancelledException implements Exception {
  const ScrapingCancelledException();
  @override
  String toString() => 'ScrapingCancelledException';
}

class ProgressTracker {
  static const _key = 'scraping:status';
  static const _cancelKey = 'scraping:cancel';
  static const _ttlSeconds = 1800; // 30 min; Nominatim puede ser lento entre ticks

  /// Marca el scraping en curso para que se detenga en el próximo checkpoint.
  /// El backend lo invoca desde POST /api/scraping/stop. Es idempotente.
  static Future<void> requestCancel(dynamic redis) async {
    await redis.send_object(['SET', _cancelKey, '1', 'EX', '$_ttlSeconds']);
  }

  /// Lectura no-bloqueante: los scrapers la llaman cada N rows / entre categorías.
  /// Si devuelve true deben lanzar ScrapingCancelledException.
  static Future<bool> isCancelRequested(dynamic redis) async {
    final raw = await redis.send_object(['GET', _cancelKey]);
    return raw != null;
  }

  /// Limpia el flag al iniciar un scraping nuevo, para que un cancel previo
  /// no aborte instantáneamente la nueva corrida.
  static Future<void> clearCancel(dynamic redis) async {
    await redis.send_object(['DEL', _cancelKey]);
  }

  /// Helper combinado: verifica el flag y lanza si está activo.
  /// Llamar entre rows o entre pasos para tener una salida cooperativa.
  static Future<void> throwIfCancelled(dynamic redis) async {
    if (await isCancelRequested(redis)) {
      throw const ScrapingCancelledException();
    }
  }

  final dynamic _redis;
  final String _modo;
  final int _totalSteps;
  final DateTime _startedAt;

  int _step = 0;
  int _ok = 0;
  int _err = 0;
  String _fuente = '';
  String _fuenteLabel = '';

  ProgressTracker(this._redis, {required String modo, required int totalSteps})
      : _modo = modo,
        _totalSteps = totalSteps,
        _startedAt = DateTime.now().toUtc();

  static Future<bool> isRunning(dynamic redis) async {
    final raw = await redis.send_object(['GET', _key]);
    if (raw is! String) return false;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return data['running'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> start() async {
    await _write(running: true);
  }

  Future<void> stepStart({required String fuente, required String label}) async {
    _step++;
    _fuente = fuente;
    _fuenteLabel = label;
    await _write(running: true);
  }

  void addOk([int n = 1]) => _ok += n;
  void addErr([int n = 1]) => _err += n;

  Future<void> tick() async {
    await _write(running: true);
  }

  Future<void> finish({String? error}) async {
    await _write(running: false, error: error);
  }

  Future<void> _write({required bool running, String? error}) async {
    final progress = _totalSteps == 0 ? 0.0 : (_step / _totalSteps).clamp(0.0, 1.0);
    final payload = jsonEncode({
      'running': running,
      'modo': _modo,
      'fuente': _fuente,
      'fuente_label': _fuenteLabel,
      'step': _step,
      'total_steps': _totalSteps,
      'progress': progress,
      'started_at': _startedAt.toIso8601String(),
      'finished_at': running ? null : DateTime.now().toUtc().toIso8601String(),
      'ok': _ok,
      'errores': _err,
      if (error != null) 'error': error,
    });

    await _redis.send_object(['SET', _key, payload, 'EX', '$_ttlSeconds']);
  }
}
