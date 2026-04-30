import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import '../local/database.dart';

class SyncService {
  final AppDatabase _db;
  final Connectivity _connectivity;

  SyncService(this._db, this._connectivity) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        print('Conexión recuperada. Iniciando sincronización...');
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
    await _db.into(_db.syncQueueTable).insert(
      SyncQueueTableCompanion.insert(
        entidad: entidad,
        accion: accion,
        entidadId: entidadId,
        payloadJson: jsonEncode(payload),
      )
    );
    print('Encolado para sincronización offline: \$accion \$entidad (\$entidadId)');
  }

  Future<void> syncPendingQueue() async {
    final pendingItems = await _db.select(_db.syncQueueTable).get();
    
    if (pendingItems.isEmpty) return;

    print('Procesando \${pendingItems.length} elementos en cola FIFO...');

    for (final item in pendingItems) {
      if (item.retryCount >= 3) {
        print('Saltando \${item.entidadId} por límite de reintentos.');
        continue;
      }

      try {
        // Simular llamada al backend: POST /api/sync
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Si tiene éxito, lo borramos de la cola
        await (_db.delete(_db.syncQueueTable)..where((t) => t.id.equals(item.id))).go();
        print('Sincronizado exitosamente: \${item.entidad} \${item.entidadId}');
        
      } catch (e) {
        // Backoff exponencial y reintentos (simulados)
        print('Fallo al sincronizar: \$e');
        await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(item.id)))
          .write(SyncQueueTableCompanion(
            retryCount: drift.Value(item.retryCount + 1),
            errorMsg: drift.Value(e.toString())
          ));
      }
    }
  }
}
