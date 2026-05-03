import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/brand_mark.dart';
import '../widgets/decorative_background.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ).drive(Tween<double>(begin: 0.1, end: 1));

    _progressController.addStatusListener((status) {
      if (status != AnimationStatus.completed || !mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                const Expanded(
                  flex: 3,
                  child: Center(child: _SplashBrandSection()),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: _SplashLoadingSection(
                          progressAnimation: _progressAnimation,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashBrandSection extends StatelessWidget {
  const _SplashBrandSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const BrandMark(centered: true),
        const SizedBox(height: 12),
        Text(
          'Mutfagini daha duzenli yonetmeye hazir ol',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _SplashLoadingSection extends StatelessWidget {
  const _SplashLoadingSection({required this.progressAnimation});

  final Animation<double> progressAnimation;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 6,
            color: AppColors.surfaceContainerHigh,
            child: AnimatedBuilder(
              animation: progressAnimation,
              builder: (context, child) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progressAnimation.value,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryContainer,
                                AppColors.primary,
                                AppColors.primaryDim,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.22,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(
                        (progressAnimation.value * 2) - 1,
                        0,
                      ),
                      child: Container(
                        width: 34,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: 0.35),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Mutfak deneyimin hazirlaniyor',
          textAlign: TextAlign.center,
          style: AppTextStyles.textTheme.labelSmall,
        ),
      ],
    );
  }
}
