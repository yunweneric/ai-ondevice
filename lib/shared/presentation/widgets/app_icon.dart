import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class AppIcon extends StatelessWidget {
  final String icon;
  final double? size;
  final Color? color;
  final bool? shouldColor;
  final bool? isString;
  const AppIcon({
    super.key,
    required this.icon,
    this.color,
    this.size,
    this.shouldColor,
    this.isString = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isString == true) {
      return SvgPicture.string(
        icon,
        width: size ?? 25.w,
        height: size ?? 25.w,
        color: shouldColor == true ? color ?? Theme.of(context).primaryColorDark : null,
        placeholderBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      );
    }
    return SvgPicture.asset(
      icon,
      width: size ?? 25.w,
      height: size ?? 25.w,
      color: shouldColor == true ? color ?? Theme.of(context).primaryColorDark : null,
      placeholderBuilder: (context) {
        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }
}
