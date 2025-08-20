import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

class DownloadedModelCard extends StatelessWidget {
  final DownloadInfo model;
  final bool isActive;

  const DownloadedModelCard({super.key, required this.model, this.isActive = false});

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
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Model Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.smart_toy,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            model.model.name,
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isActive) ...[
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
                      ],
                    ),
                    AppSizing.khSpacer(4.h),
                    Text(
                      '${model.model.modelType} • ${model.model.size}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizing.khSpacer(4.h),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          LangUtil.trans("models.downloaded"),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSizing.khSpacer(16.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  size: AppButtonSize.small,
                  title: LangUtil.trans(isActive ? "common.selected" : "common.select"),
                  onPressed: () {
                    AppLogger.i('model: ${model.model.name}');
                  },
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16.w,
                  ),
                ),
              ),
              AppSizing.kwSpacer(12.w),
              Expanded(
                child: AppButton(
                  type: AppButtonType.dangerGhost,
                  size: AppButtonSize.small,
                  title: LangUtil.trans("models.remove_model"),
                  onPressed: () {
                    AppSheet.showActionSheet(
                      title: LangUtil.trans("common.delete_model"),
                      context: context,
                      description: LangUtil.trans("common.delete_model_description"),
                      onApprove: () {
                        final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
                        modelDownloaderBloc.add(DeleteDownloadEvent(model.model));
                        context.pop();
                      },
                      onReject: context.pop,
                      approveText: LangUtil.trans("common.delete"),
                      rejectText: LangUtil.trans("common.cancel"),
                    );
                  },
                  icon: AppIcon(
                    icon: AppIcons.trash,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),

          // Download Info
          if (model.completedTime != null) ...[
            AppSizing.khSpacer(12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_done,
                  color: Colors.green,
                  size: 14.w,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${LangUtil.trans("models.completed")}: ${_formatTime(model.completedTime!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Format DateTime to readable string
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return LangUtil.trans("common.just_now");
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${LangUtil.trans("common.minutes_ago")}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}${LangUtil.trans("common.hours_ago")}';
    } else {
      return '${difference.inDays}${LangUtil.trans("common.days_ago")}';
    }
  }
}
