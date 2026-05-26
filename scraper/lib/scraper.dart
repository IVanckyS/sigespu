/// API pública del scraper SIGESPU.
///
/// Esta capa expone funciones de alto nivel para ejecutar scraping bajo demanda
/// (no por cron). El backend la importa para servir los endpoints
/// `POST /api/scraping/run` y `POST /api/scraping/historico`.
library scraper;

import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

import 'geocoder/nominatim_client.dart';
import 'progress.dart';
import 'sources/decretos_transito.dart';
import 'sources/organizaciones.dart';
import 'sources/patentes_ig164.dart';
import 'sources/patentes_mensuales.dart';
import 'sources/permisos_dom.dart';

export 'progress.dart';

/// Corre las 4 fuentes en su modo "actual" (período vigente).
/// Pensado para uso bajo demanda desde el backend.
Future<void> runScrapingActual({
  required Session db,
  required Command redis,
}) async {
  if (await ProgressTracker.isRunning(redis)) {
    throw StateError('Ya hay un scraping en curso');
  }
  // Limpia cualquier flag de cancel previo para no abortar al instante.
  await ProgressTracker.clearCancel(redis);

  // 5 pasos: patentes ig=103, patentes ig=164, permisos, transito, organizaciones
  final tracker = ProgressTracker(redis, modo: 'actual', totalSteps: 5);
  await tracker.start();
  final geocoder = NominatimClient();

  try {
    await scrapePatentes(db, redis, geocoder, tracker: tracker);
    await ProgressTracker.throwIfCancelled(redis);
    await scrapePatentesIg164(db, redis, tracker: tracker);
    await ProgressTracker.throwIfCancelled(redis);
    await scrapePermisosDom(db, redis, geocoder, tracker: tracker);
    await ProgressTracker.throwIfCancelled(redis);
    await scrapeDecretosTransito(db, redis, tracker: tracker);
    await ProgressTracker.throwIfCancelled(redis);
    await scrapeOrganizaciones(db, redis, geocoder, tracker: tracker);
    await tracker.finish();
  } on ScrapingCancelledException {
    print('[scraper] runScrapingActual cancelado por usuario');
    try { await tracker.finish(error: 'Cancelado por usuario'); } catch (_) {}
  } catch (e, st) {
    print('[scraper] Error en runScrapingActual: $e\n$st');
    try { await tracker.finish(error: e.toString()); } catch (_) {}
    rethrow;
  } finally {
    try { await ProgressTracker.clearCancel(redis); } catch (_) {}
  }
}

/// Corre las fuentes en modo histórico (iterando años).
///
/// Por defecto desde 2022 para patentes (cuando empezó la publicación regular)
/// y desde 2020 para organizaciones. Permisos DOM toma todos los meses
/// disponibles en el índice.
Future<void> runScrapingHistorico({
  required Session db,
  required Command redis,
  int patentesYearFrom = 2022,
  int organizacionesYearFrom = 2020,
}) async {
  if (await ProgressTracker.isRunning(redis)) {
    throw StateError('Ya hay un scraping en curso');
  }
  await ProgressTracker.clearCancel(redis);

  final now = DateTime.now();
  final yearTo = now.year;
  final lastSem = now.month <= 6 ? 1 : 2;

  // Calcular pasos totales para que la barra de progreso sea precisa
  final patentesSteps = ((yearTo - patentesYearFrom) * 2) + lastSem;
  final patentesIg164Steps = yearTo - patentesYearFrom + 1;
  final orgsSteps = yearTo - organizacionesYearFrom + 1;
  final totalSteps = patentesSteps + patentesIg164Steps + 1 /*permisos*/ + 1 /*transito*/ + orgsSteps;

  final tracker = ProgressTracker(redis, modo: 'historico', totalSteps: totalSteps);
  await tracker.start();
  final geocoder = NominatimClient();

  try {
    await scrapePatentesHistorico(db, redis, geocoder,
        yearFrom: patentesYearFrom, tracker: tracker);
    await ProgressTracker.throwIfCancelled(redis);
    await scrapePatentesIg164Historico(db, redis,
        yearFrom: patentesYearFrom, tracker: tracker);
    await ProgressTracker.throwIfCancelled(redis);
    await scrapePermisosDom(db, redis, geocoder,
        maxMonths: null /* todos */, tracker: tracker);
    await ProgressTracker.throwIfCancelled(redis);
    await scrapeDecretosTransito(db, redis, tracker: tracker);
    await ProgressTracker.throwIfCancelled(redis);
    await scrapeOrganizacionesHistorico(db, redis, geocoder,
        yearFrom: organizacionesYearFrom, tracker: tracker);
    await tracker.finish();
  } on ScrapingCancelledException {
    print('[scraper] runScrapingHistorico cancelado por usuario');
    try { await tracker.finish(error: 'Cancelado por usuario'); } catch (_) {}
  } catch (e, st) {
    print('[scraper] Error en runScrapingHistorico: $e\n$st');
    try { await tracker.finish(error: e.toString()); } catch (_) {}
    rethrow;
  } finally {
    try { await ProgressTracker.clearCancel(redis); } catch (_) {}
  }
}
