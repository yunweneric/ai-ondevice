import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class ChatMessage extends StatelessWidget {
  final String message;
  final String timestamp;
  final bool isFromUser;

  const ChatMessage({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isFromUser,
  });

  @override
  Widget build(BuildContext context) {
    return isFromUser ? _buildUserMessage(context) : _buildAIMessage(context);
  }

  Widget _buildAIMessage(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Avatar
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.smart_toy,
            color: Colors.white,
            size: 16.w,
          ),
        ),

        AppSizing.kwSpacer(12.w),

        // Message Bubble
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: theme.cardColor, width: 1),
                ),
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                timestamp,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessage(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Message Bubble
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(timestamp, style: theme.textTheme.bodySmall),
            ],
          ),
        ),

        AppSizing.kwSpacer(12.w),

        // User Avatar
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: theme.primaryColorDark,
            size: 16.w,
          ),
        ),
      ],
    );
  }
} 