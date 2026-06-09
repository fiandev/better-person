import 'package:flutter/material.dart';

import '../theme/habit_focus_theme.dart';
import '../widgets/habit_focus_app_bar.dart';
import '../widgets/habit_focus_bottom_nav.dart';

class KindnessScreen extends StatefulWidget {
  const KindnessScreen({super.key});

  @override
  State<KindnessScreen> createState() => _KindnessScreenState();
}

class _KindnessScreenState extends State<KindnessScreen> {
  final Set<int> _selectedChips = {};

  void _toggleChip(int index) {
    setState(() {
      if (_selectedChips.contains(index)) {
        _selectedChips.remove(index);
      } else {
        _selectedChips.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const HabitFocusAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
        children: [
          _HeaderSection(colorScheme: colorScheme),
          const SizedBox(height: HabitFocusTheme.sectionGap),
          _BentoGrid(
            colorScheme: colorScheme,
            selectedChips: _selectedChips,
            onToggleChip: _toggleChip,
          ),
        ],
      ),
      bottomNavigationBar: const HabitFocusBottomNav(currentIndex: 3),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.volunteer_activism,
          size: 160,
          color: colorScheme.onSurface.withValues(alpha: 0.05),
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFffdcbd),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Daily Reflection',
                style: textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF623f18),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'How did you help today?',
              style: textTheme.headlineLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Small acts of kindness create a ripple effect. Log your moments of connection and compassion.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}

class _BentoGrid extends StatelessWidget {
  const _BentoGrid({
    required this.colorScheme,
    required this.selectedChips,
    required this.onToggleChip,
  });

  final ColorScheme colorScheme;
  final Set<int> selectedChips;
  final ValueChanged<int> onToggleChip;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _QuickIdeasCard(
                      colorScheme: colorScheme,
                      selectedChips: selectedChips,
                      onToggleChip: onToggleChip,
                    ),
                  ),
                  const SizedBox(width: HabitFocusTheme.stackGap),
                  Expanded(
                    child: _ImpactCounterCard(colorScheme: colorScheme),
                  ),
                ],
              ),
              const SizedBox(height: HabitFocusTheme.stackGap),
              _ReflectionCard(colorScheme: colorScheme),
            ],
          );
        }
        return Column(
          children: [
            _QuickIdeasCard(
              colorScheme: colorScheme,
              selectedChips: selectedChips,
              onToggleChip: onToggleChip,
            ),
            const SizedBox(height: HabitFocusTheme.stackGap),
            _ImpactCounterCard(colorScheme: colorScheme),
            const SizedBox(height: HabitFocusTheme.stackGap),
            _ReflectionCard(colorScheme: colorScheme),
          ],
        );
      },
    );
  }
}

class _QuickIdeasCard extends StatelessWidget {
  const _QuickIdeasCard({
    required this.colorScheme,
    required this.selectedChips,
    required this.onToggleChip,
  });

  final ColorScheme colorScheme;
  final Set<int> selectedChips;
  final ValueChanged<int> onToggleChip;

  static const _ideas = [
    'Gave a compliment',
    'Helped a colleague',
    'Held the door open',
    'Listened actively',
    'Donated to charity',
    'Sent a thoughtful message',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        border: Border(
          left: BorderSide(color: colorScheme.tertiaryContainer, width: 4),
        ),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: colorScheme.tertiaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Ideas',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Select the acts of kindness you performed today.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_ideas.length, (index) {
              final isSelected = selectedChips.contains(index);
              return GestureDetector(
                onTap: () => onToggleChip(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    _ideas[index],
                    style: textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.outline,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ImpactCounterCard extends StatelessWidget {
  const _ImpactCounterCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Icon(
              Icons.favorite,
              size: 100,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Your Impact',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '14',
                style: textTheme.headlineLarge?.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Acts of kindness this week',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onTertiary.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.75,
                  backgroundColor: Colors.black.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Almost reached your weekly goal!',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onTertiary.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Reflection',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Describe your act of kindness or how it made you feel...',
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  HabitFocusTheme.defaultRadius,
                ),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  HabitFocusTheme.defaultRadius,
                ),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  HabitFocusTheme.defaultRadius,
                ),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Log Kindness'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
