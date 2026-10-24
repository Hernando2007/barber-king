import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barber_king_app/core/theme.dart';
import 'package:barber_king_app/widgets/common/app_ui.dart';

void main() {
  testWidgets('AppCard renders its content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: AppCard(child: Text('Barber King')),
        ),
      ),
    );

    expect(find.text('Barber King'), findsOneWidget);
  });

  testWidgets('PrimaryGradientButton triggers its action', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: PrimaryGradientButton(
            label: 'Reservar',
            onPressed: () => taps++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Reservar'));
    expect(taps, 1);
  });
}
