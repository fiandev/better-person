import 'package:flutter/material.dart';

import '../theme/habit_focus_theme.dart';
import '../widgets/habit_focus_app_bar.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../routes/app_routes.dart';
import 'profile_avatar_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userController = UserController();

  @override
  void initState() {
    super.initState();
    _userController.addListener(_refresh);
  }

  @override
  void dispose() {
    _userController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _editName() async {
    final user = _userController.getCurrentUser();
    final controller = TextEditingController(text: user.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profile name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    await _userController.updateFields(user.id, {'name': name});
  }

  Future<void> _chooseAvatarColor() async {
    final user = _userController.getCurrentUser();
    final selected = await ProfileAvatarPicker.show(context);
    if (!mounted) return;
    if (selected != null) {
      await _userController.updateFields(user.id, {
        'avatarColorValue': selected.toARGB32(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final user = _userController.getCurrentUser();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const HabitFocusAppBar(overrideTitle: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
        children: [
          _ProfileHeader(
            userName: user.name,
            streak: user.streak,
            kindnessGoal: SettingController()
                .getCurrentSetting()
                .weeklyKindnessGoal,
            onEditName: _editName,
            avatarColor: user.avatarColorValue == null
                ? null
                : Color(user.avatarColorValue!),
            onEditAvatar: _chooseAvatarColor,
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
    required this.kindnessGoal,
    required this.onEditName,
    required this.avatarColor,
    required this.onEditAvatar,
    required this.colorScheme,
    required this.textTheme,
  });

  final String userName;
  final int streak;
  final int kindnessGoal;
  final VoidCallback onEditName;
  final Color? avatarColor;
  final VoidCallback onEditAvatar;
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
              color: avatarColor ?? colorScheme.primaryContainer,
            ),
            child: Center(
              child: Text(
                userName.trim().isEmpty
                    ? '?'
                    : userName.trim()[0].toUpperCase(),
                style: textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          TextButton.icon(
            onPressed: onEditName,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit name'),
          ),
          TextButton.icon(
            onPressed: onEditAvatar,
            icon: const Icon(Icons.palette_outlined),
            label: const Text('Change avatar color'),
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
          const SizedBox(height: 8),
          Text(
            'Weekly kindness goal: $kindnessGoal acts',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.colorScheme, required this.textTheme});

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
                trailing: Icon(Icons.chevron_right, color: colorScheme.outline),
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
  const _VersionInfo({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Better Person v1.0.1',
          style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
        ),
      ),
    );
  }
}
