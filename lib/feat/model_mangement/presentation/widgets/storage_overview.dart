import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class StorageOverview extends StatelessWidget {
  const StorageOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LangUtil.trans("storage.storage_overview"),
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSizing.kh10Spacer(),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: theme.dividerColor ?? Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LangUtil.trans("models.title"),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSizing.kh10Spacer(),

              // Progress Bar
              Container(
                height: 8.h,
                decoration: BoxDecoration(
                  color: theme.dividerColor ?? Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.23, // 23% used
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.purple,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),

              AppSizing.khSpacer(8.h),

              // Storage Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LangUtil.trans("storage.gb_used", args: {"used": "7.5"}) + ' / ' + LangUtil.trans("storage.gb_total", args: {"total": "32"}),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '23% ' + LangUtil.trans("storage.used_storage"),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              AppSizing.khSpacer(4.h),

              Text(
                '77% ' + LangUtil.trans("storage.available_storage"),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
