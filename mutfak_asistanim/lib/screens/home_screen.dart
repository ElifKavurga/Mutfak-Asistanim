import 'package:flutter/material.dart';

import '../services/backend_api_service.dart';
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
  static const List<_QuickActionData> _actions = <_QuickActionData>[
    _QuickActionData(label: 'Yeni Urun Ekle', icon: Icons.add_circle_rounded),
    _QuickActionData(label: 'Buzdolabim', icon: Icons.inventory_2_rounded),
    _QuickActionData(
      label: 'Urun Tara',
      icon: Icons.center_focus_strong_rounded,
    ),
    _QuickActionData(
      label: 'Alisveris Listesi',
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
      final data = await BackendApiService.instance.loadHomeData();
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

  Future<void> _openAddProduct(BuildContext context) async {
    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const AddProductScreen()),
    );
    if (didSave == true && mounted) {
      await _loadData();
    }
  }

  Future<void> _openAiCamera(BuildContext context) async {
    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const AiCameraScreen()),
    );
    if (didSave == true && mounted) {
      await _loadData();
    }
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
    switch (action.label) {
      case 'Yeni Urun Ekle':
        _openAddProduct(context);
        return;
      case 'Buzdolabim':
        Navigator.of(context).pushNamed(InventoryScreen.routeName);
        return;
      case 'Urun Tara':
        _openAiCamera(context);
        return;
      case 'Alisveris Listesi':
        Navigator.of(context).pushNamed(ShoppingListScreen.routeName);
        return;
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
          'MutfakAsistanim',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
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
                  children: <Widget>[
                    _WelcomeSection(
                      textTheme: textTheme,
                      displayName: homeData?.displayName ?? '',
                      description:
                          homeData?.description ??
                          (_isLoading
                              ? 'Mutfagin hazirlaniyor...'
                              : 'Mutfak ozetin burada gorunecek.'),
                      summaryValue: homeData?.weeklySavingsLabel ?? '0',
                    ),
                    const SizedBox(height: 32),
                    _SectionHeader(
                      title: 'Yakinda Bozulacaklar',
                      actionLabel: 'Tumunu Gor',
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
                          children: <Widget>[
                            Text(
                              'Tarif Onerisi',
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
                          children: <Widget>[
                            Text(
                              'Hizli Aksiyonlar',
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
                            children: <Widget>[
                              suggestionSection,
                              const SizedBox(height: 28),
                              actionsSection,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
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
          boxShadow: <BoxShadow>[
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
        title: 'Urunler yukleniyor',
        description:
            'Son kullanma tarihi yaklasan urunleri burada gorebilirsin.',
      );
    }

    if (_loadError != null) {
      return _HomeMessageCard(
        icon: Icons.warning_amber_rounded,
        title: 'Urun verisi yuklenemedi',
        description: _loadError!,
        actionLabel: 'Tekrar Dene',
        onAction: _loadData,
      );
    }

    if (products.isEmpty) {
      return const _HomeMessageCard(
        icon: Icons.inventory_2_outlined,
        title: 'Henuz urun eklenmedi',
        description:
            'Ilk urunlerini eklediginde yakinda tuketilmesi gerekenler burada gorunur.',
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
        title: 'Tarif onerileri hazirlaniyor',
        description: 'Envanterine uygun tarifler senin icin seciliyor.',
      );
    }

    if (_loadError != null) {
      return _HomeMessageCard(
        icon: Icons.refresh_rounded,
        title: 'Tarif onerileri gosterilemiyor',
        description: 'Su anda tarif onerileri getirilemedi. Lutfen tekrar dene.',
        actionLabel: 'Yenile',
        onAction: _loadData,
      );
    }

    final suggestion = _homeData?.suggestion;
    if (suggestion == null) {
      return const _HomeMessageCard(
        icon: Icons.menu_book_rounded,
        title: 'Henuz tarif onerisi yok',
        description:
            'Envanterine urun eklendikce sana uygun tarif onerileri burada gorunur.',
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
    required this.summaryValue,
  });

  final TextTheme textTheme;
  final String displayName;
  final String description;
  final String summaryValue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 840;
        final intro = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              displayName.isEmpty ? 'Hos Geldin' : displayName,
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
        final summaryCard = Align(
          alignment: stacked ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Toplam Urun',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summaryValue,
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
            children: <Widget>[intro, const SizedBox(height: 18), summaryCard],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(flex: 8, child: intro),
            const SizedBox(width: 24),
            Expanded(flex: 4, child: summaryCard),
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
      children: <Widget>[
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
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
          if (actionLabel != null && onAction != null) ...<Widget>[
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
