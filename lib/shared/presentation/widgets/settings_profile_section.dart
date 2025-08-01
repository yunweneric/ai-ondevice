import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class SettingsProfileSection extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const SettingsProfileSection({
    super.key,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsSection(
      title: LangUtil.trans("settings.profile"),
      children: [
        SettingsCard(
          leading: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 24.w,
            ),
          ),
          title: LangUtil.trans("settings.user_profile"),
          subtitle: LangUtil.trans("settings.manage_account"),
          trailing: Icon(
            Icons.chevron_right,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          onTap: onProfileTap,
        ),
      ],
    );
  }
} 