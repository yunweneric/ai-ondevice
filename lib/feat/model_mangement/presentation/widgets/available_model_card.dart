import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class AvailableModelCard extends StatelessWidget {
  final AvailableModel model;

  const AvailableModelCard({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.dividerColor ?? Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Model Icon
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: model.iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              model.icon,
              color: Colors.white,
              size: 24.w,
            ),
          ),

          AppSizing.kwSpacer(12.w),

          // Model Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSizing.khSpacer(4.h),
                Text(
                  model.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                  ),
                ),
                AppSizing.khSpacer(4.h),
                Text(
                  model.details,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          AppSizing.kwSpacer(12.w),

          Expanded(
            child: AppButton(
              size: AppButtonSize.small,
              title: LangUtil.trans("models.download_model"),
              onPressed: () {},
              icon: Icon(Icons.download, color: Colors.white, size: 16.w),
            ),
          ),
        ],
      ),
    );
  }
}

class AvailableModel {
  final String name;
  final String description;
  final String details;
  final IconData icon;
  final Color iconColor;

  const AvailableModel({
    required this.name,
    required this.description,
    required this.details,
    required this.icon,
    required this.iconColor,
  });
}
