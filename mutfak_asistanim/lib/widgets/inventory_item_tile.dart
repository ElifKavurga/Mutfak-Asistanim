import 'package:flutter/material.dart';

import '../screens/product_detail_screen.dart';
import '../theme/app_colors.dart';

class InventoryItemData {
  const InventoryItemData({
    required this.name,
    required this.statusLabel,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.icon,
    required this.backgroundColors,
    required this.isCritical,
  });

  final String name;
  final String statusLabel;
  final int quantity;
  final String unit;
  final String category;
  final IconData icon;
  final List<Color> backgroundColors;
  final bool isCritical;

  InventoryItemData copyWith({int? quantity}) {
    return InventoryItemData(
      name: name,
      statusLabel: statusLabel,
      quantity: quantity ?? this.quantity,
      unit: unit,
      category: category,
      icon: icon,
      backgroundColors: backgroundColors,
      isCritical: isCritical,
    );
  }

  ProductDetailRouteData toRouteData() {
    final freshnessValue = isCritical ? 0.2 : 0.0;
    return ProductDetailRouteData(
      title: name,
      category: category,
      description: '',
      amountLabel: '$quantity $unit',
      expiryLabel: statusLabel,
      freshnessValue: freshnessValue,
      freshnessPercentLabel: '${(freshnessValue * 100).round()}%',
      isCritical: isCritical,
      icon: icon,
      heroColors: backgroundColors,
    );
  }
}

class InventoryItemTile extends StatelessWidget {
  const InventoryItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  final InventoryItemData item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusColor = item.isCritical
        ? const Color(0xFFB94C3A)
        : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(ProductDetailScreen.routeName, arguments: item.toRouteData());
        },
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: item.backgroundColors,
                  ),
                ),
                child: Icon(item.icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.statusLabel,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.quantity} ${item.unit}',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QuantityButton(
                        icon: Icons.remove_rounded,
                        onTap: onDecrement,
                      ),
                      const SizedBox(width: 6),
                      _QuantityButton(
                        icon: Icons.add_rounded,
                        onTap: onIncrement,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AppColors.outline),
        ),
      ),
    );
  }
}
