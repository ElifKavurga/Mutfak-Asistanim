import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/featured_bento_cards.dart';
import '../widgets/recipe_filter_chip.dart';
import '../widgets/recipe_grid_card.dart';

class DiscoverRecipesScreen extends StatefulWidget {
  const DiscoverRecipesScreen({super.key});

  static const String routeName = '/discover-recipes';

  @override
  State<DiscoverRecipesScreen> createState() => _DiscoverRecipesScreenState();
}

class _DiscoverRecipesScreenState extends State<DiscoverRecipesScreen> {
  static const List<String> _filters = [
    'Hepsi',
    'Kahvaltı',
    'Vegan',
    'Pratik',
    'Tatlılar',
  ];

  static const FeaturedRecipeData _featuredRecipe = FeaturedRecipeData(
    badge: 'Zero Waste',
    title: 'Renkli Hasat Salatası',
    duration: '15 dk',
    sustainabilityLabel: 'Low Carbon',
    gradientColors: [Color(0xFF7BA05B), Color(0xFF36543D)],
  );

  static const FeaturedInfoCardData _featuredInfo = FeaturedInfoCardData(
    title: 'Hızlı & Ekolojik',
    description:
        'Kalan malzemelerle 10 dakikada hazırlayabileceğin özel tarif seçkisi seni bekliyor.',
    actionLabel: 'Keşfet',
  );

  static const List<RecipeCardData> _recipes = [
    RecipeCardData(
      title: 'Çilekli Roka Şöleni',
      duration: '10 dk',
      tag: 'ZERO WASTE',
      gradientColors: [Color(0xFFDC8C7E), Color(0xFF8D4E51)],
      icon: Icons.local_florist_rounded,
    ),
    RecipeCardData(
      title: 'Fırınlanmış Sebze Kasesi',
      duration: '25 dk',
      tag: 'LOW CARBON',
      gradientColors: [Color(0xFFB9A35F), Color(0xFF6D5E30)],
      icon: Icons.ramen_dining_rounded,
    ),
    RecipeCardData(
      title: 'Ekşi Mayalı Sebzeli Pizza',
      duration: '45 dk',
      tag: 'VEGAN',
      gradientColors: [Color(0xFF95B57C), Color(0xFF4A704F)],
      icon: Icons.local_pizza_rounded,
    ),
    RecipeCardData(
      title: 'Közlenmiş Balkabağı Çorbası',
      duration: '20 dk',
      tag: 'ZERO WASTE',
      gradientColors: [Color(0xFFE0A15A), Color(0xFFA75A2A)],
      icon: Icons.soup_kitchen_rounded,
    ),
  ];

  static const _SeasonalHighlightData _seasonalHighlight =
      _SeasonalHighlightData(
        eyebrow: 'Mevsimin Gözdesi',
        title: 'Baharın En Taze Enginar Tarifleri',
        description:
            'Mevsiminde tüketmek hem sağlığın hem de gezegenimiz için en iyisi. Enginarın sürdürülebilir ve pratik yorumlarını keşfet.',
        actionLabel: 'Koleksiyonu Gör',
      );

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = _filters.first;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 118),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchAndFilters(
                    controller: _searchController,
                    filters: _filters,
                    selectedFilter: _selectedFilter,
                    onFilterSelected: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Günün İlhamı',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const FeaturedBentoCards(
                    featuredRecipe: _featuredRecipe,
                    infoCard: _featuredInfo,
                  ),
                  const SizedBox(height: 40),
                  _DiscoveryHeader(textTheme: textTheme),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      const crossAxisSpacing = 18.0;
                      const mainAxisSpacing = 22.0;
                      final crossAxisCount = width >= 1100
                          ? 4
                          : width >= 700
                          ? 2
                          : 1;
                      final cardWidth =
                          (width - ((crossAxisCount - 1) * crossAxisSpacing)) /
                          crossAxisCount;
                      final imageHeight = cardWidth * 1.25;
                      final mainAxisExtent = imageHeight + 92;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recipes.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: crossAxisSpacing,
                          mainAxisSpacing: mainAxisSpacing,
                          mainAxisExtent: mainAxisExtent,
                        ),
                        itemBuilder: (context, index) {
                          return RecipeGridCard(recipe: _recipes[index]);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  const _SeasonalHighlightSection(data: _seasonalHighlight),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const DashboardBottomNav(
        activeTab: DashboardTab.recipes,
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final TextEditingController controller;
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Hangi malzemelerle yemek yapmak istersin?',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              final selected = filter == selectedFilter;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: RecipeFilterChip(
                  label: filter,
                  selected: selected,
                  onTap: () => onFilterSelected(filter),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DiscoveryHeader extends StatelessWidget {
  const _DiscoveryHeader({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      runSpacing: 12,
      spacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yeni Tarifler',
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sürdürülebilir mutfak için taze fikirler',
              style: textTheme.bodyLarge,
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Hepsini Gör',
            style: textTheme.labelLarge?.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _SeasonalHighlightSection extends StatelessWidget {
  const _SeasonalHighlightSection({required this.data});

  final _SeasonalHighlightData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 920;
        final textContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.eyebrow,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data.title,
              style: textTheme.headlineLarge?.copyWith(
                color: AppColors.primaryDim,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Text(
                data.description,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
              ),
              child: Text(
                data.actionLabel,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.secondaryContainer.withValues(alpha: 0.88),
                AppColors.surfaceContainerLow,
              ],
            ),
          ),
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textContent,
                    const SizedBox(height: 24),
                    const _SeasonalVisual(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 6, child: textContent),
                    const SizedBox(width: 24),
                    const Expanded(flex: 5, child: _SeasonalVisual()),
                  ],
                ),
        );
      },
    );
  }
}

class _SeasonalVisual extends StatelessWidget {
  const _SeasonalVisual();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF90A86D), Color(0xFF4D653B)],
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: -18,
              bottom: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              right: 18,
              top: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'BAHAR SEÇKİSİ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.spa_rounded,
                size: 92,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonalHighlightData {
  const _SeasonalHighlightData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.actionLabel,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String actionLabel;
}
