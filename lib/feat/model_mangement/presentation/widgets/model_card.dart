import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

class ModelCard extends StatelessWidget {
  final AiModel model;
  final bool isSelected;
  final VoidCallback? onTap;

  const ModelCard({
    super.key,
    required this.model,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: 0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: theme.cardColor,
        ),
        child: Row(
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

            AppSizing.kwSpacer(15.w),

            // Model Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: theme.textTheme.displaySmall,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${model.modelType} • ${model.modelSize}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Radio Button
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor, width: 1),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
