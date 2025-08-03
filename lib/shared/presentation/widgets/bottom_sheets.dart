import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:offline_ai/shared/shared.dart';

enum FilePickerType { file, gallery, camera }

class AppSheet {
  static showActionSheet({
    required String title,
    required BuildContext context,
    required String description,
    required VoidCallback onApprove,
    required VoidCallback onReject,
    required String? approveText,
    required String? rejectText,
    double? height,
  }) {
    AppSheet.simpleBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      height: AppSizing.kHPercentage(context, height ?? 40),
      child: Column(
        children: [
          AppSizing.kh20Spacer(),
          AppSizing.kh20Spacer(),
          Text(title, style: Theme.of(context).textTheme.displayMedium),
          Text(description, textAlign: TextAlign.center),
          AppSizing.kh20Spacer(),
          AppButton(title: approveText ?? LangUtil.trans("common.yes"), onPressed: onApprove),
          AppSizing.kh10Spacer(),
          AppButton(
            title: rejectText ?? LangUtil.trans("common.no"),
            onPressed: onReject,
            type: AppButtonType.danger,
          ),
        ],
      ),
    );
  }

  static baseBottomSheet({
    required BuildContext context,
    required Widget child,
    bool? isDismissible,
    bool? enableDrag,
  }) {
    return showBarModalBottomSheet(
      // topControl: const SizedBox.shrink(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (_) => BottomSheetChild(child: child),
      barrierColor: AppColors.bgDark.withValues(alpha: 0.5),
      isDismissible: isDismissible ?? true,
      enableDrag: enableDrag ?? true,
      useRootNavigator: true,
      overlayStyle: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  static simpleBottomSheet({
    required BuildContext context,
    required Widget child,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    AlignmentGeometry? alignment,
    bool? enableDrag,
    bool? isDismissible,
    bool? showClose,
    VoidCallback? onClose,
  }) {
    return baseBottomSheet(
      context: context,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      child: PopScope(
        canPop: isDismissible ?? true,
        child: Stack(
          children: [
            Container(
              alignment: alignment,
              height: height,
              padding: padding,
              width: AppSizing.width(context),
              margin: margin,
              decoration: decoration,
              child: child,
            ),
            if (showClose == true)
              Positioned(
                top: 15,
                right: 20,
                child: GestureDetector(
                  onTap: onClose ?? () => context.pop(),
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).highlightColor.withValues(alpha: 0.2),
                    child: AppIcon(
                      icon: AppIcons.close,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static showChangeThemeSheet(BuildContext context) {
    final theme = Theme.of(context);
    final themeBloc = getIt.get<ThemeBloc>();
    return AppSheet.simpleBottomSheet(
      height: AppSizing.kHPercentage(context, 35),
      context: context,
      showClose: true,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: BlocConsumer<ThemeBloc, ThemeState>(
        listener: (context, state) {
          if (state is UpdateTheme) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) context.pop();
            });
          }
        },
        builder: (context, state) {
          final appTheme = state.themeMode;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LangUtil.trans("profile.change_theme"), style: theme.textTheme.displayMedium),
              Divider(height: 30.h),
              TextButton.icon(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  fixedSize: Size.fromWidth(AppSizing.width(context)),
                ),
                onPressed: () {
                  themeBloc.add(ChangeThemeEvent(themeMode: ThemeMode.light));
                },
                label: Row(
                  children: [
                    Expanded(
                      child: Text(
                        LangUtil.trans("profile.light_theme"),
                        style: theme.textTheme.displaySmall?.copyWith(color: theme.primaryColorDark),
                      ),
                    ),
                    AppCheckbox(isActive: appTheme == ThemeMode.light)
                  ],
                ),
                icon: Icon(Icons.sunny, color: theme.primaryColorDark),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  fixedSize: Size.fromWidth(AppSizing.width(context)),
                ),
                onPressed: () {
                  themeBloc.add(ChangeThemeEvent(themeMode: ThemeMode.dark));
                },
                label: Row(
                  children: [
                    Expanded(
                      child: Text(
                        LangUtil.trans("profile.dark_theme"),
                        style: theme.textTheme.displaySmall,
                      ),
                    ),
                    AppCheckbox(isActive: appTheme == ThemeMode.dark)
                  ],
                ),
                icon: Icon(Icons.dark_mode_rounded, color: theme.primaryColorDark),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  fixedSize: Size.fromWidth(AppSizing.width(context)),
                ),
                onPressed: () {
                  themeBloc.add(ChangeThemeEvent(themeMode: ThemeMode.system));
                },
                label: Row(
                  children: [
                    Expanded(
                      child: Text(
                        LangUtil.trans("profile.system_theme"),
                        style: theme.textTheme.displaySmall,
                      ),
                    ),
                    AppCheckbox(isActive: appTheme == ThemeMode.system)
                  ],
                ),
                icon: Icon(Icons.phone_android_rounded, color: theme.primaryColorDark),
              ),
            ],
          );
        },
      ),
    );
  }

  static showChangeLanguageSheet(BuildContext context) {
    final theme = Theme.of(context);
    final languageBloc = getIt.get<LanguageBloc>();
    return AppSheet.simpleBottomSheet(
      height: AppSizing.kHPercentage(context, 30),
      context: context,
      showClose: true,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: BlocConsumer<LanguageBloc, LanguageState>(
        listener: (context, state) {
          if (state is UpdateLanguage) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) context.pop();
            });
          }
        },
        builder: (context, state) {
          final currentLocale = state.currentLocale;
          AppLogger.i(currentLocale.countryCode);
          AppLogger.i(currentLocale.languageCode);
          bool isFrench = LangUtil.isFrench(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LangUtil.trans("profile.change_language"), style: theme.textTheme.displayMedium),
              Divider(height: 30.h),
              TextButton.icon(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  fixedSize: Size.fromWidth(AppSizing.width(context)),
                ),
                onPressed: () {
                  languageBloc.add(
                    UpdateAppLanguageEvent(
                      context: context,
                      newLocale: const Locale('fr'),
                    ),
                  );
                },
                label: Row(
                  children: [
                    Expanded(
                      child: Text(
                        LangUtil.trans("profile.french"),
                        style: theme.textTheme.displaySmall?.copyWith(color: theme.primaryColorDark),
                      ),
                    ),
                    AppCheckbox(isActive: isFrench)
                  ],
                ),
                // icon: Icon(Icons.sunny, color: theme.primaryColorDark),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  fixedSize: Size.fromWidth(AppSizing.width(context)),
                ),
                onPressed: () {
                  languageBloc.add(
                    UpdateAppLanguageEvent(
                      context: context,
                      newLocale: const Locale('en'),
                    ),
                  );
                },
                label: Row(
                  children: [
                    Expanded(
                      child: Text(
                        LangUtil.trans("profile.english"),
                        style: theme.textTheme.displaySmall,
                      ),
                    ),
                    AppCheckbox(isActive: !isFrench)
                  ],
                ),
                // icon: Icon(Icons.dark_mode_rounded, color: theme.primaryColorDark),
              ),
            ],
          );
        },
      ),
    );
  }

  static showClearCacheSheet(BuildContext context, {required String cacheSize, required VoidCallback onClearCache}) {
    final theme = Theme.of(context);
    return AppSheet.simpleBottomSheet(
      height: AppSizing.kHPercentage(context, 35),
      context: context,
      showClose: true,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LangUtil.trans("dialogs.clear_cache"),
            style: theme.textTheme.displayMedium,
          ),
          AppSizing.kh10Spacer(),
          Text(
            LangUtil.trans("dialogs.clear_cache_desc", args: {"cacheSize": cacheSize}),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          AppSizing.kh20Spacer(),
          AppButton(
            title: LangUtil.trans("dialogs.clear_cache_button"),
            onPressed: () {
              onClearCache();
              context.pop();
            },
            type: AppButtonType.danger,
          ),
        ],
      ),
    );
  }

  static showAppVersionSheet(BuildContext context, {required String appVersion}) {
    final theme = Theme.of(context);
    return AppSheet.simpleBottomSheet(
      height: AppSizing.kHPercentage(context, 40),
      context: context,
      showClose: true,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LangUtil.trans("dialogs.app_version"),
            style: theme.textTheme.displayMedium,
          ),
          AppSizing.kh10Spacer(),
          Text(
            LangUtil.trans("dialogs.app_version_desc"),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          AppSizing.kh20Spacer(),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LangUtil.trans("dialogs.version_info"),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      appVersion,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AppSizing.kh10Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LangUtil.trans("dialogs.build_number"),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      "1.0.0+1",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                AppSizing.khSpacer(5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LangUtil.trans("dialogs.release_date"),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      "2024-01-15",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static showDeleteDataSheet(BuildContext context, {required VoidCallback onDeleteData}) {
    final theme = Theme.of(context);
    return AppSheet.simpleBottomSheet(
      height: AppSizing.kHPercentage(context, 35),
      context: context,
      showClose: true,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LangUtil.trans("dialogs.delete_all_data"),
            style: theme.textTheme.displayMedium,
          ),
          AppSizing.kh10Spacer(),
          Text(
            LangUtil.trans("dialogs.delete_all_data_desc"),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          AppSizing.kh20Spacer(),
          AppButton(
            title: LangUtil.trans("dialogs.delete_all_data_button"),
            onPressed: () {
              onDeleteData();
              context.pop();
            },
            type: AppButtonType.danger,
          ),
        ],
      ),
    );
  }
}

class BottomSheetChild extends StatefulWidget {
  final Widget child;
  const BottomSheetChild({super.key, required this.child});

  @override
  State<BottomSheetChild> createState() => _BottomSheetChildState();
}

class _BottomSheetChildState extends State<BottomSheetChild> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r),
          topRight: Radius.circular(10.r),
        ),
        child: widget.child,
      ),
    );
  }
}
