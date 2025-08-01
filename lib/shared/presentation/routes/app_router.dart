import 'package:go_router/go_router.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    UtilHelper.buildAnimatedRoute(
      path: AppRouteNames.start,
      builder: (context, state) => const SplashScreen(),
    ),
    UtilHelper.buildAnimatedRoute(
      path: AppRouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    UtilHelper.buildAnimatedRoute(
      path: AppRouteNames.home,
      builder: (context, state) => const AppLayout(),
    ),
    UtilHelper.buildAnimatedRoute(
      path: AppRouteNames.onboardModel,
      builder: (context, state) => const OnboardModelScreen(),
    ),
    UtilHelper.buildAnimatedRoute(
      path: AppRouteNames.permission,
      builder: (context, state) => const PermissionScreen(),
    ),
  ],
);
