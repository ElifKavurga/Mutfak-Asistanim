import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'common_button.dart';

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    required this.title,
    required this.recipeName,
    required this.description,
  });

  final String title;
  final String recipeName;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -44,
            top: -58,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.primaryDim.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 26,
            bottom: -34,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  title,
                  style: textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Text(
                  recipeName,
                  style: textTheme.headlineLarge?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Text(
                  description,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: 170,
                child: CommonButton(
                  label: 'Tarife Git',
                  onPressed: () {},
                  variant: CommonButtonVariant.secondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
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
