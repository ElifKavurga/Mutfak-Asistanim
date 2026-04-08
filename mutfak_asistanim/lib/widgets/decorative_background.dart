import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class DecorativeBackground extends StatelessWidget {
  const DecorativeBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: -60,
          right: -40,
          child: _GlowBubble(
            size: 220,
            color: AppColors.secondaryContainer,
            opacity: 0.32,
          ),
        ),
        const Positioned(
          top: 180,
          left: -50,
          child: _GlowBubble(
            size: 120,
            color: AppColors.primaryContainer,
            opacity: 0.45,
          ),
        ),
        const Positioned(
          bottom: -120,
          left: -80,
          child: _GlowBubble(
            size: 300,
            color: AppColors.surfaceContainer,
            opacity: 0.7,
          ),
        ),
        const Positioned(
          bottom: 40,
          right: 20,
          child: _GlowBubble(
            size: 110,
            color: AppColors.tertiaryContainer,
            opacity: 0.38,
            radius: 24,
          ),
        ),
        ...?child == null ? null : [child!],
      ],
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({
    required this.size,
    required this.color,
    required this.opacity,
    this.radius,
  });

  final double size;
  final Color color;
  final double opacity;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(radius ?? size / 2),
        ),
      ),
    );
  }
}
