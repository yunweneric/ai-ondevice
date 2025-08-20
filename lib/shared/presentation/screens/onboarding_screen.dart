import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_ai/shared/shared.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSizing.kMainPadding(context),
          child: Column(
            children: [
              AppSizing.kh20Spacer(),
              AppSizing.kh20Spacer(),
              // Central Image Section
              SizedBox(
                height: AppSizing.kHPercentage(context, 20),
                width: double.infinity,
                child: Center(
                  child: Container(
                    width: 120.w,
                    height: 160.h,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      border: Border.all(color: theme.primaryColorDark, width: 8.w),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: EdgeInsets.all(8.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppIcon(
                            icon: AppIcons.robotHead,
                            size: 40.w,
                            color: theme.primaryColor,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            LangUtil.trans("onboarding.offline"),
                            style: theme.textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AppSizing.kh20Spacer(),

              // Headline
              Text(
                LangUtil.trans("onboarding.headline"),
                style: theme.textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),

              AppSizing.kh20Spacer(),

              // Description
              Text(
                LangUtil.trans("onboarding.description"),
                style: theme.textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),

              AppSizing.kh20Spacer(),
              AppSizing.kh20Spacer(),

              // Feature List
              Expanded(
                child: Column(
                  children: [
                    BuildFeatureItem(
                      icon: Icons.wifi_off,
                      title: LangUtil.trans("onboarding.use_ai_offline"),
                      description: LangUtil.trans("onboarding.use_ai_offline_desc"),
                    ),
                    AppSizing.kh20Spacer(),
                    BuildFeatureItem(
                      icon: Icons.refresh,
                      title: LangUtil.trans("onboarding.seamless_experience"),
                      description: LangUtil.trans("onboarding.seamless_experience_desc"),
                    ),
                    AppSizing.kh20Spacer(),
                    BuildFeatureItem(
                      icon: Icons.grid_view,
                      title: LangUtil.trans("onboarding.model_management"),
                      description: LangUtil.trans("onboarding.model_management_desc"),
                    ),
                  ],
                ),
              ),
              AppSizing.kh20Spacer(),

              // Bottom Button
              AppButton(
                onPressed: () async {
                  final localStorageService = getIt.get<LocalStorageService>();
                  await localStorageService.saveInit();
                  if (context.mounted) {
                    context.go(AppRouteNames.permission);
                  }
                },
                title: LangUtil.trans("common.get_started"),
              ),
              AppSizing.kh20Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class BuildFeatureItem extends StatelessWidget {
  const BuildFeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Icon(
            icon,
            size: 24.w,
            color: Colors.white,
          ),
        ),
        AppSizing.kwSpacer(15.w),
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
                description,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
