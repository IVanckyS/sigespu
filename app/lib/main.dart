import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'src/config/theme.dart';
import 'src/config/router.dart';
import 'src/data/sync/sync_provider.dart';

/// Configura el logger global. Reglas:
/// - **Debug**: nivel ALL, salida vía `debugPrint` con formato compacto.
/// - **Release**: solo WARNING+ (errores reales) — los INFO se descartan para
///   no llenar la consola del navegador con tráfico interno.
///
/// Cada componente obtiene su propio `Logger('NombreComponente')`; los logs
/// quedan etiquetados y se pueden filtrar fácilmente.
void _setupLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  Logger.root.onRecord.listen((r) {
    final ts = '${r.time.hour.toString().padLeft(2, '0')}:'
        '${r.time.minute.toString().padLeft(2, '0')}:'
        '${r.time.second.toString().padLeft(2, '0')}';
    final tag = r.loggerName.isEmpty ? '-' : r.loggerName;
    debugPrint('$ts [${r.level.name}] $tag: ${r.message}');
    if (r.error != null) debugPrint('  error: ${r.error}');
    if (r.stackTrace != null && r.level >= Level.SEVERE) {
      debugPrint(r.stackTrace.toString());
    }
  });
}

// Pantalla de diagnóstico temporal — muestra el error en pantalla sin ADB.
// TODO: eliminar cuando se confirme la causa del crash.
void _showCrashScreen(Object error, StackTrace? stack) {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFFFF3CD),
      appBar: AppBar(
        title: const Text('SIGESPU — Error de inicio'),
        backgroundColor: const Color(0xFFEA580C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SelectableText(
          'ERROR:\n$error\n\nSTACK:\n$stack',
          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
        ),
      ),
    ),
  ));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupLogging();

  FlutterError.onError = (FlutterErrorDetails details) {
    _showCrashScreen(details.exception, details.stack);
  };

  await runZonedGuarded(() async {
    runApp(const ProviderScope(child: SigespuApp()));
  }, _showCrashScreen);
}

class SigespuApp extends ConsumerWidget {
  const SigespuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Inicializar SyncService para que escuche cambios de conectividad
    ref.watch(syncServiceProvider);

    return MaterialApp.router(
      title: 'SIGESPU Lota',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'CL'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'CL'),
        Locale('en'),
      ],
    );
  }
}
