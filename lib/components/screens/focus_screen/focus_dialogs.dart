import 'package:flutter/material.dart';

/// Dialogs for focus session completion and break completion
class FocusDialogs {
  /// Show dialog when a focus session completes
  static Future<void> showSessionCompleteDialog(
    BuildContext context,
    VoidCallback onStartNewSession,
  ) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: const Text('Great work! You completed your focus session.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onStartNewSession();
            },
            child: const Text('Start New Session'),
          ),
        ],
      ),
    );
  }

  /// Show dialog when a break completes
  static Future<void> showBreakCompleteDialog(
    BuildContext context,
    VoidCallback onStartFocus,
  ) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Break Complete!'),
        content: const Text('Ready to focus again?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onStartFocus();
            },
            child: const Text('Start Focusing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Stay on Break'),
          ),
        ],
      ),
    );
  }
}
