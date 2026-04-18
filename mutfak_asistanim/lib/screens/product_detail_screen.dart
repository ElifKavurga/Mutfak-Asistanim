import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/recipe_grid_card.dart';

class ProductDetailRouteData {
  const ProductDetailRouteData({
    required this.title,
    required this.category,
    required this.description,
    required this.amountLabel,
    required this.expiryLabel,
    required this.freshnessValue,
    required this.freshnessPercentLabel,
    required this.isCritical,
    required this.icon,
    required this.heroColors,
    this.imageUrl,
  });

  const ProductDetailRouteData.empty()
    : title = '',
      category = '',
      description = '',
      amountLabel = '',
      expiryLabel = '',
      freshnessValue = 0,
      freshnessPercentLabel = '0%',
      isCritical = false,
      icon = Icons.inventory_2_rounded,
      heroColors = const [Color(0xFFE0E5EA), Color(0xFF95A9C9)],
      imageUrl = null;

  final String title;
  final String category;
  final String description;
  final String amountLabel;
  final String expiryLabel;
  final double freshnessValue;
  final String freshnessPercentLabel;
  final bool isCritical;
  final IconData icon;
  final List<Color> heroColors;
  final String? imageUrl;

  static ProductDetailRouteData fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ProductDetailRouteData) {
      return args;
    }

    return const ProductDetailRouteData.empty();
  }
}

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  static const String routeName = '/product-detail';

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final List<RecipeCardData> _relatedRecipes = [];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final product = ProductDetailRouteData.fromRoute(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 360,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 72,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _TopCircleButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 20,
                end: 20,
                bottom: 16,
              ),
              title: Text(
                'Ürün Detayı',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _HeroBackground(product: product),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.14),
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.96),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    top: 112,
                    child: Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: Icon(product.icon, color: Colors.white, size: 68),
                    ),
                  ),
                  Positioned(
                    right: -30,
                    top: 46,
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    top: 94,
                    child: _HeroChip(
                      label: product.category,
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final stacked = constraints.maxWidth < 920;
                          final detailsPanel = _DetailsPanel(
                            textTheme: textTheme,
                            product: product,
                          );
                          const tipPanel = _ChefTipCard();

                          if (stacked) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                detailsPanel,
                                const SizedBox(height: 20),
                                tipPanel,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 7, child: detailsPanel),
                              const SizedBox(width: 20),
                              const Expanded(flex: 5, child: _ChefTipCard()),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      _RecipeSuggestionsSection(
                        textTheme: textTheme,
                        recipes: _relatedRecipes,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.textTheme, required this.product});

  final TextTheme textTheme;
  final ProductDetailRouteData product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Envanter',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.outline,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.outline,
              ),
              const SizedBox(width: 6),
              Text(
                product.category,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.outline,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            product.title,
            style: textTheme.displaySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.description,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 460;
              final expiryBackground = product.isCritical
                  ? const Color(0xFFF7E2DD)
                  : AppColors.secondaryContainer;
              final expiryAccent = product.isCritical
                  ? const Color(0xFFB94C3A)
                  : AppColors.primary;

              if (compact) {
                return Column(
                  children: [
                    _InfoCard(
                      label: 'Kalan Miktar',
                      value: product.amountLabel,
                      icon: product.icon,
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      label: 'SKT Durumu',
                      value: product.expiryLabel,
                      icon: Icons.warning_amber_rounded,
                      accentColor: expiryAccent,
                      backgroundColor: expiryBackground,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      label: 'Kalan Miktar',
                      value: product.amountLabel,
                      icon: product.icon,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      label: 'SKT Durumu',
                      value: product.expiryLabel,
                      icon: Icons.warning_amber_rounded,
                      accentColor: expiryAccent,
                      backgroundColor: expiryBackground,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Text(
            'Tazelik Oranı',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: constraints.maxWidth * product.freshnessValue,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFFB94C3A), AppColors.primaryDim],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                product.freshnessPercentLabel,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Durum Güncelle',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.outline,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const _PrimaryActionButton(
            title: 'Tüketildi',
            subtitle: 'Envanterden düşer, istatistiklere eklenir',
            icon: Icons.restaurant_rounded,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            iconBackgroundColor: Color(0x2BFFFFFF),
          ),
          const SizedBox(height: 12),
          const _PrimaryActionButton(
            title: 'Çöpe Gitti',
            subtitle: 'Atık raporuna kaydedilir',
            icon: Icons.delete_outline_rounded,
            backgroundColor: Color(0xFFF9ECA6),
            foregroundColor: Color(0xFF5C541D),
            iconBackgroundColor: Color(0x1F5C541D),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Düzenle'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.history_rounded),
                label: const Text('Geçmiş'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.outline,
                  textStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChefTipCard extends StatelessWidget {
  const _ChefTipCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.tips_and_updates_rounded,
              color: Color(0xFF686028),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Şefin İpucu',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ürüne özel ipuçları backend entegrasyonu sonrasında burada gösterilecek.',
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          const Wrap(spacing: 10, runSpacing: 10),
        ],
      ),
    );
  }
}

class _RecipeSuggestionsSection extends StatelessWidget {
  const _RecipeSuggestionsSection({
    required this.textTheme,
    required this.recipes,
  });

  final TextTheme textTheme;
  final List<RecipeCardData> recipes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bu Malzeme ile Ne Pişirilir?',
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'İlgili tarifler backend verisi geldiğinde burada listelenecek.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            if (recipes.isEmpty) {
              return const SizedBox.shrink();
            }

            if (constraints.maxWidth < 760) {
              return Column(
                children: List.generate(recipes.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == recipes.length - 1 ? 0 : 20,
                    ),
                    child: RecipeGridCard(recipe: recipes[index]),
                  );
                }),
              );
            }

            if (constraints.maxWidth < 1080) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recipes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 360,
                ),
                itemBuilder: (context, index) {
                  return RecipeGridCard(recipe: recipes[index]);
                },
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(recipes.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == recipes.length - 1 ? 0 : 18),
                    child: RecipeGridCard(recipe: recipes[index]),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.product});

  final ProductDetailRouteData product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl;
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _HeroPlaceholder(product: product);
        },
      );
    }

    return _HeroPlaceholder(product: product);
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.product});

  final ProductDetailRouteData product;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: product.heroColors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: 40,
            top: 72,
            child: Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 32,
            top: 122,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(product.icon, size: 58, color: Colors.white),
            ),
          ),
          Positioned(
            right: 26,
            bottom: 54,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Text(
                'Görsel backend üzerinden gelecek',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  const _TopCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor = AppColors.primary,
    this.backgroundColor = AppColors.surfaceContainerLow,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.outline,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: textTheme.titleLarge?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.iconBackgroundColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: foregroundColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: foregroundColor.withValues(alpha: 0.86),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: foregroundColor),
            ],
          ),
        ),
      ),
    );
  }
}
