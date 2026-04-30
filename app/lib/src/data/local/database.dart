import 'package:drift/drift.dart';
import 'daos/reportes_dao.dart';
import 'daos/zonas_dao.dart';
import 'connection/shared.dart'
    if (dart.library.js_interop) 'connection/web.dart'
    if (dart.library.ffi) 'connection/native.dart';

part 'database.g.dart';

@DataClassName('PuntoInteresLocal')
class PuntosInteresTable extends Table {
  TextColumn get id => text()();
  TextColumn get tipo => text()();
  TextColumn get nombre => text().nullable()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get direccion => text().nullable()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get estado => text().withDefault(const Constant('activo'))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ZonaPeligroLocal')
class ZonasPeligroTable extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text().nullable()();
  TextColumn get polygonCoordsJson => text()(); // Almacenar el JSON de coordenadas
  IntColumn get nivelRiesgo => integer().nullable()();
  TextColumn get tipoRiesgo => text().nullable()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get horarioCritico => text().nullable()();
  DateTimeColumn get vigenteDesde => dateTime().nullable()();
  DateTimeColumn get vigenteHasta => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReporteSeguridadLocal')
class ReportesSeguridadTable extends Table {
  TextColumn get id => text()();
  TextColumn get tipo => text()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get direccion => text().nullable()();
  TextColumn get descripcion => text().nullable()();
  IntColumn get severidad => integer().nullable()();
  DateTimeColumn get fechaEvento => dateTime().nullable()();
  TextColumn get estado => text().withDefault(const Constant('reportado'))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PatenteComercialLocal')
class PatentesComercialesTable extends Table {
  TextColumn get id => text()();
  TextColumn get tipoPatente => text().nullable()();
  TextColumn get rut => text().nullable()();
  TextColumn get razonSocial => text().nullable()();
  TextColumn get giro => text().nullable()();
  TextColumn get direccionNormalizada => text().nullable()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get estadoInferido => text().withDefault(const Constant('vigente_esperado'))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncQueueItem')
class SyncQueueTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entidad => text()(); // 'punto_interes', 'reporte_seguridad', etc.
  TextColumn get accion => text()(); // 'create', 'update', 'delete'
  TextColumn get entidadId => text()();
  TextColumn get payloadJson => text()(); // Datos a sincronizar
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMsg => text().nullable()();
}

@DriftDatabase(
  tables: [
    PuntosInteresTable,
    ZonasPeligroTable,
    ReportesSeguridadTable,
    PatentesComercialesTable,
    SyncQueueTable,
  ],
  daos: [ReportesDao, ZonasDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connect());

  @override
  int get schemaVersion => 1;

  @override
  ReportesDao get reportesDao => ReportesDao(this);
  @override
  ZonasDao get zonasDao => ZonasDao(this);
}
