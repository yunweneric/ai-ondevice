import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class AppSizing {
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;
  static double kHPercentage(BuildContext context, double value) => (height(context) * value) / 100;
  static double kWPercentage(BuildContext context, double value) => (width(context) * value) / 100;
  static BorderRadius radiusMd = BorderRadius.circular(10.r);
  static BorderRadius radiusSm = BorderRadius.circular(5.r);

  static OutlineInputBorder mainBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: color),
      borderRadius: BorderRadius.all(Radius.circular(10.r)),
    );
  }

  static OutlineInputBorder mainFocusBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(width: 1, color: AppColors.primary),
      borderRadius: BorderRadius.all(Radius.circular(10.r)),
    );
  }

  static OutlineInputBorder focusedErrorBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(width: 1, color: AppColors.red),
      borderRadius: BorderRadius.all(Radius.circular(10.r)),
    );
  }

  static OutlineInputBorder errorBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(width: 1, color: AppColors.red),
      borderRadius: BorderRadius.all(Radius.circular(10.r)),
    );
  }

  static EdgeInsets kMainPadding(BuildContext context) => EdgeInsets.symmetric(
        // horizontal: isMobile(context) ? 20.w : 30.w,
        horizontal: isMobile(context) ? 20.w : 30.w,
      );

  static EdgeInsets kPadding(double width, double height) =>
      EdgeInsets.symmetric(horizontal: width.w, vertical: height.h);

  static Widget kh20Spacer() => SizedBox(height: 20.h);
  static Widget kh10Spacer() => SizedBox(height: 10.h);

  static Widget khSpacer(double height) => SizedBox(height: height);

  static Widget kwSpacer(double width) => SizedBox(width: width);

  static bool isXMobile(context) => width(context) < 380;
  static bool isMobile(context) => width(context) < 789;
  static bool isTablet(context) => width(context) > 789 && width(context) < 992;
  static bool isDesktop(context) => width(context) > 992;

  static OutlineInputBorder noBorder() {
    return const OutlineInputBorder(borderSide: BorderSide.none);
  }
}
