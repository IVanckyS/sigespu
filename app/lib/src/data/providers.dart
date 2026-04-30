import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local/database.dart';
import 'local/daos/reportes_dao.dart';
import 'local/daos/zonas_dao.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final reportesDaoProvider = Provider<ReportesDao>((ref) {
  return ref.watch(databaseProvider).reportesDao;
});

final zonasDaoProvider = Provider<ZonasDao>((ref) {
  return ref.watch(databaseProvider).zonasDao;
});

final reportesStreamProvider = StreamProvider<List<ReporteSeguridadLocal>>((ref) {
  return ref.watch(reportesDaoProvider).watchTodos();
});
