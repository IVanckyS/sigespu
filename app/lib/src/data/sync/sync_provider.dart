import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/database.dart';
import '../../presentation/auth/auth_provider.dart';
import 'sync_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final connectivity = ref.watch(connectivityProvider);
  final storage = ref.watch(secureStorageProvider);
  
  return SyncService(db, connectivity, storage);
});
