import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

class ChatHeader extends StatelessWidget {
  final DownloadInfo? selectedModel;
  final VoidCallback? onRefresh;
  final VoidCallback? onChangeModel;

  const ChatHeader({
    super.key,
    this.selectedModel,
    this.onRefresh,
    this.onChangeModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSizing.kMainPadding(context).copyWith(
        top: 16.h,
        bottom: 16.h,
      ),
      child: Row(
        children: [
          // AI Icon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 20.w,
            ),
          ),

          AppSizing.kwSpacer(12.w),

          // Title and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LangUtil.trans("chat.title"),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      selectedModel?.model.name ?? 'No Model Selected',
                      style: theme.textTheme.bodyMedium,
                    ),
                    AppSizing.kwSpacer(8.w),
                    if (selectedModel != null) ...[
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration:
                            const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                      ),
                      AppSizing.kwSpacer(4.w),
                      Text(
                        LangUtil.trans("onboarding.offline"),
                        style: theme.textTheme.bodySmall,
                      ),
                    ] else ...[
                      Text(
                        'Select a model to start',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Action Icons
          Row(
            children: [
              if (selectedModel != null) ...[
                IconButton(
                  onPressed: onRefresh,
                  icon: Icon(
                    Icons.refresh,
                    color: AppColors.textGrey,
                    size: 20.w,
                  ),
                ),
                IconButton(
                  onPressed: onChangeModel,
                  icon: Icon(
                    Icons.swap_horiz,
                    color: AppColors.textGrey,
                    size: 20.w,
                  ),
                ),
              ],
              IconButton(
                onPressed: () =>
                    getIt.get<BottomNavBarBloc>().add(UpdateNavbarIndexEvent(newIndex: 3)),
                icon: Icon(
                  Icons.settings,
                  color: AppColors.textGrey,
                  size: 20.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
