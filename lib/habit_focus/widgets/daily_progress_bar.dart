import 'package:flutter/material.dart';

class DailyProgressBar extends StatelessWidget {
  const DailyProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 4.0,
  });

  final double progress;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final barColor = color ?? colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * progress.clamp(0.0, 1.0);
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        );
      },
    );
  }
}
