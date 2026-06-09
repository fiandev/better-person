import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.borderColor,
  });

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
            ? Border(left: BorderSide(color: borderColor!, width: 4))
            : null,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 40,
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
