import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class SettingsStorageSection extends StatelessWidget {
  final String storageUsage;
  final VoidCallback? onStorageUsageTap;
  final VoidCallback? onClearCacheTap;

  const SettingsStorageSection({
    super.key,
    required this.storageUsage,
    this.onStorageUsageTap,
    this.onClearCacheTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsSection(
      title: LangUtil.trans("settings.storage"),
      children: [
        SettingsCard(
          leading: Icon(
            Icons.storage,
            color: theme.primaryColor,
            size: 24.w,
          ),
          title: LangUtil.trans("settings.storage_usage"),
          subtitle: storageUsage,
          trailing: Icon(
            Icons.chevron_right,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          onTap: onStorageUsageTap,
        ),
        AppSizing.kh10Spacer(),
        SettingsCard(
          leading: Icon(
            Icons.delete_sweep,
            color: theme.primaryColor,
            size: 24.w,
          ),
          title: LangUtil.trans("settings.clear_cache"),
          subtitle: LangUtil.trans("settings.free_up_space"),
          trailing: Expanded(
            child: AppButton(
              title: LangUtil.trans("common.clear"),
              onPressed: onClearCacheTap,
              type: AppButtonType.dangerGhost,
              size: AppButtonSize.small,
            ),
          ),
        ),
      ],
    );
  }
}
