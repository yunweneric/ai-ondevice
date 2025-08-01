import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class SettingsAboutSection extends StatelessWidget {
  final String appVersion;
  final VoidCallback? onAppVersionTap;
  final VoidCallback? onPrivacyPolicyTap;
  final VoidCallback? onTermsOfServiceTap;

  const SettingsAboutSection({
    super.key,
    required this.appVersion,
    this.onAppVersionTap,
    this.onPrivacyPolicyTap,
    this.onTermsOfServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsSection(
      title: LangUtil.trans("settings.about"),
      children: [
        SettingsCard(
          leading: Icon(
            Icons.info,
            color: theme.primaryColor,
            size: 24.w,
          ),
          title: LangUtil.trans("settings.app_version"),
          subtitle: appVersion,
          trailing: Icon(
            Icons.chevron_right,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          onTap: onAppVersionTap,
        ),
        AppSizing.kh10Spacer(),
        SettingsCard(
          leading: Icon(
            Icons.description,
            color: theme.primaryColor,
            size: 24.w,
          ),
          title: LangUtil.trans("settings.privacy_policy"),
          subtitle: LangUtil.trans("settings.read_privacy"),
          trailing: Icon(
            Icons.chevron_right,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          onTap: onPrivacyPolicyTap,
        ),
        AppSizing.kh10Spacer(),
        SettingsCard(
          leading: Icon(
            Icons.description,
            color: theme.primaryColor,
            size: 24.w,
          ),
          title: LangUtil.trans("settings.terms_of_service"),
          subtitle: LangUtil.trans("settings.read_terms"),
          trailing: Icon(
            Icons.chevron_right,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          onTap: onTermsOfServiceTap,
        ),
      ],
    );
  }
}
