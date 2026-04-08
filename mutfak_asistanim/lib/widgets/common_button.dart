import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum CommonButtonVariant { primary, secondary, ghost }

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = CommonButtonVariant.primary,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final CommonButtonVariant variant;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final style = switch (variant) {
      CommonButtonVariant.primary => FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        textStyle: AppTextStyles.textTheme.titleMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      CommonButtonVariant.secondary => FilledButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        textStyle: AppTextStyles.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.18),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      CommonButtonVariant.ghost => TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: AppTextStyles.textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    };

    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              const SizedBox(width: 12),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final button = switch (variant) {
      CommonButtonVariant.primary || CommonButtonVariant.secondary =>
        FilledButton(onPressed: onPressed, style: style, child: child),
      CommonButtonVariant.ghost => TextButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    };

    return SizedBox(width: double.infinity, child: button);
  }
}
