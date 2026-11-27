import 'package:material_ui/material_ui.dart';

import '../../theme/habit_focus_theme.dart';
import '../../../routes/app_routes.dart';

/// Menu card of the profile screen: navigation entries and profile deletion.
class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({super.key, required this.onDeleteProfile});

  final VoidCallback onDeleteProfile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      // ListTiles paint their ink on the nearest Material, so a transparent one
      // is inserted here to keep splashes visible above the card colour.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.settings_outlined,
                color: colorScheme.onSurface,
              ),
              title: Text(
                'Settings',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: colorScheme.outline),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.settingsRoute),
            ),
            Divider(height: 1, indent: 56, color: colorScheme.outlineVariant),
            ListTile(
              leading: Icon(Icons.delete_outline, color: colorScheme.error),
              title: Text(
                'Delete profile',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              ),
              onTap: onDeleteProfile,
            ),
          ],
        ),
      ),
    );
  }
}
