import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class SettingsAppearanceSection extends StatelessWidget {
  final String selectedLanguage;

  final VoidCallback? onLanguageTap;
  final VoidCallback? onThemeTap;

  const SettingsAppearanceSection({
    super.key,
    required this.selectedLanguage,
    this.onLanguageTap,
    this.onThemeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state.themeMode == ThemeMode.dark;
        return SettingsSection(
          title: LangUtil.trans("settings.appearance"),
          children: [
            SettingsCard(
              leading: Icon(
                Icons.dark_mode,
                color: theme.primaryColor,
                size: 24.w,
              ),
              title: LangUtil.trans("settings.dark_mode"),
              subtitle: LangUtil.trans("settings.switch_themes"),
              trailing: Icon(
                Icons.chevron_right,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
              onTap: onThemeTap,
            ),
            SettingsCard(
              leading: Icon(
                Icons.language,
                color: theme.primaryColor,
                size: 24.w,
              ),
              title: LangUtil.trans("settings.language"),
              subtitle: selectedLanguage,
              trailing: Icon(
                Icons.chevron_right,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
              onTap: onLanguageTap,
            ),
          ],
        );
      },
    );
  }
}
