import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class OnboardHeader extends StatelessWidget {
  const OnboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        AppSizing.kh20Spacer(),

        // Main Illustration
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(20.w),
          child: AppIcon(icon: AppIcons.download, size: 20.w, color: theme.primaryColor),
        ),

        AppSizing.kh20Spacer(),

        // Main Heading
        Text(
          LangUtil.trans("onboarding.download_first_model"),
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        AppSizing.kh10Spacer(),

        // Description
        Text(
          LangUtil.trans("onboarding.choose_model_description"),
          style: theme.textTheme.labelMedium,
          textAlign: TextAlign.center,
        ),

        AppSizing.kh20Spacer(),
      ],
    );
  }
}
