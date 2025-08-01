import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

class ModelCard extends StatelessWidget {
  final AiModel model;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDownloading;
  final bool isDownloaded;
  final bool isFailed;
  final double? downloadProgress;
  final double? downloadSpeed;
  final String? downloadError;
  final int? downloadedBytes;

  const ModelCard({
    super.key,
    required this.model,
    this.isSelected = false,
    this.onTap,
    this.isDownloading = false,
    this.isDownloaded = false,
    this.isFailed = false,
    this.downloadProgress,
    this.downloadSpeed,
    this.downloadError,
    this.downloadedBytes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border:
              Border.all(color: isSelected ? theme.primaryColor.withValues(alpha: 0.5) : theme.dividerColor, width: 1),
          borderRadius: BorderRadius.circular(12.r),
          color: theme.cardColor,
        ),
        curve: Curves.easeInOut,
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
              padding: EdgeInsets.all(8.w),
              child: AppIcon(
                icon: AppIcons.robotHead,
                size: 20.w,
                color: AppColors.textWhite,
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
                    '${model.modelType} • ${downloadedBytes != null ? "${UtilHelper.formatBytes(downloadedBytes!)}/" : ''}${model.modelSize}',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (isDownloading && downloadProgress != null) ...[
                    SizedBox(height: 8.h),
                    LinearProgressIndicator(
                      value: downloadProgress,
                      backgroundColor: theme.dividerColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(downloadProgress! * 100).toInt()}% Downloaded',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${UtilHelper.formatFile(downloadSpeed?.toInt() ?? 0)}/S',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isDownloaded) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Downloaded',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isFailed) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Download Failed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
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
