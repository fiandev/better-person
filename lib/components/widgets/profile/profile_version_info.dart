import 'package:material_ui/material_ui.dart';

/// Build/version label shown at the bottom of the profile screen.
class ProfileVersionInfo extends StatelessWidget {
  const ProfileVersionInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Better Person v1.1.0',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colorScheme.outline),
        ),
      ),
    );
  }
}
