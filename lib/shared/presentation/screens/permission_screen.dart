import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_ai/shared/shared.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  void initState() {
    super.initState();
    getIt.get<PermissionBloc>().add(const CheckPermissions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<PermissionBloc, PermissionState>(
          listener: (context, state) {
            if (state.status == AppPermissionStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? LangUtil.trans('permissions.error_message')),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
            if (state.storagePermission) {
              // context.go(AppRouteNames.home);
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    const PermissionHeader(),

                    AppSizing.kh20Spacer(),

                    // Permission Cards
                    PermissionCards(state: state),
                    AppSizing.kh20Spacer(),

                    // Action Buttons
                    PermissionActionButtons(state: state),
                    AppSizing.kh20Spacer(),

                    // Settings Button (if needed)
                    if (!state.storagePermission && state.status == AppPermissionStatus.loaded)
                      const PermissionSettingsButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PermissionHeader extends StatelessWidget {
  const PermissionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.security,
          size: 80,
          color: Theme.of(context).primaryColor,
        ),
        AppSizing.kh20Spacer(),
        Text(
          LangUtil.trans('permissions.title'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        AppSizing.kh20Spacer(),
        Text(
          LangUtil.trans('permissions.description'),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class PermissionCards extends StatelessWidget {
  final PermissionState state;

  const PermissionCards({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PermissionCard(
          icon: Icons.folder,
          title: LangUtil.trans('permissions.storage_permission'),
          description: '${LangUtil.trans('permissions.storage_description')} (Required)',
          isGranted: state.storagePermission,
          isLoading: state.status == AppPermissionStatus.loading,
          onRequest: () {
            getIt.get<PermissionBloc>().add(const RequestStoragePermission());
          },
          isOptional: false,
        ),
        AppSizing.kh20Spacer(),
        PermissionCard(
          icon: Icons.notifications,
          title: LangUtil.trans('permissions.notification_permission'),
          description: '${LangUtil.trans('permissions.notification_description')} (Optional)',
          isGranted: state.notificationPermission,
          isLoading: state.status == AppPermissionStatus.loading,
          onRequest: () {
            getIt.get<PermissionBloc>().add(const RequestNotificationPermission());
          },
          isOptional: true,
        ),
      ],
    );
  }
}

class PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final bool isLoading;
  final VoidCallback onRequest;
  final bool isOptional;

  const PermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.isLoading,
    required this.onRequest,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        // color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted
              ? Theme.of(context).primaryColor
              : isOptional
                  ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)
                  : Theme.of(context).highlightColor,
          width: isOptional ? 1 : 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGranted
                  ? Theme.of(context).primaryColor
                  : isOptional
                      ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                      : Theme.of(context).highlightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isGranted ? AppColors.textWhite : Theme.of(context).primaryColor,
              size: 18,
            ),
          ),
          AppSizing.kwSpacer(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (isGranted)
            Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
              size: 24,
            )
          else if (isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).primaryColor,
              ),
            )
          else
            IconButton(
              onPressed: onRequest,
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class PermissionActionButtons extends StatelessWidget {
  final PermissionState state;

  const PermissionActionButtons({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == AppPermissionStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        if (!state.storagePermission)
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () => getIt.get<PermissionBloc>().add(const RequestStoragePermission()),
              title: 'Grant Storage Permission',
              isLoading: state.status == AppPermissionStatus.loading,
            ),
          ),
        if (state.storagePermission) ...[
          AppSizing.kh20Spacer(),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () {
                context.go(AppRouteNames.onboardModel);
              },
              title: LangUtil.trans('permissions.continue'),
              type: AppButtonType.primary,
            ),
          ),
          if (!state.notificationPermission) ...[
            AppSizing.kh20Spacer(),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: () => getIt.get<PermissionBloc>().add(const RequestNotificationPermission()),
                title: 'Enable Notifications (Optional)',
                type: AppButtonType.outline,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class PermissionSettingsButton extends StatelessWidget {
  const PermissionSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getIt.get<PermissionBloc>().add(const OpenAppSettings());
      },
      child: Text(
        LangUtil.trans('permissions.open_app_settings'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }
}
