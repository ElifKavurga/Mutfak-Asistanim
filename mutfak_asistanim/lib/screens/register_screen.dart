import 'package:flutter/material.dart';

import '../services/backend_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_mark.dart';
import '../widgets/common_button.dart';
import '../widgets/common_text_field.dart';
import '../widgets/decorative_background.dart';
import 'home_screen.dart';
import 'info_pages.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _submitRegister() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final repeatPassword = _repeatPasswordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      setState(() {
        _errorMessage = 'Devam etmek için tüm alanları doldur.';
      });
      return;
    }

    if (password != repeatPassword) {
      setState(() {
        _errorMessage = 'Girdiğin şifreler birbiriyle eşleşmiyor.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await BackendApiService.instance.registerAndAuthenticate(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
      );
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
        _isSubmitting = false;
      });
    }
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
                      children: <Widget>[
                        Flex(
                          direction: isWide ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            if (isWide) ...<Widget>[
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
                                firstNameController: _firstNameController,
                                lastNameController: _lastNameController,
                                usernameController: _usernameController,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                repeatPasswordController:
                                    _repeatPasswordController,
                                obscurePassword: _obscurePassword,
                                obscureRepeatPassword: _obscureRepeatPassword,
                                isSubmitting: _isSubmitting,
                                errorMessage: _errorMessage,
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
                                onSubmit: _submitRegister,
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
                          children: <Widget>[
                            _FooterLink(
                              label: 'Gizlilik',
                              onTap: () =>
                                  _openScreen(const PrivacyPolicyScreen()),
                            ),
                            const _FooterDot(),
                            _FooterLink(
                              label: 'Sartlar',
                              onTap: () =>
                                  _openScreen(const TermsOfUseScreen()),
                            ),
                            const _FooterDot(),
                            _FooterLink(
                              label: 'Yardim',
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
      children: <Widget>[
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
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
              children: <Widget>[
                const Spacer(),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: const <Widget>[
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
                  'Mutfagini daha duzenli ve kolay yonet.',
                  style: textTheme.headlineLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hesabini olustur, envanterini takip et ve sana uygun tarif onerilerini tek yerde gor.',
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
    required this.firstNameController,
    required this.lastNameController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.repeatPasswordController,
    required this.obscurePassword,
    required this.obscureRepeatPassword,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onToggleRepeatPassword,
    required this.onSubmit,
  });

  final TextTheme textTheme;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController repeatPasswordController;
  final bool obscurePassword;
  final bool obscureRepeatPassword;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleRepeatPassword;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 12),
        const BrandMark(compact: true),
        const SizedBox(height: 24),
        Text(
          'Yeni hesabini olustur ve mutfagini daha kolay yonetmeye basla.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        CommonTextField(
          label: 'Ad',
          hintText: 'Adinizi girin',
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
          controller: firstNameController,
        ),
        const SizedBox(height: 18),
        CommonTextField(
          label: 'Soyad',
          hintText: 'Soyadinizi girin',
          prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.name,
          controller: lastNameController,
        ),
        const SizedBox(height: 18),
        CommonTextField(
          label: 'Kullanici Adi',
          hintText: 'kullanici_adi',
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.text,
          controller: usernameController,
        ),
        const SizedBox(height: 18),
        CommonTextField(
          label: 'E-posta',
          hintText: 'ornek@mutfak.com',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
        ),
        const SizedBox(height: 18),
        CommonTextField(
          label: 'Sifre',
          hintText: 'Sifrenizi olusturun',
          prefixIcon: Icons.lock_outline_rounded,
          controller: passwordController,
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
          label: 'Sifre Tekrar',
          hintText: 'Sifrenizi yeniden girin',
          prefixIcon: Icons.lock_person_outlined,
          controller: repeatPasswordController,
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
        if (errorMessage != null) ...<Widget>[
          const SizedBox(height: 14),
          _InlineErrorText(message: errorMessage!),
        ],
        const SizedBox(height: 24),
        CommonButton(
          label: isSubmitting ? 'Hesap Olusturuluyor...' : 'Kayit Ol',
          onPressed: isSubmitting ? null : () => onSubmit(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
        const SizedBox(height: 26),
        Text.rich(
          TextSpan(
            text: 'Zaten hesabin var mi? ',
            style: textTheme.bodyMedium,
            children: <InlineSpan>[
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
                    'Giris Yap',
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

class _InlineErrorText extends StatelessWidget {
  const _InlineErrorText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7B8AD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.error_outline_rounded, color: Color(0xFFB94C3A)),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
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
        boxShadow: const <BoxShadow>[
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
