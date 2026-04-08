import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: AppTextStyles.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextField(
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: AppColors.outline),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
