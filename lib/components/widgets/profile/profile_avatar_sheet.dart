import 'package:flutter/material.dart';

import 'profile_avatar.dart';

/// Bottom sheet that previews the profile avatar and exposes photo actions.
class ProfileAvatarSheet {
  ProfileAvatarSheet._();

  static Future<void> show(
    BuildContext context, {
    required String name,
    required String? avatarPath,
    required Color? color,
    required VoidCallback onChangePhoto,
    required VoidCallback onRemovePhoto,
  }) {
    final hasPhoto = avatarPath != null && avatarPath.isNotEmpty;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileAvatar(
                name: name,
                imagePath: avatarPath,
                color: color,
                size: 128,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    onChangePhoto();
                  },
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(hasPhoto ? 'Change photo' : 'Add photo'),
                ),
              ),
              if (hasPhoto) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      onRemovePhoto();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove photo'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
