import 'package:material_ui/material_ui.dart';

import '../../../routes/app_routes.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _QuickAction(
          label: 'Start focus',
          icon: Icons.timer_outlined,
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.focus),
        ),
        _QuickAction(
          label: 'Log kindness',
          icon: Icons.favorite_border,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.kindness),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(44, 48),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    ),
  );
}
