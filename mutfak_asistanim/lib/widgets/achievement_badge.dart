import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AchievementBadgeData {
  const AchievementBadgeData({
    required this.title,
    required this.icon,
    required this.isUnlocked,
  });

  final String title;
  final IconData icon;
  final bool isUnlocked;
}

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({super.key, required this.data});

  final AchievementBadgeData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor = data.isUnlocked
        ? AppColors.surfaceContainerLow
        : AppColors.surfaceContainer;
    final iconShellColor = data.isUnlocked
        ? AppColors.secondaryContainer
        : AppColors.surfaceContainerHigh;
    final iconColor = data.isUnlocked ? AppColors.secondary : AppColors.outline;
    final textColor = data.isUnlocked
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconShellColor,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
