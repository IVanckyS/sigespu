import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigespu/src/presentation/map/widgets/panel_filtros_izquierdo.dart';

void main() {
  testWidgets('panel renders and collapses', (tester) async {
    // Use a large surface so the ListView does not overflow in tests.
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Row(children: [PanelFiltrosIzquierdo()]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Expanded: find collapse button
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);

    // Tap collapse button
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    // Collapsed: find expand button
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('zonas dibujadas section is visible', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Row(children: [PanelFiltrosIzquierdo()]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll the list so the ZONAS DIBUJADAS block enters the viewport.
    await tester.scrollUntilVisible(
      find.text('ZONAS DIBUJADAS', skipOffstage: false),
      100,
    );
    expect(find.text('ZONAS DIBUJADAS'), findsOneWidget);
  });
}
