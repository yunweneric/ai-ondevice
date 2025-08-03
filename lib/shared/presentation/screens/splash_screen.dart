import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_ai/shared/shared.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late List<AnimationController> _bounceControllers;
  late List<Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Initialize staggered bounce animations
    _bounceControllers = List.generate(
        5,
        (index) => AnimationController(
              duration: const Duration(milliseconds: 600),
              vsync: this,
            ));

    _bounceAnimations = _bounceControllers
        .map((controller) => Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            )))
        .toList();

    // Start animations with staggered timing
    _fadeController.forward();
    for (int i = 0; i < _bounceControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 120), () {
        if (mounted) _bounceControllers[i].repeat(reverse: true);
      });
    }

    // Navigate after delay
    Future.delayed(const Duration(seconds: 2), () {
      // ignore: use_build_context_synchronously
      if (context.mounted) context.go(AppRouteNames.onboarding);
    });
  }

  @override
  void dispose() {
    for (var controller in _bounceControllers) {
      controller.dispose();
    }
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SvgPicture.string(
                  AppIcons.robot,
                  width: 120,
                  height: 120,
                ),
              ),
            ),
          ),

          // Progress bar with bouncing circles
          Container(
            padding: const EdgeInsets.only(bottom: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Row(
                  children: [
                    AnimatedBuilder(
                      animation: _bounceAnimations[index],
                      builder: (context, child) {
                        return Opacity(
                          opacity: _bounceAnimations[index].value,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                    if (index < 4) const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
