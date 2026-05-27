import 'package:postgres/postgres.dart';
import '../progress.dart';

/// Stub — la fuente ig=269 aún no está implementada.
/// Se mantiene la firma para que el orchestrator pueda llamarla sin condicionales.
Future<void> scrapeDecretosTransito(Session db, dynamic redis,
    {ProgressTracker? tracker}) async {
  await tracker?.stepStart(
      fuente: 'decretos_transito',
      label: 'Decretos tránsito (no implementado)');
  print('[decretos_transito] Stub — fuente ig=269 pendiente de implementación');
  await tracker?.tick();
}
