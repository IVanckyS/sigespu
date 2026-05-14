import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;
import '../../config/constants.dart';
import '../local/database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SyncService {
  final AppDatabase _db;
  final Connectivity _connectivity;
  final FlutterSecureStorage _storage;

  SyncService(this._db, this._connectivity, this._storage) {
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
    print('Encolado para sincronización: $accion $entidad ($entidadId)');

    // Intentar sync inmediato si hay red
    final status = await _connectivity.checkConnectivity();
    if (status != ConnectivityResult.none) {
      syncPendingQueue();
    }
  }

  Future<void> syncPendingQueue() async {
    final pendingItems = await _db.select(_db.syncQueueTable).get();
    if (pendingItems.isEmpty) return;

    final token = await _storage.read(key: 'access_token');
    if (token == null) return;

    print('Procesando ${pendingItems.length} elementos en cola FIFO...');

    for (final item in pendingItems) {
      if (item.retryCount >= 3) continue;

      try {
        bool success = false;
        if (item.entidad == 'punto_interes') {
          success = await _syncPuntoInteres(item, token);
        } else if (item.entidad == 'zona_peligro') {
          success = await _syncZona(item, token);
        } else if (item.entidad == 'actividad_municipal') {

          success = await _syncActividad(item, token);
        } else if (item.entidad == 'reporte_seguridad') {
          // TODO: Implementar sync de reportes reales
          success = true; 
        }

        if (success) {
          await (_db.delete(_db.syncQueueTable)..where((t) => t.id.equals(item.id))).go();
          print('Sincronizado exitosamente: ${item.entidad} ${item.entidadId}');
        }
      } catch (e) {
        print('Fallo al sincronizar: $e');
        await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(item.id)))
          .write(SyncQueueTableCompanion(
            retryCount: drift.Value(item.retryCount + 1),
            errorMsg: drift.Value(e.toString())
          ));
      }
    }
  }

  Future<bool> _syncActividad(SyncQueueItem item, String token) async {
    const apiBase = AppConstants.apiBaseUrl;
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    http.Response resp;
    if (item.accion == 'create') {
      resp = await http.post(
        Uri.parse('$apiBase/api/actividades'),
        headers: headers,
        body: item.payloadJson,
      );
    } else if (item.accion == 'update') {
      resp = await http.put(
        Uri.parse('$apiBase/api/actividades/${item.entidadId}'),
        headers: headers,
        body: item.payloadJson,
      );
    } else if (item.accion == 'delete') {
      resp = await http.delete(
        Uri.parse('$apiBase/api/actividades/${item.entidadId}'),
        headers: headers,
      );
    } else {
      return true;
    }

    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  Future<bool> _syncPuntoInteres(SyncQueueItem item, String token) async {
    const apiBase = AppConstants.apiBaseUrl;
    final payload = jsonDecode(item.payloadJson);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    http.Response resp;
    if (item.accion == 'create') {
      resp = await http.post(
        Uri.parse('$apiBase/api/elementos'),
        headers: headers,
        body: item.payloadJson,
      );
    } else if (item.accion == 'update') {
      resp = await http.put(
        Uri.parse('$apiBase/api/elementos/${item.entidadId}'),
        headers: headers,
        body: item.payloadJson,
      );
    } else if (item.accion == 'delete') {
      resp = await http.delete(
        Uri.parse('$apiBase/api/elementos/${item.entidadId}'),
        headers: headers,
      );
    } else {
      return true; // Accion desconocida
    }

    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  Future<bool> _syncZona(SyncQueueItem item, String token) async {
    const apiBase = AppConstants.apiBaseUrl;
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    http.Response resp;
    if (item.accion == 'create') {
      resp = await http.post(
        Uri.parse('$apiBase/api/zonas'),
        headers: headers,
        body: item.payloadJson,
      );
    } else if (item.accion == 'update') {
      resp = await http.put(
        Uri.parse('$apiBase/api/zonas/${item.entidadId}'),
        headers: headers,
        body: item.payloadJson,
      );
    } else if (item.accion == 'delete') {
      resp = await http.delete(
        Uri.parse('$apiBase/api/zonas/${item.entidadId}'),
        headers: headers,
      );
    } else {
      return true;
    }

    return resp.statusCode == 200 || resp.statusCode == 201;
  }
}

