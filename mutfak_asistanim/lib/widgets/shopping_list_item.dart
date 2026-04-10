import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum ShoppingListVisualType { icon, image }

class ShoppingListVisual {
  const ShoppingListVisual.icon({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  }) : type = ShoppingListVisualType.icon,
       imageUrl = null;

  const ShoppingListVisual.image({
    required this.imageUrl,
  }) : type = ShoppingListVisualType.image,
       icon = null,
       backgroundColor = null,
       foregroundColor = null;

  final ShoppingListVisualType type;
  final IconData? icon;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? foregroundColor;
}

class ShoppingListItemData {
  const ShoppingListItemData({
    required this.name,
    required this.quantity,
    required this.visual,
    this.isChecked = false,
  });

  final String name;
  final String quantity;
  final bool isChecked;
  final ShoppingListVisual visual;

  ShoppingListItemData copyWith({bool? isChecked}) {
    return ShoppingListItemData(
      name: name,
      quantity: quantity,
      visual: visual,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

class ShoppingListItem extends StatelessWidget {
  const ShoppingListItem({
    super.key,
    required this.item,
    required this.onChanged,
  });

  final ShoppingListItemData item;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final itemOpacity = item.isChecked ? 0.48 : 1.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: itemOpacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Transform.scale(
              scale: 1.18,
              child: Checkbox(
                value: item.isChecked,
                onChanged: (value) => onChanged(value ?? false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      decoration: item.isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.quantity,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _ItemVisual(visual: item.visual, faded: item.isChecked),
          ],
        ),
      ),
    );
  }
}

class _ItemVisual extends StatelessWidget {
  const _ItemVisual({required this.visual, required this.faded});

  final ShoppingListVisual visual;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final baseDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      boxShadow: faded
          ? const []
          : const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
    );

    if (visual.type == ShoppingListVisualType.image && visual.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 54,
          height: 54,
          child: Image.network(
            visual.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _FallbackVisual(
                decoration: baseDecoration.copyWith(color: AppColors.surfaceContainerLow),
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: 54,
      height: 54,
      decoration: baseDecoration.copyWith(color: visual.backgroundColor),
      child: Icon(
        visual.icon,
        color: visual.foregroundColor,
        size: 28,
      ),
    );
  }
}

class _FallbackVisual extends StatelessWidget {
  const _FallbackVisual({required this.decoration});

  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.outline,
      ),
    );
  }
}
