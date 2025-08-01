import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class SettingsDangerZoneSection extends StatelessWidget {
  final VoidCallback? onDeleteAllDataTap;

  const SettingsDangerZoneSection({
    super.key,
    this.onDeleteAllDataTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: LangUtil.trans("settings.danger_zone"),
      children: [
        SettingsCard(
          leading: Icon(
            Icons.delete_forever,
            color: Colors.red,
            size: 24.w,
          ),
          title: LangUtil.trans("settings.delete_all_data"),
          subtitle: LangUtil.trans("settings.permanently_delete"),
          trailing: Expanded(
            child: AppButton(
              title: LangUtil.trans("common.delete"),
              onPressed: onDeleteAllDataTap,
              type: AppButtonType.danger,
              size: AppButtonSize.small,
            ),
          ),
        ),
      ],
    );
  }
}
