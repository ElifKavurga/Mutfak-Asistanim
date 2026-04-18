import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/action_tile.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/product_card.dart';
import '../widgets/suggestion_card.dart';
import 'add_product_screen.dart';
import 'ai_camera_screen.dart';
import 'inventory_screen.dart';
import 'notifications_screen.dart';
import 'shopping_list_screen.dart';
import 'stats_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<_QuickActionData> _actions = [
    _QuickActionData(label: 'Yeni Ürün Ekle', icon: Icons.add_circle_rounded),
    _QuickActionData(label: 'Buzdolabım', icon: Icons.inventory_2_rounded),
    _QuickActionData(label: 'Barkod Tara', icon: Icons.qr_code_scanner_rounded),
    _QuickActionData(
      label: 'Alışveriş Listesi',
      icon: Icons.shopping_basket_rounded,
    ),
  ];

  final List<ProductCardData> _products = [];
  final String _displayName = '';
  final String _welcomeDescription = '';
  final String _weeklySavingsLabel = '₺0';
  final String _suggestionTitle = '';
  final String _suggestionRecipeName = '';
  final String _suggestionDescription = '';

  void _openAddProduct(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AddProductScreen()));
  }

  void _openAiCamera(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AiCameraScreen()));
  }

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
            padding: const EdgeInsets.only(right: 2),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(NotificationsScreen.routeName);
              },
              icon: const Icon(Icons.notifications_none_rounded),
              tooltip: 'Bildirimler',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pushNamed(StatsProfileScreen.routeName);
              },
              radius: 24,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.account_circle_rounded),
              ),
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
                  _WelcomeSection(
                    textTheme: textTheme,
                    displayName: _displayName,
                    description: _welcomeDescription,
                    weeklySavingsLabel: _weeklySavingsLabel,
                  ),
                  const SizedBox(height: 32),
                  _SectionHeader(
                    title: 'Yakında Bozulacaklar',
                    actionLabel: 'Tümünü Gör',
                    onTap: () {
                      Navigator.of(context).pushNamed(InventoryScreen.routeName);
                    },
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
                                SuggestionCard(
                                  title: _suggestionTitle,
                                  recipeName: _suggestionRecipeName,
                                  description: _suggestionDescription,
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
                                      onTap: () {
                                        if (action.label == 'Yeni Ürün Ekle') {
                                          _openAddProduct(context);
                                        }
                                        if (action.label == 'Buzdolabım') {
                                          Navigator.of(context).pushNamed(
                                            InventoryScreen.routeName,
                                          );
                                        }
                                        if (action.icon ==
                                            Icons.qr_code_scanner_rounded) {
                                          _openAiCamera(context);
                                        }
                                        if (action.icon ==
                                            Icons.shopping_basket_rounded) {
                                          Navigator.of(context).pushNamed(
                                            ShoppingListScreen.routeName,
                                          );
                                        }
                                      },
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
      bottomNavigationBar: const DashboardBottomNav(
        activeTab: DashboardTab.kitchen,
      ),
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
          onPressed: () => _openAddProduct(context),
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
  const _WelcomeSection({
    required this.textTheme,
    required this.displayName,
    required this.description,
    required this.weeklySavingsLabel,
  });

  final TextTheme textTheme;
  final String displayName;
  final String description;
  final String weeklySavingsLabel;

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
                    displayName.isEmpty ? 'Hoş Geldin' : 'Hoş Geldin, $displayName',
                    style: textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Text(
                      description,
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
                            weeklySavingsLabel,
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

class _QuickActionData {
  const _QuickActionData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
