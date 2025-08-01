import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class HistoryTopBar extends StatelessWidget {
  const HistoryTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: theme.primaryColorDark,
              size: 24.w,
            ),
          ),
          AppSizing.kwSpacer(12.w),
          Text(
            LangUtil.trans("chat.chat_history"),
            style: theme.textTheme.displayMedium,
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // Handle search
            },
            icon: Icon(
              Icons.search,
              color: theme.primaryColorDark,
              size: 24.w,
            ),
          ),
          AppSizing.kwSpacer(8.w),
          IconButton(
            onPressed: () {
              // Handle settings
            },
            icon: Icon(
              Icons.settings,
              color: theme.primaryColorDark,
              size: 24.w,
            ),
          ),
        ],
      ),
    );
  }
}
