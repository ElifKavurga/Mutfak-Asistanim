import 'package:flutter/material.dart';

class CameraActionButton extends StatelessWidget {
  const CameraActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.large = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool large;

  @override
  Widget build(BuildContext context) {
    if (large) {
      return GestureDetector(
        onTap: onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF536443), width: 4),
                ),
                child: const Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF536443),
                    ),
                    child: SizedBox(width: 42, height: 42),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
