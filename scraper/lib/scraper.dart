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
import 'sources/patentes_mensuales.dart';
import 'sources/permisos_dom.dart';

export 'progress.dart';

/// Corre las 4 fuentes en su modo "actual" (período vigente).
/// Pensado para uso bajo demanda desde el backend.
Future<void> runScrapingActual({
  required Connection db,
  required Command redis,
}) async {
  if (await ProgressTracker.isRunning(redis)) {
    throw StateError('Ya hay un scraping en curso');
  }

  // 4 pasos: patentes, permisos, transito, organizaciones
  final tracker = ProgressTracker(redis, modo: 'actual', totalSteps: 4);
  await tracker.start();
  final geocoder = NominatimClient();

  try {
    await scrapePatentes(db, redis, geocoder, tracker: tracker);
    await scrapePermisosDom(db, redis, geocoder, tracker: tracker);
    await scrapeDecretosTransito(db, redis, tracker: tracker);
    await scrapeOrganizaciones(db, redis, geocoder, tracker: tracker);
    await tracker.finish();
  } catch (e, st) {
    print('[scraper] Error en runScrapingActual: $e\n$st');
    await tracker.finish(error: e.toString());
    rethrow;
  }
}

/// Corre las fuentes en modo histórico (iterando años).
///
/// Por defecto desde 2022 para patentes (cuando empezó la publicación regular)
/// y desde 2020 para organizaciones. Permisos DOM toma todos los meses
/// disponibles en el índice.
Future<void> runScrapingHistorico({
  required Connection db,
  required Command redis,
  int patentesYearFrom = 2022,
  int organizacionesYearFrom = 2020,
}) async {
  if (await ProgressTracker.isRunning(redis)) {
    throw StateError('Ya hay un scraping en curso');
  }

  final now = DateTime.now();
  final yearTo = now.year;
  final lastSem = now.month <= 6 ? 1 : 2;

  // Calcular pasos totales para que la barra de progreso sea precisa
  final patentesSteps = ((yearTo - patentesYearFrom) * 2) + lastSem;
  final orgsSteps = yearTo - organizacionesYearFrom + 1;
  final totalSteps = patentesSteps + 1 /*permisos*/ + 1 /*transito*/ + orgsSteps;

  final tracker = ProgressTracker(redis, modo: 'historico', totalSteps: totalSteps);
  await tracker.start();
  final geocoder = NominatimClient();

  try {
    await scrapePatentesHistorico(db, redis, geocoder,
        yearFrom: patentesYearFrom, tracker: tracker);
    await scrapePermisosDom(db, redis, geocoder,
        maxMonths: null /* todos */, tracker: tracker);
    await scrapeDecretosTransito(db, redis, tracker: tracker);
    await scrapeOrganizacionesHistorico(db, redis, geocoder,
        yearFrom: organizacionesYearFrom, tracker: tracker);
    await tracker.finish();
  } catch (e, st) {
    print('[scraper] Error en runScrapingHistorico: $e\n$st');
    await tracker.finish(error: e.toString());
    rethrow;
  }
}
