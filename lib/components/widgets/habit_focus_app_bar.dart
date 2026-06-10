import 'package:flutter/material.dart';

class HabitFocusAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HabitFocusAppBar({super.key, this.onProfilePressed});

  final VoidCallback? onProfilePressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      title: Text(
        'HabitFocus',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: onProfilePressed,
            child: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
