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
          padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                      border:
                          Border.all(color: theme.primaryColorDark, width: 8.w),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
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
                          Icon(
                            Icons.smart_toy,
                            color: theme.primaryColor,
                            size: 40.w,
                          ),
                          SizedBox(height: 8.h),
                          Text('OFFLINE', style: theme.textTheme.displaySmall),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AppSizing.kh20Spacer(),

              // Headline
              Text(
                'AI, Anytime, Anywhere',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              AppSizing.kh10Spacer(),

              // Description
              Text(
                'With this app, you can download AI models like Gemini and UX Pilot directly to your device, and use them offline — no internet needed! Interact with the models anytime, even when you\'re on the go or in low-connectivity areas.',
                style: theme.textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),

              AppSizing.kh20Spacer(),
              AppSizing.kh20Spacer(),

              // Feature List
              Expanded(
                child: Column(
                  children: [
                    _buildFeatureItem(
                      context,
                      icon: Icons.wifi_off,
                      iconBgColor: AppColors.pinkColor,
                      title: 'Use AI Offline',
                      description:
                          'Interact with powerful AI models without needing an internet connection.',
                    ),
                    AppSizing.kh20Spacer(),
                    _buildFeatureItem(
                      context,
                      icon: Icons.refresh,
                      iconBgColor: AppColors.greenColor,
                      title: 'Seamless Experience',
                      description:
                          'Download once, switch models, and continue your work anywhere.',
                    ),
                    AppSizing.kh20Spacer(),
                    _buildFeatureItem(
                      context,
                      icon: Icons.grid_view,
                      iconBgColor: AppColors.pinkColor,
                      title: 'Model Management',
                      description:
                          'Easily manage, download, and switch between models in the app.',
                    ),
                  ],
                ),
              ),
              AppSizing.kh20Spacer(),

              // Bottom Button
              AppButton(
                onPressed: () {
                  context.go(AppRouteNames.onboardModel);
                },
                title: 'Get Started',
              ),
              AppSizing.kh20Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Icon(icon, size: 24.w),
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
