import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:offline_ai/shared/shared.dart';

class AppTheme {
  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.urbanist(
      color: AppColors.textBlack,
      fontWeight: FontWeight.w600,
      fontSize: 24.sp,
    ),
    displayMedium: GoogleFonts.urbanist(
      color: AppColors.textBlack,
      fontWeight: FontWeight.w600,
      fontSize: 20.sp,
    ),
    displaySmall: GoogleFonts.urbanist(
      color: AppColors.textBlack,
      fontWeight: FontWeight.w600,
      fontSize: 16.sp,
    ),
    bodyMedium: GoogleFonts.urbanist(
      color: AppColors.textBlack,
      fontSize: 14.sp,
      height: 1.5,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w500,
    ),
    bodySmall: GoogleFonts.urbanist(
      color: AppColors.textGrey,
      fontWeight: FontWeight.w400,
      fontSize: 12.sp,
    ),
    labelMedium: GoogleFonts.urbanist(
      color: AppColors.textGrey,
      fontWeight: FontWeight.w400,
      fontSize: 14.sp,
    ),
    labelSmall: GoogleFonts.urbanist(
      color: AppColors.textGrey,
      fontWeight: FontWeight.w400,
      fontSize: 12.sp,
      letterSpacing: 0,
    ),
  );
  static TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.urbanist(
      color: AppColors.textWhite,
      fontWeight: FontWeight.w600,
      fontSize: 24.sp,
    ),
    displayMedium: GoogleFonts.urbanist(
      color: AppColors.textWhite,
      fontWeight: FontWeight.w600,
      fontSize: 20.sp,
    ),
    displaySmall: GoogleFonts.urbanist(
      color: AppColors.textWhite,
      fontWeight: FontWeight.w600,
      fontSize: 16.sp,
    ),
    bodyMedium: GoogleFonts.urbanist(
      color: AppColors.textWhite,
      fontWeight: FontWeight.normal,
      fontSize: 14.sp,
      height: 1.5.h,
      letterSpacing: 0.1,
    ),
    bodySmall: GoogleFonts.urbanist(
      color: AppColors.textWhite,
      fontWeight: FontWeight.w400,
      fontSize: 12.sp,
    ),
    labelMedium: GoogleFonts.urbanist(
      color: AppColors.textWhite,
      fontWeight: FontWeight.w400,
      fontSize: 14.sp,
    ),
    labelSmall: GoogleFonts.urbanist(
      color: AppColors.textWhite,
      fontWeight: FontWeight.w400,
      fontSize: 12.sp,
      letterSpacing: 0,
    ),
  );

  static InputDecorationTheme lightInputDecoration = InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
    labelStyle: TextStyle(color: AppColors.textGrey, fontSize: 14.sp, fontWeight: FontWeight.w400),
    hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14.sp, fontWeight: FontWeight.w400),
    floatingLabelStyle: TextStyle(color: AppColors.textGrey, fontSize: 12.sp),
    errorStyle: TextStyle(color: AppColors.red, fontSize: 11.sp),
    border: AppSizing.mainBorder(AppColors.bgGray2),
    enabledBorder: AppSizing.mainBorder(AppColors.bgGray2),
    focusedBorder: AppSizing.mainFocusBorder(),
    focusedErrorBorder: AppSizing.focusedErrorBorder(),
    errorBorder: AppSizing.errorBorder(),
    filled: true,
    fillColor: AppColors.bgGray3,
  );

  static InputDecorationTheme darkInputDecoration = InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
    labelStyle: TextStyle(color: AppColors.textGrey, fontSize: 14.sp, fontWeight: FontWeight.w400),
    hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14.sp, fontWeight: FontWeight.w400),
    floatingLabelStyle: TextStyle(color: AppColors.textGrey, fontSize: 12.sp),
    errorStyle: TextStyle(color: AppColors.red, fontSize: 11.sp),
    border: AppSizing.mainBorder(AppColors.bgGray3),
    enabledBorder: AppSizing.mainBorder(AppColors.bgGray3),
    focusedBorder: AppSizing.mainFocusBorder(),
    focusedErrorBorder: AppSizing.focusedErrorBorder(),
    errorBorder: AppSizing.errorBorder(),
  );

  static ThemeData light() {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        error: AppColors.red,
        surface: AppColors.bg,
      ),
      primaryColor: AppColors.primary,
      primaryColorDark: AppColors.textBlack,
      primaryColorLight: AppColors.textWhite,
      scaffoldBackgroundColor: AppColors.bg,
      cardTheme: const CardTheme(color: AppColors.cardColor),
      highlightColor: AppColors.bgGray3,
      cardColor: AppColors.cardColor,
      textTheme: lightTextTheme,
      inputDecorationTheme: lightInputDecoration,
      dividerColor: AppColors.bgGray2,
      bottomAppBarTheme: const BottomAppBarTheme(color: AppColors.bg),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        surfaceTintColor: AppColors.bg,
        titleTextStyle: GoogleFonts.urbanist(color: AppColors.textBlack, fontWeight: FontWeight.w500, fontSize: 20.sp),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(
          color: AppColors.textBlack,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
          textStyle: lightTextTheme.bodySmall,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          textStyle: lightTextTheme.bodySmall,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgGray2,
        side: BorderSide.none,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        selectedColor: AppColors.primary,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        labelStyle: TextStyle(fontSize: 12.sp, color: AppColors.textBlack),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.bgGray2),
      dialogTheme: const DialogTheme(backgroundColor: AppColors.cardColor),
      iconTheme: IconThemeData(color: AppColors.textGrey, size: 20.w),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgDark,
      bottomAppBarTheme: const BottomAppBarTheme(color: AppColors.bgDark),
      primaryColorDark: AppColors.textWhite,
      primaryColorLight: AppColors.textBlack,
      cardColor: AppColors.bgCardDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        error: AppColors.red,
        surface: AppColors.bgDark,
      ),
      cardTheme: const CardTheme(color: AppColors.bgCardDark),
      textTheme: darkTextTheme,
      dividerColor: AppColors.bgGrayDark,
      highlightColor: AppColors.bgCardDark,
      inputDecorationTheme: darkInputDecoration,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        surfaceTintColor: AppColors.bgDark,
        backgroundColor: AppColors.bgDark,
        titleTextStyle: GoogleFonts.urbanist(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w500,
          fontSize: 20.sp,
        ),
        elevation: 20,
      ),
      iconTheme: IconThemeData(color: AppColors.textGrey, size: 20.w),
      primaryIconTheme: IconThemeData(color: AppColors.textGrey, size: 20.w),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgCardDark,
        side: const BorderSide(color: AppColors.bgCardDark, width: 1),
        selectedColor: AppColors.primary,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        labelStyle: TextStyle(fontSize: 12.sp, color: AppColors.textWhite),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.bgGrayDark),
      dialogTheme: const DialogTheme(backgroundColor: AppColors.bgCardDark),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 10.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          textStyle: darkTextTheme.bodySmall,
          iconColor: AppColors.bgGray,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 10.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          backgroundColor: AppColors.primary,
          textStyle: darkTextTheme.bodySmall,
          iconColor: AppColors.bgGray,
        ),
      ),
    );
  }
}
