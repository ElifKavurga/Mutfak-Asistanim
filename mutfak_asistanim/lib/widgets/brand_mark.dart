import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.compact = false,
    this.showIcon = true,
    this.centered = false,
  });

  final bool compact;
  final bool showIcon;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final titleStyle = compact
        ? AppTextStyles.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          )
        : AppTextStyles.textTheme.headlineLarge?.copyWith(
            color: AppColors.primary,
          );

    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (showIcon) ...[
          Container(
            width: compact ? 52 : 84,
            height: compact ? 52 : 84,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(compact ? 18 : 28),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 28,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -0.2,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(compact ? 14 : 22),
                    ),
                  ),
                ),
                Icon(
                  Icons.restaurant_menu_rounded,
                  size: compact ? 26 : 42,
                  color: AppColors.onPrimary,
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 12 : 20),
        ],
        Text(
          'MutfakAsistanım',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: titleStyle,
        ),
      ],
    );
  }
}
