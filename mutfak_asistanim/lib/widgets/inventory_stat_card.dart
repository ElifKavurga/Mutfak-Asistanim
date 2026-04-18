import 'package:flutter/material.dart';

class InventoryStatCardData {
  const InventoryStatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.accentIcon,
    this.outlineLabelColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? accentIcon;
  final Color? outlineLabelColor;
}

class InventoryStatCard extends StatelessWidget {
  const InventoryStatCard({super.key, required this.data});

  final InventoryStatCardData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 156,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: data.backgroundColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          if (data.accentIcon != null)
            Positioned(
              right: -10,
              bottom: -14,
              child: Icon(
                data.accentIcon,
                size: 108,
                color: data.foregroundColor.withValues(alpha: 0.10),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(data.icon, color: data.foregroundColor, size: 30),
                  const Spacer(),
                  Text(
                    data.title,
                    style: textTheme.labelSmall?.copyWith(
                      color: data.outlineLabelColor ?? data.foregroundColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                data.value,
                style: textTheme.displaySmall?.copyWith(
                  color: data.foregroundColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
