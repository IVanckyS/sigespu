// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zonas_dao.dart';

// ignore_for_file: type=lint
mixin _$ZonasDaoMixin on DatabaseAccessor<AppDatabase> {
  $ZonasPeligroTableTable get zonasPeligroTable =>
      attachedDatabase.zonasPeligroTable;
  $SyncQueueTableTable get syncQueueTable => attachedDatabase.syncQueueTable;
  ZonasDaoManager get managers => ZonasDaoManager(this);
}

class ZonasDaoManager {
  final _$ZonasDaoMixin _db;
  ZonasDaoManager(this._db);
  $$ZonasPeligroTableTableTableManager get zonasPeligroTable =>
      $$ZonasPeligroTableTableTableManager(
          _db.attachedDatabase, _db.zonasPeligroTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(
          _db.attachedDatabase, _db.syncQueueTable);
}
