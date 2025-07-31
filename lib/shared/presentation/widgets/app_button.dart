import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class AppButton extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  final Color? bgColor;
  final Color? textColor;
  final Color? disabledBgColor;
  final TextStyle? textStyle;
  final Widget? icon;
  final double? width;
  final bool? isLoading;
  final double? height;
  final bool isDisabled;
  final bool isElevated;
  final BorderSide? side;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? deleteLoaderColor;

  const AppButton({
    required this.title,
    required this.onPressed,
    this.bgColor,
    this.textColor,
    this.disabledBgColor,
    this.textStyle,
    this.isLoading,
    this.icon,
    this.side,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.deleteLoaderColor,
    this.isDisabled = false,
    this.isElevated = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isDisabled || isLoading == true ? () {} : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: isElevated ? null : 0,
          disabledBackgroundColor:
              disabledBgColor ?? bgColor?.withValues(alpha: .5),
          backgroundColor: bgColor ?? theme.colorScheme.primary,
          surfaceTintColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(30.r),
            side: side ?? BorderSide.none,
          ),
          shadowColor: AppColors.textBlack.withValues(alpha: .1),
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w),
          child: isLoading == true
              ? Center(
                  child: SizedBox(
                    height: 18.h,
                    width: 18.h,
                    child: CircularProgressIndicator(
                        color: deleteLoaderColor ?? AppColors.textWhite),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: textStyle ??
                            theme.textTheme.bodyMedium!.copyWith(
                              color: textColor ?? AppColors.textWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                            ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
