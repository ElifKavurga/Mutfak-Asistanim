import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SuggestionChip extends StatelessWidget {
  const SuggestionChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ActionChip(
      onPressed: onTap,
      backgroundColor: AppColors.secondaryContainer,
      side: BorderSide.none,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      label: Text(
        label,
        style: textTheme.labelMedium?.copyWith(color: AppColors.secondary),
      ),
    );
  }
}
