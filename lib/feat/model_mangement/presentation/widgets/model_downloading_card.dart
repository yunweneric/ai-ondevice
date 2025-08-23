import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

class ModelDownloadingCard extends StatelessWidget {
  final DownloadInfo downloadInfo;
  final VoidCallback? onPause;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ModelDownloadingCard({
    super.key,
    required this.downloadInfo,
    this.onPause,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = downloadInfo.model;
    final isDownloading = downloadInfo.status == DownloadStatus.downloading;
    AppLogger.i('isDownloading: $isDownloading');

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Model Info
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
                  Icons.download,
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
                    Text(
                      model.name,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSizing.khSpacer(4.h),
                    Text(
                      '${model.modelType} • ${model.size}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizing.khSpacer(4.h),
                    Text(
                      'Downloading...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Download Status Icon
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.pause, color: theme.primaryColor, size: 18.w),
              ),
            ],
          ),

          AppSizing.khSpacer(16.h),

          // Progress Section

          // Progress Bar
          LinearProgressIndicator(
            value: downloadInfo.progress,
            backgroundColor: theme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(12.r),
          ),
          AppSizing.khSpacer(8.h),

          // Progress Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(downloadInfo.progress * 100).toInt()}% Complete',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_formatBytes(downloadInfo.receivedBytes)} / ${_formatBytes(downloadInfo.totalBytes)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          AppSizing.khSpacer(16.h),

          // Action Buttons
          Row(
            children: [
              if (onPause != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPause,
                    icon: const Icon(Icons.pause, size: 18),
                    label: const Text('Pause'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: Colors.orange),
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              if (onDelete != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Download Time Info

          AppSizing.khSpacer(12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Started: ${_formatTime(downloadInfo.startTime)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
              Text(
                'Updated: ${_formatTime(downloadInfo.lastUpdateTime)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Format bytes to human readable format
  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    if (i >= suffixes.length) {
      i = suffixes.length - 1;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Format DateTime to readable string
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
