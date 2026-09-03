import 'package:flutter/material.dart';

import '../theme/habit_focus_theme.dart';
import '../widgets/habit_focus_app_bar.dart';
import '../../controllers/user_controller.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userController = UserController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final user = _userController.getCurrentUser();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const HabitFocusAppBar(
        overrideTitle: 'Profile',
      ),
      body: ListView(
        padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
        children: [
          _ProfileHeader(
            userName: user.name,
            streak: user.streak,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: HabitFocusTheme.sectionGap),
          _MenuSection(colorScheme: colorScheme, textTheme: textTheme),
          const SizedBox(height: HabitFocusTheme.sectionGap),
          _VersionInfo(colorScheme: colorScheme, textTheme: textTheme),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.userName,
    required this.streak,
    required this.colorScheme,
    required this.textTheme,
  });

  final String userName;
  final int streak;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak-day streak',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  static const _items = [
    (Icons.person_outline, 'Profile'),
    (Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Column(
        children: List.generate(_items.length, (i) {
          final (icon, label) = _items[i];
          return Column(
            children: [
              ListTile(
                leading: Icon(icon, color: colorScheme.onSurface),
                title: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.outline,
                ),
                onTap: () {
                  if (label == 'Settings') {
                    Navigator.pushNamed(context, AppRoutes.settingsRoute);
                  }
                },
              ),
              if (i < _items.length - 1)
                Divider(
                  height: 1,
                  indent: 56,
                  color: colorScheme.outlineVariant,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _VersionInfo extends StatelessWidget {
  const _VersionInfo({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Better Person v1.0.1',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
