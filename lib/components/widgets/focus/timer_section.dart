import 'package:flutter/material.dart';

import '../progress_ring.dart';
import '../../../models/models.dart';

class TimerSection extends StatelessWidget {
  const TimerSection({
    super.key,
    required this.session,
  });

  final FocusSession session;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        width: 288,
        height: 288,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surfaceContainerLowest,
          border: Border.all(color: colorScheme.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              offset: Offset.zero,
              blurRadius: 40,
              spreadRadius: 4,
              color: colorScheme.secondary.withValues(alpha: 0.15),
            ),
          ],
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              ProgressRing(
                progress: session.progress,
                color: colorScheme.secondary,
                size: 240,
                strokeWidth: 10,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    session.timerDisplay,
                    style: textTheme.headlineLarge?.copyWith(
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.timerStateLabel,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
