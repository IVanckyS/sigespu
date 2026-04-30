// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reportes_dao.dart';

// ignore_for_file: type=lint
mixin _$ReportesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReportesSeguridadTableTable get reportesSeguridadTable =>
      attachedDatabase.reportesSeguridadTable;
  $SyncQueueTableTable get syncQueueTable => attachedDatabase.syncQueueTable;
  ReportesDaoManager get managers => ReportesDaoManager(this);
}

class ReportesDaoManager {
  final _$ReportesDaoMixin _db;
  ReportesDaoManager(this._db);
  $$ReportesSeguridadTableTableTableManager get reportesSeguridadTable =>
      $$ReportesSeguridadTableTableTableManager(
          _db.attachedDatabase, _db.reportesSeguridadTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(
          _db.attachedDatabase, _db.syncQueueTable);
}
