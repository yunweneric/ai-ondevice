import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class StorageOverview extends StatefulWidget {
  const StorageOverview({super.key});

  @override
  State<StorageOverview> createState() => _StorageOverviewState();
}

class _StorageOverviewState extends State<StorageOverview> {
  @override
  void initState() {
    super.initState();
    // Load storage info when widget initializes
    getIt.get<FileManagementBloc>().add(LoadStorageInfoEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<FileManagementBloc, FileManagementState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LangUtil.trans("storage.storage_overview"),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: state is FileManagementLoading
                      ? null
                      : () {
                          getIt.get<FileManagementBloc>().add(LoadStorageInfoEvent());
                        },
                  icon: state is FileManagementLoading
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          size: 20.w,
                          color: theme.colorScheme.primary,
                        ),
                  tooltip: 'Refresh storage info',
                ),
              ],
            ),
            AppSizing.kh10Spacer(),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: _buildStorageContent(context, state, theme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStorageContent(BuildContext context, FileManagementState state, ThemeData theme) {
    final error = (state is FileManagementError) ? state.message : null;
    return DataBuilder(
      isLoading: state is FileManagementLoading,
      isError: state is FileManagementError,
      isEmpty: false,
      onReload: () {
        getIt.get<FileManagementBloc>().add(LoadStorageInfoEvent());
      },
      loadingWidget: const StorageOverviewShimmer(),
      errorWidget: error != null ? _buildErrorWidget(error, theme) : null,
      noDataWidget: const SizedBox.shrink(),
      child: _buildLoadedContent(state, theme),
    );
  }

  Widget _buildErrorWidget(String error, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LangUtil.trans("models.title"),
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSizing.kh10Spacer(),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.onErrorContainer,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Error: $error',
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedContent(FileManagementState state, ThemeData theme) {
    // All states now have storage data, but we only want to show content for loaded state
    if (state is! FileManagementLoaded) {
      return const SizedBox.shrink();
    }

    final usedSpace = state.usedSpace;
    final totalSpace = state.totalSpace;
    final usagePercentage = totalSpace > 0 ? (usedSpace / totalSpace) : 0.0;
    final availablePercentage = 1.0 - usagePercentage;

    return Column(
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
            color: theme.dividerColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: usagePercentage,
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
              '${UtilHelper.formatBytes(usedSpace)} / ${UtilHelper.formatBytes(totalSpace)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(usagePercentage * 100).toStringAsFixed(1)}% ${LangUtil.trans("storage.used_storage")}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.purple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        AppSizing.khSpacer(4.h),

        Text(
          '${(availablePercentage * 100).toStringAsFixed(1)}% ${LangUtil.trans("storage.available_storage")}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
