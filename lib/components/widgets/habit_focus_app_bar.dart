import 'package:flutter/material.dart';

class HabitFocusAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HabitFocusAppBar({super.key, this.onSettingsPressed});

  final VoidCallback? onSettingsPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
      ),
      title: Text(
        'HabitFocus',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: colorScheme.onSurface),
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }
}
