import 'dart:async' show unawaited;
import 'dart:io';
import 'package:cron/cron.dart';
import 'package:postgres/postgres.dart';
import '../scraper.dart'; // runScrapingActual, ProgressTracker
import '../sources/patentes_mensuales.dart';
import '../sources/permisos_dom.dart';
import '../sources/decretos_transito.dart';
import '../sources/organizaciones.dart';
import '../geocoder/nominatim_client.dart';

/// Registers scraper cron jobs using the Pool and Command already initialized
/// by the backend. Does not create its own connections.
///
/// If RUN_INITIAL_SCRAPE=true, immediately launches a full tracked scrape in
/// background — skipped if another scrape is already running (safe on restarts).
void startScraperCron(Pool db, dynamic redis) {
  final cron = Cron();
  final geocoder = NominatimClient();

  if (Platform.environment['RUN_INITIAL_SCRAPE'] == 'true') {
    print('[scraper] RUN_INITIAL_SCRAPE=true — lanzando scrape inicial en background');
    unawaited(_runAllSources(db, redis));
  }

  cron.schedule(Schedule.parse('0 3 * * *'), () async {
    print('[scraper] Cron 03:00 — scrapePatentes');
    await scrapePatentes(db, redis, geocoder);
  });

  cron.schedule(Schedule.parse('10 3 * * *'), () async {
    print('[scraper] Cron 03:10 — scrapePermisosDom');
    await scrapePermisosDom(db, redis, geocoder);
  });

  cron.schedule(Schedule.parse('20 3 * * *'), () async {
    print('[scraper] Cron 03:20 — scrapeDecretosTransito');
    await scrapeDecretosTransito(db, redis);
  });

  cron.schedule(Schedule.parse('0 4 * * 0'), () async {
    print('[scraper] Cron domingo 04:00 — scrapeOrganizaciones');
    await scrapeOrganizaciones(db, redis, geocoder);
  });

  print('[scraper] Cron scheduler iniciado');
}

Future<void> _runAllSources(Pool db, dynamic redis) async {
  if (await ProgressTracker.isRunning(redis)) {
    print('[cron] _runAllSources: scraping ya en curso — omitiendo RUN_INITIAL_SCRAPE');
    return;
  }
  print('[scraper] Iniciando scrape completo (tracked)...');
  try {
    await runScrapingActual(db: db, redis: redis);
    print('[scraper] Scrape completo finalizado');
  } catch (e) {
    print('[cron] _runAllSources error: $e');
  }
}
