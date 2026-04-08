import 'package:flutter/material.dart';

class DetectionBox extends StatelessWidget {
  const DetectionBox({
    super.key,
    required this.label,
    required this.width,
    required this.height,
    required this.left,
    required this.top,
  });

  final String label;
  final double width;
  final double height;
  final double left;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned(
              left: 0,
              top: 0,
              child: _Corner(alignment: Alignment.topLeft),
            ),
            const Positioned(
              right: 0,
              top: 0,
              child: _Corner(alignment: Alignment.topRight),
            ),
            const Positioned(
              left: 0,
              bottom: 0,
              child: _Corner(alignment: Alignment.bottomLeft),
            ),
            const Positioned(
              right: 0,
              bottom: 0,
              child: _Corner(alignment: Alignment.bottomRight),
            ),
            Positioned(
              top: -38,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xE6536443),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Color(0xFFEDFFD8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFFEDFFD8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Color(0xFFC7DBB1), width: 4)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Color(0xFFC7DBB1), width: 4)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Color(0xFFC7DBB1), width: 4)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Color(0xFFC7DBB1), width: 4)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(16) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(16) : Radius.zero,
          bottomLeft: !isTop && isLeft
              ? const Radius.circular(16)
              : Radius.zero,
          bottomRight: !isTop && !isLeft
              ? const Radius.circular(16)
              : Radius.zero,
        ),
      ),
    );
  }
}
