import 'dart:convert';
import 'package:drift/drift.dart';
import '../database.dart';
import 'package:uuid/uuid.dart';
import 'package:shared/shared.dart';

part 'zonas_dao.g.dart';

@DriftAccessor(tables: [ZonasPeligroTable, SyncQueueTable])
class ZonasDao extends DatabaseAccessor<AppDatabase> with _$ZonasDaoMixin {
  final AppDatabase db;
  ZonasDao(this.db) : super(db);

  final _uuid = const Uuid();

  Future<String> crearZona({
    required String nombre,
    required List<List<double>> polygonCoords,
    int? nivelRiesgo,
  }) async {
    final newId = _uuid.v4();
    final now = DateTime.now();

    await transaction(() async {
      await into(zonasPeligroTable).insert(
        ZonasPeligroTableCompanion.insert(
          id: newId,
          nombre: Value(nombre),
          polygonCoordsJson: jsonEncode(polygonCoords),
          nivelRiesgo: Value(nivelRiesgo),
          vigenteDesde: Value(now),
        )
      );

      final zonaDto = ZonaPeligro(
        id: newId,
        nombre: nombre,
        polygonCoords: polygonCoords,
        nivelRiesgo: nivelRiesgo,
        createdAt: now,
      );

      await into(syncQueueTable).insert(
        SyncQueueTableCompanion.insert(
          entidad: 'zona_peligro',
          accion: 'create',
          entidadId: newId,
          payloadJson: jsonEncode(zonaDto.toJson()),
        )
      );
    });

    return newId;
  }
}
