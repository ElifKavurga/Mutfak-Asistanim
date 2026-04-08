import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/action_tile.dart';
import '../widgets/product_card.dart';
import '../widgets/suggestion_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  static const List<ProductCardData> _products = [
    ProductCardData(
      name: 'Taze Çilek',
      location: 'Buzdolabı',
      quantity: '500 g',
      remainingLabel: '2 gün kaldı',
      categories: ['TATLI', 'SMOOTHIE'],
      icon: Icons.local_florist_rounded,
      backgroundColors: [Color(0xFFEB7B86), Color(0xFFC55262)],
    ),
    ProductCardData(
      name: 'Ispanak',
      location: 'Sebzelik',
      quantity: '1 bağ',
      remainingLabel: '1 gün kaldı',
      categories: ['YEMEK', 'SALATA'],
      icon: Icons.eco_rounded,
      backgroundColors: [Color(0xFF8EBF83), Color(0xFF5B8F57)],
    ),
    ProductCardData(
      name: 'Organik Süt',
      location: 'Kapak Rafı',
      quantity: '1 L',
      remainingLabel: '3 gün kaldı',
      categories: ['KAHVALTI'],
      icon: Icons.local_drink_rounded,
      backgroundColors: [Color(0xFF8FA8D9), Color(0xFF6783BC)],
    ),
    ProductCardData(
      name: 'Akdeniz Yeşillikleri',
      location: 'Sebzelik',
      quantity: '200 g',
      remainingLabel: 'Bugün',
      categories: ['DÜŞÜK ATIK'],
      icon: Icons.spa_rounded,
      backgroundColors: [Color(0xFF9DBA86), Color(0xFF6C8E54)],
    ),
  ];

  static const List<_QuickActionData> _actions = [
    _QuickActionData(label: 'Yeni Ürün Ekle', icon: Icons.add_circle_rounded),
    _QuickActionData(label: 'Barkod Tara', icon: Icons.qr_code_scanner_rounded),
    _QuickActionData(
      label: 'Alışveriş Listesi',
      icon: Icons.shopping_basket_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1200
        ? 4
        : width >= 760
        ? 2
        : 1;
    final childAspectRatio = width >= 1200
        ? 0.84
        : width >= 760
        ? 0.92
        : 1.08;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 72,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu_rounded),
        ),
        title: Text(
          'MutfakAsistanım',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WelcomeSection(textTheme: textTheme),
                  const SizedBox(height: 32),
                  _SectionHeader(
                    title: 'Yakında Bozulacaklar',
                    actionLabel: 'Tümünü Gör',
                    onTap: () {},
                  ),
                  const SizedBox(height: 18),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      return ProductCard(product: _products[index]);
                    },
                  ),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 980;

                      return Flex(
                        direction: stacked ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: stacked ? 0 : 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Değerlendirme Önerileri',
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const SuggestionCard(
                                  title: 'GÜNÜN KURTARICISI',
                                  recipeName:
                                      'Ispanaklı ve Çilekli Bahar Salatası',
                                  description:
                                      'Elindeki ıspanak ve çilekleri değerlendirmenin en ferah yolu. Sadece 10 dakikada hazır!',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: stacked ? 0 : 24,
                            height: stacked ? 28 : 0,
                          ),
                          Expanded(
                            flex: stacked ? 0 : 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hızlı Aksiyonlar',
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                ..._actions.map(
                                  (action) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: ActionTile(
                                      icon: action.icon,
                                      label: action.label,
                                      onTap: () {},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _DashboardBottomNav(),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 840;

        return Flex(
          direction: stacked ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: stacked
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: stacked ? 0 : 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş Geldin, Şef',
                    style: textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Text(
                      'Mutfaktaki sürdürülebilir yolculuğunda bugün 4 ürünün dikkatini bekliyor.',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: stacked ? 0 : 24, height: stacked ? 18 : 0),
            Expanded(
              flex: stacked ? 0 : 4,
              child: Align(
                alignment: stacked
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Haftalık Tasarruf',
                            style: textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₺240',
                            style: textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.headlineMedium?.copyWith(color: AppColors.primary),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionLabel,
            style: textTheme.labelLarge?.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 22,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.kitchen_rounded,
              label: 'Mutfak',
              active: true,
            ),
            _BottomNavItem(
              icon: Icons.restaurant_menu_rounded,
              label: 'Tarifler',
            ),
            _BottomNavItem(icon: Icons.calendar_today_rounded, label: 'Planla'),
            _BottomNavItem(icon: Icons.person_rounded, label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? AppColors.onPrimary : AppColors.primary,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: active ? AppColors.onPrimary : AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
