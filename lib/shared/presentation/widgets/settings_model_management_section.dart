import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class SettingsModelManagementSection extends StatelessWidget {
  final VoidCallback? onManageModelsTap;
  final VoidCallback? onDownloadSettingsTap;

  const SettingsModelManagementSection({
    super.key,
    this.onManageModelsTap,
    this.onDownloadSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsSection(
      title: LangUtil.trans("models.model_management"),
      children: [
        SettingsCard(
          leading: Icon(
            Icons.storage,
            color: theme.primaryColor,
            size: 24.w,
          ),
          title: LangUtil.trans("settings.manage_models"),
          subtitle: LangUtil.trans("settings.download_update_remove"),
          trailing: Icon(
            Icons.chevron_right,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          onTap: onManageModelsTap,
        ),
        SettingsCard(
          leading: Icon(
            Icons.cloud_download,
            color: theme.primaryColor,
            size: 24.w,
          ),
          title: LangUtil.trans("settings.download_settings"),
          subtitle: LangUtil.trans("settings.configure_download"),
          trailing: Icon(
            Icons.chevron_right,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          onTap: onDownloadSettingsTap,
        ),
      ],
    );
  }
} 