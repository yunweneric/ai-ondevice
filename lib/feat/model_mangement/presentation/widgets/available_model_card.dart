import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

class AvailableModelCard extends StatelessWidget {
  final AiModel model;
  final VoidCallback? onDownload;

  const AvailableModelCard({
    super.key,
    required this.model,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(10.w),
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
                  children: [
                    Column(
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
                          model.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            model.size,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AppButton(
                            size: AppButtonSize.small,
                            title: LangUtil.trans("models.download_model"),
                            onPressed: () {
                              final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
                              modelDownloaderBloc.add(StartDownloadEvent(model));
                            },
                            icon: Icon(Icons.download, color: Colors.white, size: 16.w),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AvailableModel {
  final IconData icon;
  final Color iconColor;
  final AiModel model;

  const AvailableModel({
    required this.icon,
    required this.iconColor,
    required this.model,
  });

  /// Create an AvailableModel with default styling
  factory AvailableModel.withDefaults({
    required AiModel model,
    IconData icon = Icons.smart_toy,
    Color iconColor = Colors.blue,
  }) {
    return AvailableModel(
      icon: icon,
      iconColor: iconColor,
      model: model,
    );
  }
}
