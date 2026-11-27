import 'package:material_ui/material_ui.dart';

import '../../theme/habit_focus_theme.dart';
import 'profile_avatar.dart';
import 'profile_avatar_sheet.dart';

/// Header card of the profile screen: avatar with an edit shortcut and name.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.avatarPath,
    required this.avatarColor,
    required this.busy,
    required this.onEditName,
    required this.onChangePhoto,
    required this.onRemovePhoto,
  });

  final String name;
  final String? avatarPath;
  final Color? avatarColor;
  final bool busy;
  final VoidCallback onEditName;
  final VoidCallback onChangePhoto;
  final VoidCallback onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              ProfileAvatar(
                name: name,
                imagePath: avatarPath,
                color: avatarColor,
                size: 88,
              ),
              _AvatarEditButton(
                onPressed: busy
                    ? null
                    : () => ProfileAvatarSheet.show(
                        context,
                        name: name,
                        avatarPath: avatarPath,
                        color: avatarColor,
                        onChangePhoto: onChangePhoto,
                        onRemovePhoto: onRemovePhoto,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit name',
                onPressed: busy ? null : onEditName,
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: colorScheme.primary,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

class _AvatarEditButton extends StatelessWidget {
  const _AvatarEditButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(Icons.edit, size: 16, color: colorScheme.onPrimary),
        ),
      ),
    );
  }
}
