import 'dart:io';

import 'package:flutter/material.dart';

/// Circular profile avatar.
///
/// Renders the locally stored [imagePath] when it can be read and falls back to
/// the first letter of [name] tinted with [color] otherwise.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.imagePath,
    this.color,
    this.size = 80,
  });

  final String name;
  final String? imagePath;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: path == null || path.isEmpty
            ? _initial(context)
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _initial(context),
              ),
      ),
    );
  }

  Widget _initial(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trimmed = name.trim();
    return ColoredBox(
      color: color ?? colorScheme.primaryContainer,
      child: Center(
        child: Text(
          trimmed.isEmpty ? '?' : trimmed[0].toUpperCase(),
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
