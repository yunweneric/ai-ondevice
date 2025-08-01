import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class ChatEntryCard extends StatelessWidget {
  final ChatEntry entry;

  const ChatEntryCard({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          // AI Model Icon
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: entry.iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(entry.icon, color: Colors.white, size: 24.w),
          ),

          AppSizing.kwSpacer(12.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.modelName,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      entry.timestamp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                AppSizing.khSpacer(8.h),
                Text(
                  entry.previewText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSizing.khSpacer(8.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${entry.messageCount} ' + LangUtil.trans("chat.messages"),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.primaryColor,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    AppSizing.kwSpacer(8.w),
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSizing.kwSpacer(4.w),
                    Text(
                      LangUtil.trans("onboarding.offline"),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatEntry {
  final String modelName;
  final String timestamp;
  final String previewText;
  final int messageCount;
  final IconData icon;
  final Color iconColor;

  const ChatEntry({
    required this.modelName,
    required this.timestamp,
    required this.previewText,
    required this.messageCount,
    required this.icon,
    required this.iconColor,
  });
}
