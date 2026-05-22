import 'dart:io';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

final _log = Logger('Migrator');

// ID arbitrario para el advisory lock de Postgres.
// Garantiza que solo un proceso aplica migraciones a la vez.
const _lockId = 12345;

Future<void> runMigrations(Pool db) async {
  final lockResult = await db.execute(
    'SELECT pg_try_advisory_lock($_lockId)',
  );
  final locked = lockResult.first[0] as bool;

  if (!locked) {
    _log.info('Otro proceso está ejecutando migraciones. Esperando 5s...');
    await Future.delayed(const Duration(seconds: 5));
    return;
  }

  try {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version TEXT PRIMARY KEY,
        applied_at TIMESTAMPTZ DEFAULT NOW()
      )
    ''');

    final appliedRows = await db.execute(
      'SELECT version FROM schema_migrations',
    );
    final applied = appliedRows.map((r) => r[0] as String).toSet();

    // /app/migrations in Docker, fall back to backend/migrations for local dev
    final migrationsDir = Directory('/app/migrations').existsSync()
        ? Directory('/app/migrations')
        : Directory('migrations');
    if (!migrationsDir.existsSync()) {
      _log.warning('Directorio de migraciones no encontrado. Sin migraciones.');
      return;
    }

    final files = migrationsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.sql'))
        .toList()
      ..sort((a, b) =>
          a.uri.pathSegments.last.compareTo(b.uri.pathSegments.last));

    for (final file in files) {
      final version = file.uri.pathSegments.last;
      if (applied.contains(version)) {
        _log.fine('$version ya aplicada, omitiendo');
        continue;
      }

      _log.info('Aplicando migración $version...');
      final sql = await file.readAsString();

      await db.runTx((tx) async {
        // Strip comment lines first, then split on semicolons.
        // Filtering whole blocks by leading '--' would silently skip
        // CREATE statements that appear after a file-header comment.
        final stripped = sql
            .split('\n')
            .where((line) => !line.trimLeft().startsWith('--'))
            .join('\n');
        final stmts = stripped
            .split(';')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        for (final stmt in stmts) {
          await tx.execute(stmt);
        }
        await tx.execute(
          Sql.named(
              'INSERT INTO schema_migrations (version) VALUES (@v)'),
          parameters: {'v': version},
        );
      });

      _log.info('Migración $version aplicada');
    }
  } finally {
    await db.execute('SELECT pg_advisory_unlock($_lockId)');
  }
}
