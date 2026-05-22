import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../../presentation/auth/auth_provider.dart';
import 'sync_service.dart';

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final connectivity = ref.watch(connectivityProvider);
  final storage = ref.watch(secureStorageProvider);

  final service = SyncService(db, connectivity, storage);
  // Libera el listener de connectivity cuando el provider sea descartado
  // (evita listeners duplicados en hot-reload o cambio de scope).
  ref.onDispose(service.dispose);
  return service;
});

/// Stream reactivo del número de conflictos sin resolver. El AppShell lo
/// observa para mostrar un badge "N conflictos" en el header.
final conflictCountProvider = StreamProvider<int>((ref) {
  return ref.watch(syncServiceProvider).watchConflictCount();
});

/// Stream reactivo de la lista de conflictos. La pantalla de resolución
/// suscribe a este para refrescar la UI cuando se resuelve uno.
final conflictsProvider = StreamProvider<List<ConflictItem>>((ref) {
  return ref.watch(syncServiceProvider).watchConflicts();
});
