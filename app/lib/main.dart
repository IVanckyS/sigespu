import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/config/theme.dart';
import 'src/config/router.dart';
import 'src/data/sync/sync_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SigespuApp(),
    ),
  );
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
