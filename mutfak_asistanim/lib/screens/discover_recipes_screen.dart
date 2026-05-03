import 'package:flutter/material.dart';

import '../services/backend_api_service.dart';
import '../services/mock_kitchen_data_service.dart';
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
  final TextEditingController _searchController = TextEditingController();

  KitchenRecipeDiscoveryData? _data;
  String? _loadError;
  String? _selectedFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChange);
    _loadData();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChange)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final data = await BackendApiService.instance.loadRecipeDiscoveryData();
      if (!mounted) {
        return;
      }

      setState(() {
        _data = data;
        final previousFilter = _selectedFilter;
        _selectedFilter = data.categories.contains(previousFilter)
            ? previousFilter
            : (data.categories.isNotEmpty ? data.categories.first : null);
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

  void _handleSearchChange() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  List<RecipeCardData> get _visibleRecipes {
    final data = _data;
    if (data == null) {
      return const <RecipeCardData>[];
    }

    final selectedFilter = _selectedFilter ?? BackendApiService.allFilterLabel;
    final query = _searchController.text.trim().toLowerCase();

    return data.recipes
        .where((recipe) {
          final matchesFilter =
              selectedFilter == BackendApiService.allFilterLabel ||
              recipe.tag == selectedFilter;
          if (!matchesFilter) {
            return false;
          }

          if (query.isEmpty) {
            return true;
          }

          final haystack = <String>[
            recipe.title,
            recipe.tag,
            ...recipe.searchKeywords,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);
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
          'MutfakAsistanim',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
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
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 118),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: _buildBody(textTheme),
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

  Widget _buildBody(TextTheme textTheme) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 120),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return _RecipesErrorState(message: _loadError!, onRetry: _loadData);
    }

    final data = _data;
    if (data == null) {
      return _RecipesErrorState(
        message: 'Tarifler su anda yuklenemedi.',
        onRetry: _loadData,
      );
    }

    final recipes = _visibleRecipes;
    final selectedFilter = _selectedFilter ?? data.categories.first;
    final hasSearchQuery = _searchController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SearchAndFilters(
          controller: _searchController,
          categories: data.categories,
          selectedFilter: selectedFilter,
          onFilterSelected: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
        ),
        const SizedBox(height: 36),
        Text(
          'Bugun Ne Pisirsem?',
          style: textTheme.headlineMedium?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 18),
        FeaturedBentoCards(
          featuredRecipe: data.featuredRecipe,
          infoCard: data.infoCard,
        ),
        const SizedBox(height: 40),
        _DiscoveryHeader(
          textTheme: textTheme,
          totalRecipeCount: recipes.length,
          onResetFilter: () {
            setState(() {
              _selectedFilter = BackendApiService.allFilterLabel;
            });
          },
        ),
        const SizedBox(height: 22),
        if (recipes.isEmpty)
          _RecipesEmptyState(
            hasSearchQuery: hasSearchQuery,
          )
        else
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
                itemCount: recipes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  mainAxisExtent: mainAxisExtent,
                ),
                itemBuilder: (context, index) {
                  return RecipeGridCard(recipe: recipes[index]);
                },
              );
            },
          ),
        const SizedBox(height: 40),
        _SeasonalHighlightSection(data: data.seasonalHighlight),
      ],
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.categories,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final TextEditingController controller;
  final List<String> categories;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Malzeme veya tarif ara',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories
                .map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: RecipeFilterChip(
                      label: filter,
                      selected: filter == selectedFilter,
                      onTap: () => onFilterSelected(filter),
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _DiscoveryHeader extends StatelessWidget {
  const _DiscoveryHeader({
    required this.textTheme,
    required this.totalRecipeCount,
    required this.onResetFilter,
  });

  final TextTheme textTheme;
  final int totalRecipeCount;
  final VoidCallback onResetFilter;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      runSpacing: 12,
      spacing: 12,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Tarifler',
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$totalRecipeCount tarif senin icin listelendi',
              style: textTheme.bodyLarge,
            ),
          ],
        ),
        TextButton(
          onPressed: onResetFilter,
          child: Text(
            'Onerilenleri Gor',
            style: textTheme.labelLarge?.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _SeasonalHighlightSection extends StatelessWidget {
  const _SeasonalHighlightSection({required this.data});

  final KitchenSeasonalHighlightData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 920;
        final textContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
              colors: <Color>[
                AppColors.secondaryContainer.withValues(alpha: 0.88),
                AppColors.surfaceContainerLow,
              ],
            ),
          ),
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    textContent,
                    const SizedBox(height: 24),
                    const _SeasonalVisual(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
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
            colors: <Color>[Color(0xFF90A86D), Color(0xFF4D653B)],
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
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
                  'PLAN',
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
              child: Icon(Icons.spa_rounded, size: 92, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipesEmptyState extends StatelessWidget {
  const _RecipesEmptyState({required this.hasSearchQuery});

  final bool hasSearchQuery;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = hasSearchQuery
        ? 'Aramana uygun tarif bulunamadi'
        : 'Bu filtrede gosterilecek tarif bulunamadi';
    final description = hasSearchQuery
        ? 'Aramani biraz daha genisletebilir veya farkli bir filtre deneyebilirsin.'
        : 'Farkli bir kategori secerek yeni tarifler inceleyebilirsin.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.search_off_rounded,
            color: AppColors.primary,
            size: 44,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipesErrorState extends StatelessWidget {
  const _RecipesErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFB94C3A),
                size: 42,
              ),
              const SizedBox(height: 14),
              Text(
                'Tarifler yuklenemedi',
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
