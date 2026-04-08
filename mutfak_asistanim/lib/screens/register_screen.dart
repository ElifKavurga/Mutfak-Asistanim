import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/brand_mark.dart';
import '../widgets/common_button.dart';
import '../widgets/common_text_field.dart';
import '../widgets/decorative_background.dart';
import 'info_pages.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 20,
                  vertical: isWide ? 32 : 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1160),
                    child: Column(
                      children: [
                        Flex(
                          direction: isWide ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isWide) ...[
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 48),
                                  child: _RegisterShowcase(),
                                ),
                              ),
                            ],
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 430),
                              child: _RegisterForm(
                                textTheme: textTheme,
                                obscurePassword: _obscurePassword,
                                obscureRepeatPassword: _obscureRepeatPassword,
                                onTogglePassword: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                onToggleRepeatPassword: () {
                                  setState(() {
                                    _obscureRepeatPassword =
                                        !_obscureRepeatPassword;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 14,
                          runSpacing: 10,
                          children: [
                            _FooterLink(
                              label: 'Gizlilik',
                              onTap: () =>
                                  _openScreen(const PrivacyPolicyScreen()),
                            ),
                            const _FooterDot(),
                            _FooterLink(
                              label: 'Şartlar',
                              onTap: () =>
                                  _openScreen(const TermsOfUseScreen()),
                            ),
                            const _FooterDot(),
                            _FooterLink(
                              label: 'Yardım',
                              onTap: () =>
                                  _openScreen(const HelpSupportScreen()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RegisterShowcase extends StatelessWidget {
  const _RegisterShowcase();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFDCE8D0),
                  Color(0xFFB8C8A7),
                  Color(0xFF8A9A7C),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -22,
          left: -18,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ),
        Positioned(
          bottom: -28,
          right: -10,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32),
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: const [
                      _CircleGlow(size: 280, opacity: 0.18),
                      _RoundedGlow(size: 180, opacity: 0.2),
                      Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 112,
                        color: Colors.white,
                      ),
                      Positioned(
                        left: 34,
                        top: 64,
                        child: _ShowcaseBadge(
                          icon: Icons.favorite_rounded,
                          color: AppColors.secondaryContainer,
                          iconColor: AppColors.secondary,
                        ),
                      ),
                      Positioned(
                        right: 36,
                        bottom: 56,
                        child: _ShowcaseBadge(
                          icon: Icons.verified_user_rounded,
                          color: AppColors.tertiaryContainer,
                          iconColor: AppColors.primaryDim,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'MutfakAsistanım ile mutfağını daha akıllı yönet.',
                  style: textTheme.headlineLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hesabını oluştur, malzemelerini düzenle ve önerileri keşfet.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.textTheme,
    required this.obscurePassword,
    required this.obscureRepeatPassword,
    required this.onTogglePassword,
    required this.onToggleRepeatPassword,
  });

  final TextTheme textTheme;
  final bool obscurePassword;
  final bool obscureRepeatPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleRepeatPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const BrandMark(compact: true),
        const SizedBox(height: 24),
        Text(
          'Yeni hesabınızı oluşturun ve mutfak deneyiminizi kişiselleştirin.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        const CommonTextField(
          label: 'Ad Soyad',
          hintText: 'Adınızı ve soyadınızı girin',
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 18),
        const CommonTextField(
          label: 'E-posta',
          hintText: 'ornek@mutfak.com',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        CommonTextField(
          label: 'Şifre',
          hintText: 'Şifrenizi oluşturun',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: obscurePassword,
          suffix: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.outline,
            ),
          ),
        ),
        const SizedBox(height: 18),
        CommonTextField(
          label: 'Şifre Tekrar',
          hintText: 'Şifrenizi yeniden girin',
          prefixIcon: Icons.lock_person_outlined,
          obscureText: obscureRepeatPassword,
          suffix: IconButton(
            onPressed: onToggleRepeatPassword,
            icon: Icon(
              obscureRepeatPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.outline,
            ),
          ),
        ),
        const SizedBox(height: 24),
        CommonButton(
          label: 'Kayıt Ol',
          onPressed: () {},
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
        const SizedBox(height: 26),
        Text.rich(
          TextSpan(
            text: 'Zaten hesabın var mı? ',
            style: textTheme.bodyMedium,
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Giriş Yap',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ShowcaseBadge extends StatelessWidget {
  const _ShowcaseBadge({
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}

class _CircleGlow extends StatelessWidget {
  const _CircleGlow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _RoundedGlow extends StatelessWidget {
  const _RoundedGlow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(34),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _FooterDot extends StatelessWidget {
  const _FooterDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.outlineVariant,
        shape: BoxShape.circle,
      ),
    );
  }
}
