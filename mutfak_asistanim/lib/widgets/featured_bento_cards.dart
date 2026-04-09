import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AspectRatio(
      aspectRatio: 1.4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
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
              left: -16,
              top: -18,
              child: Container(
                width: 150,
                height: 150,
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
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 54,
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
                        letterSpacing: 0.9,
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
    );
  }
}

class _FeaturedInfoCard extends StatelessWidget {
  const _FeaturedInfoCard({required this.infoCard});

  final FeaturedInfoCardData infoCard;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 220),
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
          const SizedBox(height: 44),
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
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryDim,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(
              infoCard.actionLabel,
              style: textTheme.labelLarge?.copyWith(color: AppColors.primaryDim),
            ),
          ),
        ],
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
