import 'package:flutter/material.dart';

import '../services/backend_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_mark.dart';
import '../widgets/common_button.dart';
import '../widgets/common_text_field.dart';
import '../widgets/decorative_background.dart';
import 'forgot_password_screen.dart';
import 'google_sign_in_screen.dart';
import 'home_screen.dart';
import 'info_pages.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _submitLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Kullanici adi ve sifre zorunludur.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await BackendApiService.instance.authenticate(
        username: username,
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
                                  child: _LoginShowcase(),
                                ),
                              ),
                            ],
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 430),
                              child: _LoginForm(
                                textTheme: textTheme,
                                usernameController: _usernameController,
                                passwordController: _passwordController,
                                rememberMe: _rememberMe,
                                obscurePassword: _obscurePassword,
                                isSubmitting: _isSubmitting,
                                errorMessage: _errorMessage,
                                onRememberChanged: (value) {
                                  setState(() {
                                    _rememberMe = value;
                                  });
                                },
                                onTogglePassword: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                onSubmit: _submitLogin,
                                openScreen: _openScreen,
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

class _LoginShowcase extends StatelessWidget {
  const _LoginShowcase();

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
                    children: <Widget>[
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(34),
                        ),
                      ),
                      const Icon(
                        Icons.kitchen_rounded,
                        size: 112,
                        color: Colors.white,
                      ),
                      Positioned(
                        left: 34,
                        top: 64,
                        child: _ShowcaseBadge(
                          icon: Icons.local_florist_rounded,
                          color: AppColors.secondaryContainer,
                          iconColor: AppColors.secondary,
                        ),
                      ),
                      Positioned(
                        right: 36,
                        bottom: 56,
                        child: _ShowcaseBadge(
                          icon: Icons.restaurant_menu_rounded,
                          color: AppColors.tertiaryContainer,
                          iconColor: AppColors.primaryDim,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Mutfakta ilham dolu anlar seni bekliyor.',
                  style: textTheme.headlineLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Giris yap, mutfagini takip etmeye basla ve envanterine uygun tarifleri kolayca kesfet.',
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

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.textTheme,
    required this.usernameController,
    required this.passwordController,
    required this.rememberMe,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.openScreen,
  });

  final TextTheme textTheme;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool obscurePassword;
  final bool isSubmitting;
  final String? errorMessage;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;
  final ValueChanged<Widget> openScreen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 12),
        const BrandMark(compact: true),
        const SizedBox(height: 24),
        Text(
          'Hesabina giris yaparak envanterini, bildirimlerini ve sana ozel tarif onerilerini goruntule.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        CommonTextField(
          label: 'Kullanici Adi',
          hintText: 'kullanici_adi',
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.text,
          controller: usernameController,
        ),
        const SizedBox(height: 18),
        CommonTextField(
          label: 'Sifre',
          hintText: 'Sifrenizi girin',
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
        if (errorMessage != null) ...<Widget>[
          const SizedBox(height: 14),
          _InlineErrorText(message: errorMessage!),
        ],
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: rememberMe,
                onChanged: isSubmitting
                    ? null
                    : (value) => onRememberChanged(value ?? false),
              ),
            ),
            const SizedBox(width: 10),
            Text('Beni hatirla', style: textTheme.bodyMedium),
            const Spacer(),
            TextButton(
              onPressed: () => openScreen(const ForgotPasswordScreen()),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Sifremi Unuttum',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        CommonButton(
          label: isSubmitting ? 'Giris Yapiliyor...' : 'Giris Yap',
          onPressed: isSubmitting ? null : () => onSubmit(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
        const SizedBox(height: 22),
        Row(
          children: <Widget>[
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('VEYA', style: textTheme.labelSmall),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 22),
        CommonButton(
          label: 'Google ile devam et',
          variant: CommonButtonVariant.secondary,
          onPressed: () => openScreen(const GoogleSignInScreen()),
          icon: const _GoogleGlyph(),
        ),
        const SizedBox(height: 26),
        Text.rich(
          TextSpan(
            text: 'Hesabin yok mu? ',
            style: textTheme.bodyMedium,
            children: <InlineSpan>[
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RegisterScreen(),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Kayit Ol',
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

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Text(
        'G',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: const Color(0xFF4285F4),
          fontWeight: FontWeight.w800,
        ),
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
