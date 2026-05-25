import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../../config/constants.dart';
import '../local/database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _log = Logger('Sync');

/// Resultado de una operación de sync individual. Distingue conflicto
/// (servidor tiene versión más nueva — el item no debe reintentarse
/// automáticamente, requiere resolución del usuario) de error transiente
/// (red, 5xx — sí reintentar) y de éxito.
enum SyncResult { ok, conflict, transientError }

/// Marker usado en `SyncQueueTable.retryCount` para indicar conflicto
/// permanente. Mayor que el cap normal (3) → nunca se procesa en el bucle.
const _conflictRetryMarker = 999;

class SyncService {
  final AppDatabase _db;
  final Connectivity _connectivity;
  final FlutterSecureStorage _storage;

  StreamSubscription<List<ConnectivityResult>>? _connSub;

  SyncService(this._db, this._connectivity, this._storage) {
    _initConnectivityListener();
  }

  /// Llamar al destruir el provider para liberar el listener. Sin esto, si el
  /// SyncService se recrea (ej. hot-reload o cambio de provider scope), los
  /// listeners se acumulan y producen syncs paralelos corruptos.
  Future<void> dispose() async {
    await _connSub?.cancel();
    _connSub = null;
  }

  void _initConnectivityListener() {
    _connSub?.cancel();
    _connSub = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        _log.info('Conexión recuperada. Iniciando sincronización...');
        syncPendingQueue();
      }
    });
  }

  Future<void> queueForSync({
    required String entidad,
    required String accion,
    required String entidadId,
    required Map<String, dynamic> payload,
  }) async {
    // Para updates, captura el timestamp del cliente al momento de encolar.
    // El backend usa este valor para detectar conflictos: si el server tiene
    // una versión con `updated_at > client_updated_at`, devuelve 409.
    final enriched = Map<String, dynamic>.from(payload);
    if (accion == 'update' && !enriched.containsKey('client_updated_at')) {
      enriched['client_updated_at'] = DateTime.now().toUtc().toIso8601String();
    }

    await _db.into(_db.syncQueueTable).insert(
      SyncQueueTableCompanion.insert(
        entidad: entidad,
        accion: accion,
        entidadId: entidadId,
        payloadJson: jsonEncode(enriched),
      )
    );
    _log.info('Encolado: $accion $entidad ($entidadId)');

    // Intentar sync inmediato si hay red
    final status = await _connectivity.checkConnectivity();
    if (status.any((r) => r != ConnectivityResult.none)) {
      syncPendingQueue();
    }
  }

  /// Cuenta los items con error transiente (3-998 reintentos fallidos).
  /// El UI puede llamarla para mostrar un badge "N items sin sincronizar".
  Future<int> permanentlyFailedCount() async {
    final query = _db.select(_db.syncQueueTable)
      ..where((t) =>
          t.retryCount.isBiggerOrEqualValue(3) &
          t.retryCount.isSmallerThanValue(_conflictRetryMarker));
    return (await query.get()).length;
  }

  /// Cuenta items con conflicto pendiente de resolución del usuario.
  /// El UI debería mostrarlos en una bandeja "Cambios en conflicto" para que
  /// el usuario decida: descartar local, o forzar overwrite del server.
  Future<int> conflictCount() async {
    final query = _db.select(_db.syncQueueTable)
      ..where((t) => t.retryCount.equals(_conflictRetryMarker));
    return (await query.get()).length;
  }

  /// Stream reactivo de la cantidad de conflictos — útil para badges del UI
  /// que deben actualizarse automáticamente cuando llega un 409 o se resuelve uno.
  Stream<int> watchConflictCount() {
    final query = _db.select(_db.syncQueueTable)
      ..where((t) => t.retryCount.equals(_conflictRetryMarker));
    return query.watch().map((rows) => rows.length);
  }

  /// Lista detallada de conflictos pendientes con `local` (lo que intentó
  /// guardar el usuario) y `server` (lo que tiene la BD). El UI los compara
  /// lado-a-lado para que el usuario decida.
  Future<List<ConflictItem>> listConflicts() async {
    final query = _db.select(_db.syncQueueTable)
      ..where((t) => t.retryCount.equals(_conflictRetryMarker));
    final rows = await query.get();
    return rows.map(ConflictItem.fromRow).toList();
  }

  /// Stream reactivo de la lista de conflictos.
  Stream<List<ConflictItem>> watchConflicts() {
    final query = _db.select(_db.syncQueueTable)
      ..where((t) => t.retryCount.equals(_conflictRetryMarker));
    return query
        .watch()
        .map((rows) => rows.map(ConflictItem.fromRow).toList());
  }

  /// Re-encola un conflicto para forzar overwrite del servidor: quita el
  /// `client_updated_at` del payload (el backend cae a last-write-wins) y
  /// resetea el `retryCount` a 0 para que el SyncService lo procese de nuevo
  /// en el siguiente tick.
  Future<void> forceOverwrite(int itemId) async {
    final row = await (_db.select(_db.syncQueueTable)
          ..where((t) => t.id.equals(itemId)))
        .getSingleOrNull();
    if (row == null) return;

    final payload = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    payload.remove('client_updated_at');

    await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(itemId)))
        .write(SyncQueueTableCompanion(
      retryCount: const drift.Value(0),
      errorMsg: const drift.Value(null),
      payloadJson: drift.Value(jsonEncode(payload)),
    ));
    _log.info('Forzando overwrite del servidor: item=$itemId');

    // Procesar inmediatamente si hay red.
    final status = await _connectivity.checkConnectivity();
    if (status.any((r) => r != ConnectivityResult.none)) {
      syncPendingQueue();
    }
  }

  /// Descarta los cambios locales de un item en conflicto. El payload local
  /// se pierde — útil cuando el usuario decide quedarse con la versión server.
  Future<void> discardConflict(int itemId) async {
    await (_db.delete(_db.syncQueueTable)..where((t) => t.id.equals(itemId))).go();
    _log.info('Conflicto descartado: item=$itemId');
  }

  Future<void> syncPendingQueue() async {
    final pendingItems = await _db.select(_db.syncQueueTable).get();
    if (pendingItems.isEmpty) return;

    final token = await _storage.read(key: 'access_token');
    if (token == null) return;

    // Skipea items con error permanente (retryCount >= 3) y conflictos (999).
    final actionable = pendingItems.where((i) => i.retryCount < 3).toList();
    if (actionable.isEmpty) return;
    _log.info('Procesando ${actionable.length} elementos en cola FIFO...');

    for (final item in actionable) {
      try {
        (SyncResult, String?) result = (SyncResult.ok, null);
        if (item.entidad == 'punto_interes') {
          result = await _syncPuntoInteres(item, token);
        } else if (item.entidad == 'zona_peligro') {
          result = await _syncZona(item, token);
        } else if (item.entidad == 'actividad_municipal') {
          result = await _syncActividad(item, token);
        } else if (item.entidad == 'reporte_seguridad') {
          // TODO(sprint-3): Implementar sync de reportes reales
          result = (SyncResult.ok, null);
        }

        switch (result.$1) {
          case SyncResult.ok:
            await (_db.delete(_db.syncQueueTable)
                  ..where((t) => t.id.equals(item.id)))
                .go();
            _log.fine('OK: ${item.entidad} ${item.entidadId}');
          case SyncResult.conflict:
            // Persistimos el body completo del 409 (que incluye server_state)
            // en errorMsg con prefijo CONFLICT: — el UI lo parsea para mostrar
            // un comparativo local vs servidor.
            final body = result.$2 ?? '{"error":"CONFLICT"}';
            await (_db.update(_db.syncQueueTable)
                  ..where((t) => t.id.equals(item.id)))
                .write(SyncQueueTableCompanion(
                  retryCount: const drift.Value(_conflictRetryMarker),
                  errorMsg: drift.Value('CONFLICT:$body'),
                ));
            _log.warning(
                'CONFLICTO ${item.entidad} ${item.entidadId}: el server tiene una versión más nueva. Requiere resolución del usuario.');
          case SyncResult.transientError:
            await (_db.update(_db.syncQueueTable)
                  ..where((t) => t.id.equals(item.id)))
                .write(SyncQueueTableCompanion(
                  retryCount: drift.Value(item.retryCount + 1),
                  errorMsg: const drift.Value('Error de red o 5xx'),
                ));
        }
      } catch (e, st) {
        _log.warning('Fallo al sincronizar ${item.entidad} ${item.entidadId}', e, st);
        await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(item.id)))
          .write(SyncQueueTableCompanion(
            retryCount: drift.Value(item.retryCount + 1),
            errorMsg: drift.Value(e.toString())
          ));
      }
    }
  }

  /// Mapea status HTTP a SyncResult. 200/201 = ok, 409 = conflict, resto = transient.
  /// 4xx (excepto 409) son técnicamente errores del cliente pero los tratamos
  /// como transientes — el retry cap (3) los aborta de todos modos.
  SyncResult _resultFor(int statusCode) {
    if (statusCode == 200 || statusCode == 201) return SyncResult.ok;
    if (statusCode == 409) return SyncResult.conflict;
    return SyncResult.transientError;
  }

  Future<(SyncResult, String?)> _syncActividad(SyncQueueItem item, String token) =>
      _syncEntidad(item, token, '/api/actividades');

  Future<(SyncResult, String?)> _syncPuntoInteres(SyncQueueItem item, String token) =>
      _syncEntidad(item, token, '/api/elementos');

  Future<(SyncResult, String?)> _syncZona(SyncQueueItem item, String token) =>
      _syncEntidad(item, token, '/api/zonas');

  /// Sync genérico contra un endpoint REST. Retorna el SyncResult + el body
  /// de respuesta — necesario para extraer `server_state` en caso de 409.
  Future<(SyncResult, String?)> _syncEntidad(
    SyncQueueItem item,
    String token,
    String basePath,
  ) async {
    const apiBase = AppConstants.apiBaseUrl;
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    http.Response resp;
    if (item.accion == 'create') {
      resp = await http.post(
        Uri.parse('$apiBase$basePath'),
        headers: headers,
        body: item.payloadJson,
      );
    } else if (item.accion == 'update') {
      resp = await http.put(
        Uri.parse('$apiBase$basePath/${item.entidadId}'),
        headers: headers,
        body: item.payloadJson,
      );
    } else if (item.accion == 'delete') {
      resp = await http.delete(
        Uri.parse('$apiBase$basePath/${item.entidadId}'),
        headers: headers,
      );
    } else {
      return (SyncResult.ok, null); // Acción desconocida — la descartamos.
    }

    return (_resultFor(resp.statusCode), resp.body);
  }
}

