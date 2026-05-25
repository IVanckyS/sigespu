import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sigespu/src/presentation/shared/app_shell.dart';

GoRouter _makeRouter() => GoRouter(
      initialLocation: '/map',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/map', builder: (_, __) => const SizedBox()),
          ],
        ),
      ],
    );

void main() {
  testWidgets('desktop shows header tabs, no bottom nav', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _makeRouter()),
      ),
    );
    await tester.pumpAndSettle();
    // El shell móvil usa un widget propio (_MobileBottomTabs), no el
    // BottomNavigationBar de Material — se busca por runtimeType al ser privado.
    expect(_findMobileTabs(), findsNothing);
    expect(find.text('Mapa'), findsWidgets);
  });

  testWidgets('mobile shows bottom nav, no header tabs', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: _makeRouter()),
      ),
    );
    await tester.pumpAndSettle();
    expect(_findMobileTabs(), findsOneWidget);
  });
}

/// La barra inferior móvil es un widget privado (`_MobileBottomTabs`); se
/// localiza por nombre de runtimeType ya que no es accesible por tipo.
Finder _findMobileTabs() => find.byWidgetPredicate(
      (w) => w.runtimeType.toString() == '_MobileBottomTabs',
    );
