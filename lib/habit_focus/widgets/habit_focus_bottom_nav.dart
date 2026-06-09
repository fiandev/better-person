import 'package:flutter/material.dart';

class HabitFocusBottomNav extends StatelessWidget {
  const HabitFocusBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(
        icon: Icons.timer_outlined, activeIcon: Icons.timer, label: 'Focus'),
    _NavItem(
        icon: Icons.self_improvement_outlined,
        activeIcon: Icons.self_improvement,
        label: 'Ibadah'),
    _NavItem(
        icon: Icons.volunteer_activism_outlined,
        activeIcon: Icons.volunteer_activism,
        label: 'Kindness'),
    _NavItem(
        icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = index == currentIndex;
              return _NavButton(
                item: item,
                isActive: isActive,
                colorScheme: colorScheme,
                onTap: () => onTap?.call(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isActive,
    required this.colorScheme,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              size: 22,
              color: isActive
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
