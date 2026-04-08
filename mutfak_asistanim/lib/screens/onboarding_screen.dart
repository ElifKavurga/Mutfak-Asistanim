import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/common_button.dart';
import '../widgets/decorative_background.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'İsrafı Önle',
      description: 'Mutfağındaki malzemeleri akıllıca yöneterek israfı azalt.',
      centerIcon: Icons.recycling_rounded,
      backgroundIcon: Icons.spa_rounded,
      topIcon: Icons.restaurant_rounded,
      bottomIcon: Icons.eco_rounded,
      topChipColor: AppColors.secondaryContainer,
      bottomChipColor: AppColors.primaryContainer,
      topIconColor: AppColors.secondary,
      bottomIconColor: AppColors.primary,
    ),
    _OnboardingPageData(
      title: 'Akıllı Takip',
      description: 'Ürünlerinin son kullanma tarihlerini kolayca takip et.',
      centerIcon: Icons.event_note_rounded,
      backgroundIcon: Icons.schedule_rounded,
      topIcon: Icons.notifications_active_rounded,
      bottomIcon: Icons.inventory_2_rounded,
      topChipColor: AppColors.tertiaryContainer,
      bottomChipColor: AppColors.secondaryContainer,
      topIconColor: AppColors.primaryDim,
      bottomIconColor: AppColors.secondary,
    ),
    _OnboardingPageData(
      title: 'Tarif Önerileri',
      description: 'Elindeki malzemelerle yapabileceğin tarifleri keşfet.',
      centerIcon: Icons.menu_book_rounded,
      backgroundIcon: Icons.ramen_dining_rounded,
      topIcon: Icons.tips_and_updates_rounded,
      bottomIcon: Icons.local_dining_rounded,
      topChipColor: AppColors.primaryContainer,
      bottomChipColor: AppColors.tertiaryContainer,
      topIconColor: AppColors.primary,
      bottomIconColor: AppColors.primaryDim,
    ),
    _OnboardingPageData(
      title: 'Tasarruf Et',
      description: 'Hem bütçeni hem doğayı koru.',
      centerIcon: Icons.savings_rounded,
      backgroundIcon: Icons.energy_savings_leaf_rounded,
      topIcon: Icons.payments_rounded,
      bottomIcon: Icons.eco_rounded,
      topChipColor: AppColors.secondaryContainer,
      bottomChipColor: AppColors.primaryContainer,
      topIconColor: AppColors.secondary,
      bottomIconColor: AppColors.primary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
  }

  void _handleContinue() {
    if (_currentPage == _pages.length - 1) {
      _goToLogin();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 470),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 48,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'MutfakAsistanım',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        height: 520,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _pages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final page = _pages[index];
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _OnboardingIllustration(data: page),
                                        const SizedBox(height: 36),
                                        Text(
                                          page.title,
                                          textAlign: TextAlign.center,
                                          style: textTheme.displayMedium,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          page.description,
                                          textAlign: TextAlign.center,
                                          style: textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == _pages.length - 1 ? 0 : 8,
                            ),
                            child: _ProgressDash(
                              width: _currentPage == index ? 36 : 10,
                              active: _currentPage == index,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 36),
                      CommonButton(
                        label: _currentPage == _pages.length - 1
                            ? 'Başla'
                            : 'Devam Et',
                        onPressed: _handleContinue,
                      ),
                      const SizedBox(height: 10),
                      CommonButton(
                        label: 'Atla',
                        variant: CommonButtonVariant.ghost,
                        onPressed: _goToLogin,
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

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.centerIcon,
    required this.backgroundIcon,
    required this.topIcon,
    required this.bottomIcon,
    required this.topChipColor,
    required this.bottomChipColor,
    required this.topIconColor,
    required this.bottomIconColor,
  });

  final String title;
  final String description;
  final IconData centerIcon;
  final IconData backgroundIcon;
  final IconData topIcon;
  final IconData bottomIcon;
  final Color topChipColor;
  final Color bottomChipColor;
  final Color topIconColor;
  final Color bottomIconColor;
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            top: 26,
            right: 34,
            child: _FloatChip(
              color: data.topChipColor,
              icon: data.topIcon,
              iconColor: data.topIconColor,
            ),
          ),
          Positioned(
            bottom: 36,
            left: 24,
            child: _FloatChip(
              color: data.bottomChipColor,
              icon: data.bottomIcon,
              iconColor: data.bottomIconColor,
              circular: true,
            ),
          ),
          Transform.rotate(
            angle: -0.24,
            child: Icon(
              data.backgroundIcon,
              size: 170,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: 168,
            height: 168,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.16),
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 18,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(data.centerIcon, size: 64, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatChip extends StatelessWidget {
  const _FloatChip({
    required this.color,
    required this.icon,
    required this.iconColor,
    this.circular = false,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(circular ? 999 : 22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}

class _ProgressDash extends StatelessWidget {
  const _ProgressDash({required this.width, this.active = false});

  final double width;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: active
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDim],
              )
            : null,
        color: active ? null : AppColors.surfaceContainerHigh,
      ),
    );
  }
}
