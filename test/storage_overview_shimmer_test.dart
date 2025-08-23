import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:offline_ai/shared/presentation/widgets/storage_overview_shimmer.dart';

void main() {
  group('StorageOverviewShimmer', () {
    testWidgets('should render shimmer effect', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              home: Scaffold(
                body: Container(
                  padding: const EdgeInsets.all(16),
                  child: const StorageOverviewShimmer(),
                ),
              ),
            );
          },
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.byType(StorageOverviewShimmer), findsOneWidget);
      expect(find.byType(Shimmer), findsOneWidget);

      // Verify shimmer containers are present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should have correct layout structure', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              home: Scaffold(
                body: Container(
                  padding: const EdgeInsets.all(16),
                  child: const StorageOverviewShimmer(),
                ),
              ),
            );
          },
        ),
      );

      // Act
      await tester.pump();

      // Assert
      // Should have a Column as the main layout
      expect(find.byType(Column), findsOneWidget);

      // Should have a Row for the storage details
      expect(find.byType(Row), findsOneWidget);
    });
  });
}