// ── ConflictItem ─────────────────────────────────────────────────────────────

/// Representación lista-para-UI de un item de la cola de sync que entró en
/// conflicto con el servidor. Encapsula el parsing del payload local y del
/// `errorMsg` (que lleva el body 409 con prefijo `CONFLICT:`).
class ConflictItem {
  /// ID interno de la cola de sync (autoincremental). Usar para llamar
  /// [SyncService.discardConflict] o [SyncService.forceOverwrite].
  final int id;
  final String entidad;
  final String accion;
  final String entidadId;

  /// Lo que el usuario intentó guardar localmente.
  final Map<String, dynamic> local;

  /// Estado actual en el servidor (lo que provocó el 409). `null` si el body
  /// del 409 no incluía `server_state` (no debería ocurrir con nuestros
  /// handlers, pero el UI debe defenderse).
  final Map<String, dynamic>? server;

  /// Mensaje legible del 409 — útil para mostrar en el banner del UI.
  final String message;

  const ConflictItem({
    required this.id,
    required this.entidad,
    required this.accion,
    required this.entidadId,
    required this.local,
    required this.server,
    required this.message,
  });

  factory ConflictItem.fromRow(SyncQueueItem row) {
    Map<String, dynamic> local = const {};
    try {
      local = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    } catch (_) {}

    Map<String, dynamic>? server;
    String message = 'Conflicto de sincronización';
    final raw = row.errorMsg;
    if (raw != null && raw.startsWith('CONFLICT:')) {
      try {
        final body = jsonDecode(raw.substring('CONFLICT:'.length)) as Map<String, dynamic>;
        server = body['server_state'] as Map<String, dynamic>?;
        message = (body['message'] as String?) ?? message;
      } catch (_) {}
    }

    return ConflictItem(
      id: row.id,
      entidad: row.entidad,
      accion: row.accion,
      entidadId: row.entidadId,
      local: local,
      server: server,
      message: message,
    );
  }

  /// Etiqueta amigable de la entidad para el UI.
  String get entidadLabel {
    switch (entidad) {
      case 'punto_interes':
        return 'Elemento del mapa';
      case 'zona_peligro':
        return 'Zona';
      case 'actividad_municipal':
        return 'Actividad';
      case 'reporte_seguridad':
        return 'Reporte';
      default:
        return entidad;
    }
  }
}

