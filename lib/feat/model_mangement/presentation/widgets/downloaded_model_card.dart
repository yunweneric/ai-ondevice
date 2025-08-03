import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class DownloadedModelCard extends StatelessWidget {
  final DownloadedModel model;

  const DownloadedModelCard({
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
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Model Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(color: model.iconColor, shape: BoxShape.circle),
                child: Icon(model.icon, color: Colors.white, size: 24.w),
              ),

              AppSizing.kwSpacer(12.w),

              // Model Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            model.name,
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (model.isActive)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              LangUtil.trans("common.active"),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.green,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                      ],
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
            ],
          ),

          AppSizing.khSpacer(12.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  size: AppButtonSize.small,
                  title: LangUtil.trans("common.select"),
                  onPressed: () {},
                  icon: Icon(Icons.check, color: Colors.white, size: 16.w),
                ),
              ),
              AppSizing.kwSpacer(12.w),
              Expanded(
                child: AppButton(
                  type: AppButtonType.dangerGhost,
                  size: AppButtonSize.small,
                  title: LangUtil.trans("models.remove_model"),
                  onPressed: () {},
                  icon: AppIcon(icon: AppIcons.trash, color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DownloadedModel {
  final String name;
  final String description;
  final String details;
  final IconData icon;
  final Color iconColor;
  final bool isActive;
  final bool isSelected;

  const DownloadedModel({
    required this.name,
    required this.description,
    required this.details,
    required this.icon,
    required this.iconColor,
    required this.isActive,
    required this.isSelected,
  });
}
