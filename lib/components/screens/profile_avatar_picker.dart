import 'package:flutter/material.dart';

class ProfileAvatarPicker {
  static Future<Color?> show(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final options = [
      colors.primaryContainer,
      colors.secondaryContainer,
      colors.tertiaryContainer,
      colors.surfaceContainerHighest,
    ];
    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avatar color'),
        content: Wrap(
          spacing: 12,
          children: options
              .map(
                (color) => IconButton(
                  tooltip: 'Choose color ${options.indexOf(color) + 1}',
                  onPressed: () => Navigator.pop(context, color),
                  icon: CircleAvatar(backgroundColor: color),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
