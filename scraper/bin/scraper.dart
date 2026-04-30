import '../lib/scheduler/cron.dart' as scheduler;

void main() async {
  print('Iniciando SIGESPU Scraper Worker...');
  await scheduler.startCron();
}
