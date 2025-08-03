import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class AppLoader extends StatelessWidget {
  final double? size;
  final Color? color;
  const AppLoader({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator.adaptive(
        backgroundColor: color ?? AppColors.textWhite,
        strokeWidth: 2.w,
      ),
    );
  }
}
