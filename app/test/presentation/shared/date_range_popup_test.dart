import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigespu/src/presentation/shared/date_range_popup.dart';

void main() {
  testWidgets('DateRangePopup shows Desde and Hasta tabs plus action buttons',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DateRangePopup(
          onApply: (_, __) {},
          onDismiss: () {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Desde'), findsOneWidget);
    expect(find.text('Hasta'), findsOneWidget);
    expect(find.text('Aplicar'), findsOneWidget);
    expect(find.text('Limpiar'), findsOneWidget);
  });
}
