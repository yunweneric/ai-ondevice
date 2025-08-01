import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

enum AppButtonSize {
  small,
  medium,
  large,
}

enum AppButtonType {
  primary,
  secondary,
  outline,
  ghost,
  danger,
  dangerOutline,
  dangerGhost,
}

enum IconAlignment {
  left,
  right,
}

class AppButton extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  final Color? disabledBgColor;
  final TextStyle? textStyle;
  final Widget? icon;
  final double? width;
  final bool? isLoading;
  final double? height;
  final bool isDisabled;
  final bool isElevated;
  final EdgeInsetsGeometry? padding;
  final Color? deleteLoaderColor;
  final AppButtonSize? size;
  final AppButtonType? type;
  final IconAlignment? iconAlignment;
  const AppButton({
    required this.title,
    required this.onPressed,
    this.disabledBgColor,
    this.textStyle,
    this.isLoading,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.deleteLoaderColor,
    this.isDisabled = false,
    this.isElevated = true,
    this.size,
    this.type,
    this.iconAlignment,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizeProps = switch (size) {
      AppButtonSize.small => AppButtonSizeProps(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          borderRadius: BorderRadius.circular(8.r),
          fontSize: 12.sp,
        ),
      AppButtonSize.medium => AppButtonSizeProps(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
        ),
      AppButtonSize.large => AppButtonSizeProps(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
        ),
      _ => AppButtonSizeProps(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
        ),
    };
    final typeProps = switch (type) {
      AppButtonType.primary => AppButtonTypeProps(
          bgColor: theme.primaryColor,
          textColor: AppColors.textWhite,
        ),
      AppButtonType.danger => AppButtonTypeProps(
          bgColor: theme.colorScheme.error,
          textColor: AppColors.textWhite,
        ),
      AppButtonType.secondary => AppButtonTypeProps(
          bgColor: theme.colorScheme.secondary,
          textColor: AppColors.textWhite,
        ),
      AppButtonType.outline => AppButtonTypeProps(
          bgColor: Colors.transparent,
          textColor: theme.primaryColor,
          borderColor: theme.primaryColor,
        ),
      AppButtonType.ghost => AppButtonTypeProps(
          bgColor: Colors.transparent,
          textColor: theme.primaryColor,
        ),
      AppButtonType.dangerGhost => AppButtonTypeProps(
          bgColor: theme.colorScheme.error.withValues(alpha: .1),
          textColor: theme.colorScheme.error,
        ),
      _ => AppButtonTypeProps(
          bgColor: theme.primaryColor,
          textColor: AppColors.textWhite,
        ),
    };
    return ElevatedButton.icon(
      onPressed: isDisabled || isLoading == true ? () {} : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: isElevated ? null : 0,
        minimumSize: Size(AppSizing.width(context), 36.h),
        disabledBackgroundColor: disabledBgColor ?? typeProps.bgColor?.withValues(alpha: .5),
        backgroundColor: typeProps.bgColor ?? theme.colorScheme.primary,
        surfaceTintColor: typeProps.bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: sizeProps.borderRadius ?? BorderRadius.circular(12.r),
          side: BorderSide(
            color: typeProps.borderColor ?? Colors.transparent,
            width: 1,
          ),
        ),
        shadowColor: AppColors.textBlack.withValues(alpha: .1),
        padding: sizeProps.padding,
      ),
      icon: icon,
      label: Text(
        title,
        textAlign: TextAlign.center,
        style: textStyle ??
            theme.textTheme.bodyMedium!.copyWith(
              color: typeProps.textColor ?? AppColors.textWhite,
              fontWeight: FontWeight.w600,
              fontSize: sizeProps.fontSize ?? 15.sp,
            ),
      ),
    );
  }
}

class AppButtonSizeProps {
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;
  final double? height;
  final double? fontSize;
  const AppButtonSizeProps({
    required this.padding,
    this.borderRadius,
    this.height,
    this.fontSize,
  });
}

class AppButtonTypeProps {
  final Color? bgColor;
  final Color? textColor;
  final Color? borderColor;
  const AppButtonTypeProps({
    this.bgColor,
    this.textColor,
    this.borderColor,
  });
}
