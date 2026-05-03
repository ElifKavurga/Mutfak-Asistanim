import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/brand_mark.dart';
import '../widgets/common_button.dart';
import '../widgets/common_text_field.dart';
import '../widgets/decorative_background.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
                constraints: const BoxConstraints(maxWidth: 460),
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
                      const SizedBox(height: 24),
                      Text(
                        'Sifremi Unuttum',
                        style: textTheme.headlineLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Hesabina bagli e-posta adresini gir. Sifre yenileme baglantisini bu adrese gonderelim.',
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 28),
                      const CommonTextField(
                        label: 'E-posta Adresi',
                        hintText: 'ornek@mutfak.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      CommonButton(
                        label: 'Sifre Yenileme Baglantisi Gonder',
                        onPressed: () {},
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CommonButton(
                        label: 'Giris Ekranina Don',
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
