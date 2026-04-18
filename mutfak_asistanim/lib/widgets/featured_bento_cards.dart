import 'package:flutter/material.dart';

import '../screens/recipe_detail_screen.dart';
import '../theme/app_colors.dart';

class FeaturedRecipeData {
  const FeaturedRecipeData({
    required this.badge,
    required this.title,
    required this.duration,
    required this.sustainabilityLabel,
    required this.gradientColors,
  });

  final String badge;
  final String title;
  final String duration;
  final String sustainabilityLabel;
  final List<Color> gradientColors;
}

class FeaturedInfoCardData {
  const FeaturedInfoCardData({
    required this.title,
    required this.description,
    required this.actionLabel,
  });

  final String title;
  final String description;
  final String actionLabel;
}

class FeaturedBentoCards extends StatelessWidget {
  const FeaturedBentoCards({
    super.key,
    required this.featuredRecipe,
    required this.infoCard,
  });

  final FeaturedRecipeData featuredRecipe;
  final FeaturedInfoCardData infoCard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 860;

        if (stacked) {
          return Column(
            children: [
              _FeaturedRecipeCard(recipe: featuredRecipe),
              const SizedBox(height: 18),
              _FeaturedInfoCard(infoCard: infoCard),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _FeaturedRecipeCard(recipe: featuredRecipe),
            ),
            const SizedBox(width: 18),
            Expanded(child: _FeaturedInfoCard(infoCard: infoCard)),
          ],
        );
      },
    );
  }
}

class _FeaturedRecipeCard extends StatelessWidget {
  const _FeaturedRecipeCard({required this.recipe});

  final FeaturedRecipeData recipe;

  void _openRecipeDetail(BuildContext context) {
    Navigator.of(context).pushNamed(
      RecipeDetailScreen.routeName,
      arguments: {
        'title': recipe.title,
        'duration': recipe.duration,
        'tag': recipe.badge.toUpperCase(),
        'gradientColors': recipe.gradientColors,
        'icon': Icons.energy_savings_leaf_rounded,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AspectRatio(
      aspectRatio: 1.34,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openRecipeDetail(context),
          borderRadius: BorderRadius.circular(34),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: recipe.gradientColors,
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
                  left: -34,
                  top: -44,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  right: 22,
                  top: 22,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDim.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.energy_savings_leaf_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  bottom: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          recipe.badge,
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        recipe.title,
                        style: textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        children: [
                          _FeatureMeta(
                            icon: Icons.schedule_rounded,
                            label: recipe.duration,
                          ),
                          _FeatureMeta(
                            icon: Icons.energy_savings_leaf_rounded,
                            label: recipe.sustainabilityLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedInfoCard extends StatelessWidget {
  const _FeaturedInfoCard({required this.infoCard});

  final FeaturedInfoCardData infoCard;

  void _openRecipeDetail(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamed(RecipeDetailScreen.routeName, arguments: const <String, dynamic>{});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openRecipeDetail(context),
        borderRadius: BorderRadius.circular(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 220),
          child: Ink(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.tertiaryContainer),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.primaryDim,
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  infoCard.title,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryDim,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  infoCard.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () => _openRecipeDetail(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryDim,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        infoCard.actionLabel,
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primaryDim,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureMeta extends StatelessWidget {
  const _FeatureMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
