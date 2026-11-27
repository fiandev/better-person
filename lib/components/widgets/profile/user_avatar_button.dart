import 'package:material_ui/material_ui.dart';

import '../../../controllers/user_controller.dart';
import '../../../routes/app_routes.dart';
import 'profile_avatar.dart';

/// App bar avatar that always reflects the stored profile.
///
/// Rebuilds whenever [UserController] changes, so the photo, colour and initial
/// stay in sync across every screen header.
class UserAvatarButton extends StatelessWidget {
  const UserAvatarButton({super.key, this.onPressed, this.size = 40});

  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Open profile',
      onPressed:
          onPressed ??
          () => Navigator.pushNamed(context, AppRoutes.profile),
      icon: ListenableBuilder(
        listenable: UserController(),
        builder: (context, _) {
          final user = UserController().getAll().firstOrNull;
          final colorValue = user?.avatarColorValue;
          return ProfileAvatar(
            name: user?.name ?? '',
            imagePath: user?.avatarUrl,
            color: colorValue == null ? null : Color(colorValue),
            size: size,
          );
        },
      ),
    );
  }
}
