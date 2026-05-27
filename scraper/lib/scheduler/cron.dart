import 'dart:async' show unawaited;
import 'dart:io';
import 'package:cron/cron.dart';
import 'package:postgres/postgres.dart';
import '../sources/patentes_mensuales.dart';
import '../sources/permisos_dom.dart';
import '../sources/decretos_transito.dart';
import '../sources/organizaciones.dart';
import '../geocoder/nominatim_client.dart';

/// Registers scraper cron jobs using the Pool and Command already initialized
/// by the backend. Does not create its own connections.
///
/// If RUN_INITIAL_SCRAPE=true, immediately launches a full scrape in background
/// (useful on first deploy to populate historical data).
void startScraperCron(Pool db, dynamic redis) {
  final cron = Cron();
  final geocoder = NominatimClient();

  if (Platform.environment['RUN_INITIAL_SCRAPE'] == 'true') {
    print('[scraper] RUN_INITIAL_SCRAPE=true — lanzando scrape inicial en background');
    unawaited(_runAllSources(db, redis, geocoder));
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

Future<void> _runAllSources(
    Pool db, dynamic redis, NominatimClient geocoder) async {
  print('[scraper] Iniciando scrape completo de todas las fuentes...');
  await scrapePatentes(db, redis, geocoder);
  await scrapePermisosDom(db, redis, geocoder);
  await scrapeDecretosTransito(db, redis);
  await scrapeOrganizaciones(db, redis, geocoder);
  print('[scraper] Scrape completo finalizado');
}
