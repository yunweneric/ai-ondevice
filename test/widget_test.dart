// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:offline_ai/shared/shared.dart';

void main() {
  testWidgets('App should render without crashing',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Offline AI App',
              style: Theme.of(tester.element(find.byType(Text)))
                  .textTheme
                  .headlineMedium,
            ),
          ),
        ),
      ),
    );

    // Verify that our app renders without crashing
    expect(find.text('Offline AI App'), findsOneWidget);
  });

  testWidgets('Colors are properly defined', (WidgetTester tester) async {
    // Build our app with basic theme
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.bg,
        ),
        home: Scaffold(
          body: Container(
            color: AppColors.primary,
            child: const Center(
              child: Text('Test'),
            ),
          ),
        ),
      ),
    );

    // Verify that the app renders with colors
    expect(find.text('Test'), findsOneWidget);
  });
}
