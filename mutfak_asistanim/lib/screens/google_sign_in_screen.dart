import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/brand_mark.dart';
import '../widgets/common_button.dart';
import '../widgets/decorative_background.dart';

class GoogleSignInScreen extends StatelessWidget {
  const GoogleSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 40,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BrandMark(compact: true),
                      const SizedBox(height: 28),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'G',
                                style: textTheme.headlineLarge?.copyWith(
                                  color: const Color(0xFF4285F4),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Google ile Giriş',
                        style: textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Google hesabınızla hızlı, güvenli ve pratik şekilde giriş yapabilirsiniz. Bu ekran şimdilik arayüz akışını tamamlamak için hazırlanmıştır.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      CommonButton(
                        label: 'Devam Et',
                        onPressed: () {},
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CommonButton(
                        label: 'Geri dön',
                        variant: CommonButtonVariant.ghost,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
