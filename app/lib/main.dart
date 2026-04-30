import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/config/theme.dart';
import 'src/config/router.dart';

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

    return MaterialApp.router(
      title: 'SIGESPU Lota',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
