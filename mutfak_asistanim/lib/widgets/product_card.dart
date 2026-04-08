import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ProductCardData {
  const ProductCardData({
    required this.name,
    required this.location,
    required this.quantity,
    required this.remainingLabel,
    required this.categories,
    required this.icon,
    required this.backgroundColors,
  });

  final String name;
  final String location;
  final String quantity;
  final String remainingLabel;
  final List<String> categories;
  final IconData icon;
  final List<Color> backgroundColors;
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductCardData product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 170,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              gradient: LinearGradient(colors: product.backgroundColors),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -12,
                  top: -8,
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 18,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(product.icon, size: 36, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFD795A),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      product.remainingLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${product.location} • ${product.quantity}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: product.categories.map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        category,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
