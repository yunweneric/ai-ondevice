import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class SettingsNotificationsSection extends StatelessWidget {
  final bool notificationsEnabled;
  final bool autoDownload;
  final ValueChanged<bool>? onNotificationsChanged;
  final ValueChanged<bool>? onAutoDownloadChanged;

  const SettingsNotificationsSection({
    super.key,
    required this.notificationsEnabled,
    required this.autoDownload,
    this.onNotificationsChanged,
    this.onAutoDownloadChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsSection(
      title: LangUtil.trans("settings.notifications"),
      children: [
        SettingsCard(
          leading: Icon(
            Icons.notifications,
            color: theme.primaryColor,
            size: 24.w,
          ),
          title: LangUtil.trans("settings.push_notifications"),
          subtitle: LangUtil.trans("settings.receive_notifications"),
          trailing: Switch(
            value: notificationsEnabled,
            onChanged: onNotificationsChanged,
          ),
        ),
        AppSizing.kh10Spacer(),
        SettingsCard(
          leading: Icon(
            Icons.download,
            color: theme.primaryColor,
            size: 24.w,
          ),
          title: LangUtil.trans("settings.auto_download"),
          subtitle: LangUtil.trans("settings.auto_download_models"),
          trailing: Switch(
            value: autoDownload,
            onChanged: onAutoDownloadChanged,
          ),
        ),
      ],
    );
  }
}
