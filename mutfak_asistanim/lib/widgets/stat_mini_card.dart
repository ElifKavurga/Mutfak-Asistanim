import 'package:flutter/material.dart';

class StatMiniCardData {
  const StatMiniCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.iconBackgroundColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color iconBackgroundColor;
}

class StatMiniCard extends StatelessWidget {
  const StatMiniCard({super.key, required this.data});

  final StatMiniCardData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: data.backgroundColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: textTheme.labelSmall?.copyWith(
                    color: data.foregroundColor.withValues(alpha: 0.78),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data.value,
                  style: textTheme.displayMedium?.copyWith(
                    color: data.foregroundColor,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: data.foregroundColor.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: data.iconBackgroundColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(data.icon, color: data.foregroundColor),
          ),
        ],
      ),
    );
  }
}
