import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:offline_ai/shared/shared.dart';

void main() {
  group('SplashScreen Tests', () {
    testWidgets('SplashScreen should render robot SVG and animations', (WidgetTester tester) async {
      // Build the splash screen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.bg,
          ),
          home: const SplashScreen(),
        ),
      );

      // Wait for the initial frame
      await tester.pump();

      // Verify that the splash screen renders without crashing
      expect(find.byType(SplashScreen), findsOneWidget);

      // Verify that the robot SVG is present
      expect(find.byType(SvgPicture), findsOneWidget);

      // Wait for animations to start
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that the ripple effect container is present
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));

      // Verify that the fade transition is present
      expect(find.byType(FadeTransition), findsOneWidget);

      // Wait a short time to let animations progress
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('SplashScreen should have proper animations', (WidgetTester tester) async {
      // Build the splash screen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.bg,
          ),
          home: const SplashScreen(),
        ),
      );

      // Wait for initial frame
      await tester.pump();

      // Wait for fade animation to complete
      await tester.pump(const Duration(milliseconds: 800));

      // Verify that the robot SVG is visible after fade animation
      expect(find.byType(SvgPicture), findsOneWidget);

      // Wait for ripple animation to progress
      await tester.pump(const Duration(milliseconds: 500));

      // Verify that ripple effect is still present
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));

      // Wait a short time to let animations progress
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
