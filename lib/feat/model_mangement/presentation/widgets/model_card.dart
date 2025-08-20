import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

class ModelCard extends StatelessWidget {
  final AiModel model;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onPause;
  final VoidCallback? onDelete;
  final DownloadInfo? downloadInfo;

  const ModelCard({
    super.key,
    required this.model,
    this.isSelected = false,
    this.onTap,
    this.onPause,
    this.onDelete,
    this.downloadInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppLogger.i('downloadProgress: ${downloadInfo?.progress}');
    AppLogger.i('isDownloading: ${downloadInfo?.isDownloading}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(
                  color:
                      isSelected ? theme.primaryColor.withValues(alpha: 0.5) : theme.dividerColor,
                  width: 1),
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
                        '${model.modelType} • ${downloadInfo?.receivedBytes != null ? "${UtilHelper.formatBytes(downloadInfo!.receivedBytes!)}/" : ''}${model.size}',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (downloadInfo?.isDownloading == true &&
                          downloadInfo?.progress != null) ...[
                        SizedBox(height: 8.h),
                        LinearProgressIndicator(
                          value: downloadInfo?.progress,
                          backgroundColor: theme.dividerColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${(downloadInfo?.progress ?? 0 * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            if (onPause != null) ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: onPause,
                                  icon: const Icon(Icons.pause, size: 16),
                                  label: const Text('Pause'),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                            ],
                            if (onDelete != null) ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: onDelete,
                                  icon: const Icon(Icons.delete, size: 16),
                                  label: const Text('Delete'),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    foregroundColor: Colors.red,
                                    side: BorderSide(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      if (downloadInfo?.status == DownloadStatus.complete) ...[
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
                      if (downloadInfo?.status == DownloadStatus.incomplete) ...[
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
        ),
        if (downloadInfo?.isDownloading == true && downloadInfo?.progress != null) ...[
          SizedBox(height: 8.h),
          ModelActions(model: model, downloadInfo: downloadInfo)
        ],
      ],
    );
  }
}
