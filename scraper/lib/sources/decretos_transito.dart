import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';
import '../progress.dart';

/// Stub — la fuente ig=269 aún no está implementada.
/// Se mantiene la firma para que el orchestrator pueda llamarla sin condicionales.
Future<void> scrapeDecretosTransito(Connection db, Command redis,
    {ProgressTracker? tracker}) async {
  await tracker?.stepStart(
      fuente: 'decretos_transito',
      label: 'Decretos tránsito (no implementado)');
  print('[decretos_transito] Stub — fuente ig=269 pendiente de implementación');
  await tracker?.tick();
}
