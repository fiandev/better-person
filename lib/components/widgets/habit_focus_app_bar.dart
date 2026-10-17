import 'package:flutter/material.dart';

import 'profile/user_avatar_button.dart';

class HabitFocusAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HabitFocusAppBar({
    super.key,
    this.onProfilePressed,
    this.overrideTitle,
  });

  final VoidCallback? onProfilePressed;
  final String? overrideTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      title: Text(
        overrideTitle ?? 'Better Person',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
      actions: [UserAvatarButton(onPressed: onProfilePressed)],
    );
  }
}
