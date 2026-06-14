import 'package:flutter/material.dart';

import '../../../models/models.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.session,
    required this.onToggleFocus,
    required this.onToggleBreak,
  });

  final FocusSession session;
  final VoidCallback onToggleFocus;
  final VoidCallback onToggleBreak;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFocusing = session.timerState == TimerState.focusing;
    final isOnBreak = session.timerState == TimerState.onBreak;
    
    // If we're idle, we need to know if we were in a break or focus mode
    // We can infer this from the timerDuration
    final isBreakMode =
        isOnBreak ||
        (session.timerState == TimerState.idle &&
            session.timerDuration.inMinutes == 5);
    final isFocusMode =
        isFocusing ||
        (session.timerState == TimerState.idle &&
            session.timerDuration.inMinutes == 25);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isBreakMode) ...[
          // Show Focus button when not in break mode
          FilledButton.icon(
            onPressed: onToggleFocus,
            icon: Icon(isFocusing ? Icons.pause : Icons.play_arrow),
            label: Text(isFocusing ? 'Pause' : 'Start Focus'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: onToggleBreak,
            icon: const Icon(Icons.coffee),
            label: const Text('Break'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.secondary,
              side: BorderSide(color: colorScheme.secondary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ] else ...[
          // Show Break button when in break mode
          FilledButton.icon(
            onPressed: onToggleBreak,
            icon: Icon(isOnBreak ? Icons.pause : Icons.play_arrow),
            label: Text(isOnBreak ? 'Pause Break' : 'Start Break'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: onToggleFocus,
            icon: const Icon(Icons.work_outline),
            label: const Text('Focus'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.secondary,
              side: BorderSide(color: colorScheme.secondary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ],
    );
  }
}
