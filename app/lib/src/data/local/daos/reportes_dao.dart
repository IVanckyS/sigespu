import 'dart:convert';
import 'package:drift/drift.dart';
import '../database.dart';
import 'package:uuid/uuid.dart';
import 'package:shared/shared.dart';

part 'reportes_dao.g.dart';

@DriftAccessor(tables: [ReportesSeguridadTable, SyncQueueTable])
class ReportesDao extends DatabaseAccessor<AppDatabase> with _$ReportesDaoMixin {
  final AppDatabase db;
  ReportesDao(this.db) : super(db);

  final _uuid = const Uuid();

  Future<List<ReporteSeguridadLocal>> getTodos() => select(reportesSeguridadTable).get();

  Stream<List<ReporteSeguridadLocal>> watchTodos() => select(reportesSeguridadTable).watch();

  Future<String> crearReporte({
    required String tipo,
    required double lat,
    required double lng,
    String? descripcion,
    int? severidad,
  }) async {
    final newId = _uuid.v4();
    final now = DateTime.now();

    // Iniciar transacción: guardar local y encolar
    await transaction(() async {
      await into(reportesSeguridadTable).insert(
        ReportesSeguridadTableCompanion.insert(
          id: newId,
          tipo: tipo,
          lat: lat,
          lng: lng,
          descripcion: Value(descripcion),
          severidad: Value(severidad),
          fechaEvento: Value(now),
        )
      );

      // Encolar para sincronización
      final reporteDto = ReporteSeguridad(
        id: newId,
        tipo: tipo,
        lat: lat,
        lng: lng,
        descripcion: descripcion,
        severidad: severidad,
        fechaEvento: now,
        estado: 'reportado',
      );

      await into(syncQueueTable).insert(
        SyncQueueTableCompanion.insert(
          entidad: 'reporte_seguridad',
          accion: 'create',
          entidadId: newId,
          payloadJson: jsonEncode(reporteDto.toJson()),
        )
      );
    });

    return newId;
  }
}
