import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoDownload = false;
  final String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LangUtil.trans("settings.title")),
        centerTitle: true,
      ),
      body: ListView(
        padding: AppSizing.kMainPadding(context),
        children: [
          AppSizing.kh20Spacer(),

          // Profile Section
          SettingsProfileSection(
            onProfileTap: () {
              // Navigate to profile settings
            },
          ),

          AppSizing.kh20Spacer(),

          // Appearance Section
          SettingsAppearanceSection(
            selectedLanguage: _selectedLanguage,
            onThemeTap: () {
              AppSheet.showChangeThemeSheet(context);
            },
            onLanguageTap: () {
              AppSheet.showChangeLanguageSheet(context);
            },
          ),

          AppSizing.kh20Spacer(),

          // Notifications Section
          SettingsNotificationsSection(
            notificationsEnabled: _notificationsEnabled,
            autoDownload: _autoDownload,
            onNotificationsChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            onAutoDownloadChanged: (value) {
              setState(() {
                _autoDownload = value;
              });
            },
          ),

          AppSizing.kh20Spacer(),

          // Model Management Section
          SettingsModelManagementSection(
            onManageModelsTap: () {
              // Navigate to model management
            },
            onDownloadSettingsTap: () {
              // Navigate to download settings
            },
          ),

          AppSizing.kh20Spacer(),

          // Storage Section
          SettingsStorageSection(
            storageUsage: '7.5 GB used of 32 GB',
            onStorageUsageTap: () {
              // Navigate to storage details
            },
            onClearCacheTap: () {
              _showClearCacheSheet();
            },
          ),

          AppSizing.kh20Spacer(),

          // About Section
          SettingsAboutSection(
            appVersion: 'v1.0.0',
            onAppVersionTap: () {
              _showAppVersionSheet();
            },
            onPrivacyPolicyTap: () {
              // Navigate to privacy policy
            },
            onTermsOfServiceTap: () {
              // Navigate to terms of service
            },
          ),

          AppSizing.kh20Spacer(),

          // Danger Zone
          SettingsDangerZoneSection(
            onDeleteAllDataTap: () {
              _showDeleteDataSheet();
            },
          ),

          AppSizing.kh20Spacer(),
        ],
      ),
    );
  }

  void _showClearCacheSheet() {
    AppSheet.showClearCacheSheet(
      context,
      cacheSize: '2.3 GB',
      onClearCache: () {
        // Handle clear cache
        AppLogger.i('Cache cleared');
      },
    );
  }

  void _showAppVersionSheet() {
    AppSheet.showAppVersionSheet(
      context,
      appVersion: 'v1.0.0',
    );
  }

  void _showDeleteDataSheet() {
    AppSheet.showDeleteDataSheet(
      context,
      onDeleteData: () {
        // Handle delete all data
        AppLogger.i('All data deleted');
      },
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.displaySmall,
        ),
        AppSizing.kh10Spacer(),
        ...children,
      ],
    );
  }
}

class SettingsCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            leading,
            AppSizing.kwSpacer(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.displaySmall,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              AppSizing.kwSpacer(12.w),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
