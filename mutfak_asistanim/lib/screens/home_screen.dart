import 'package:flutter/material.dart';

import '../services/mock_kitchen_data_service.dart';
import '../theme/app_colors.dart';
import '../widgets/action_tile.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/product_card.dart';
import '../widgets/suggestion_card.dart';
import 'add_product_screen.dart';
import 'ai_camera_screen.dart';
import 'inventory_screen.dart';
import 'notifications_screen.dart';
import 'recipe_detail_screen.dart';
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
    _QuickActionData(
      label: 'Ürün Tara',
      icon: Icons.center_focus_strong_rounded,
    ),
    _QuickActionData(
      label: 'Alışveriş Listesi',
      icon: Icons.shopping_basket_rounded,
    ),
  ];

  KitchenHomeData? _homeData;
  String? _loadError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final data = await MockKitchenDataService.instance.loadHomeData();
      if (!mounted) {
        return;
      }

      setState(() {
        _homeData = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

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

  void _openSuggestedRecipe() {
    final suggestion = _homeData?.suggestion;
    if (suggestion == null) {
      return;
    }

    Navigator.of(context).pushNamed(
      RecipeDetailScreen.routeName,
      arguments: suggestion.routeArguments,
    );
  }

  void _handleActionTap(BuildContext context, _QuickActionData action) {
    if (action.label == 'Yeni Ürün Ekle') {
      _openAddProduct(context);
      return;
    }
    if (action.label == 'Buzdolabım') {
      Navigator.of(context).pushNamed(InventoryScreen.routeName);
      return;
    }
    if (action.label == 'Ürün Tara') {
      _openAiCamera(context);
      return;
    }
    if (action.label == 'Alışveriş Listesi') {
      Navigator.of(context).pushNamed(ShoppingListScreen.routeName);
    }
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
    final homeData = _homeData;

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
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeSection(
                      textTheme: textTheme,
                      displayName: homeData?.displayName ?? '',
                      description:
                          homeData?.description ??
                          (_isLoading
                              ? 'Mutfak verileri hazırlanıyor...'
                              : 'Tarama ve envanter verileri burada özetlenecek.'),
                      weeklySavingsLabel: homeData?.weeklySavingsLabel ?? '₺0',
                    ),
                    const SizedBox(height: 32),
                    _SectionHeader(
                      title: 'Yakında Bozulacaklar',
                      actionLabel: 'Tümünü Gör',
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(InventoryScreen.routeName);
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildProductsArea(
                      textTheme: textTheme,
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      products: homeData?.products ?? const <ProductCardData>[],
                    ),
                    const SizedBox(height: 32),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 980;

                        final suggestionSection = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Değerlendirme Önerileri',
                              style: textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _buildSuggestionArea(textTheme),
                          ],
                        );
                        final actionsSection = Column(
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
                                  onTap: () =>
                                      _handleActionTap(context, action),
                                ),
                              ),
                            ),
                          ],
                        );

                        if (stacked) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              suggestionSection,
                              const SizedBox(height: 28),
                              actionsSection,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: suggestionSection),
                            const SizedBox(width: 24),
                            Expanded(child: actionsSection),
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

  Widget _buildProductsArea({
    required TextTheme textTheme,
    required int crossAxisCount,
    required double childAspectRatio,
    required List<ProductCardData> products,
  }) {
    if (_isLoading) {
      return const _HomeMessageCard(
        icon: Icons.hourglass_top_rounded,
        title: 'Ürünler hazırlanıyor',
        description: 'Yakın tarihli ürünler birazdan burada listelenecek.',
      );
    }

    if (_loadError != null) {
      return _HomeMessageCard(
        icon: Icons.warning_amber_rounded,
        title: 'Ürün verisi yüklenemedi',
        description: _loadError!,
        actionLabel: 'Tekrar Dene',
        onAction: _loadData,
      );
    }

    if (products.isEmpty) {
      return const _HomeMessageCard(
        icon: Icons.inventory_2_outlined,
        title: 'Henüz ürün yok',
        description:
            'Yeni ürün eklediğinde bu alan bozulmaya yakın ürünleri öne çıkaracak.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }

  Widget _buildSuggestionArea(TextTheme textTheme) {
    if (_isLoading) {
      return const _HomeMessageCard(
        icon: Icons.auto_awesome_rounded,
        title: 'Tarif önerisi hazırlanıyor',
        description: 'Eldeki malzemeler ve son tarih bilgisi taranıyor.',
      );
    }

    if (_loadError != null) {
      return _HomeMessageCard(
        icon: Icons.refresh_rounded,
        title: 'Öneri getirilemedi',
        description: 'Tarif önerisini yenilemek için tekrar deneyin.',
        actionLabel: 'Yenile',
        onAction: _loadData,
      );
    }

    final suggestion = _homeData?.suggestion;
    if (suggestion == null) {
      return const _HomeMessageCard(
        icon: Icons.menu_book_rounded,
        title: 'Tarif önerisi yok',
        description:
            'Envantere ürün ekledikçe uygun tarifleri burada göreceksin.',
      );
    }

    return SuggestionCard(
      title: suggestion.title,
      recipeName: suggestion.recipeName,
      description: suggestion.description,
      buttonLabel: suggestion.buttonLabel,
      onPressed: _openSuggestedRecipe,
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
        final intro = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName.isEmpty ? 'Hoş Geldin' : displayName,
              style: textTheme.displayMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(description, style: textTheme.bodyLarge),
            ),
          ],
        );
        final savingsCard = Align(
          alignment: stacked ? Alignment.centerLeft : Alignment.centerRight,
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
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [intro, const SizedBox(height: 18), savingsCard],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(flex: 8, child: intro),
            const SizedBox(width: 24),
            Expanded(flex: 4, child: savingsCard),
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

class _HomeMessageCard extends StatelessWidget {
  const _HomeMessageCard({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: Text(actionLabel!),
            ),
          ],
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
