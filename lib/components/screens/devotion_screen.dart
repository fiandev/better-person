import 'package:flutter/material.dart';

import '../theme/habit_focus_theme.dart';
import '../widgets/habit_focus_app_bar.dart';
import '../../routes/route_shell.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';

class DevotionScreen extends StatefulWidget {
  const DevotionScreen({super.key});

  @override
  State<DevotionScreen> createState() => _DevotionScreenState();
}

class _DevotionScreenState extends State<DevotionScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const HabitFocusAppBar(overrideTitle: 'Devotion'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HabitFocusTheme.mobilePadding,
              vertical: 16,
            ),
            child: Row(
              children: [
                _BadgeTab(
                  label: 'Islamic',
                  isSelected: _selectedTab == 0,
                  colorScheme: colorScheme,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                const SizedBox(width: 8),
                _BadgeTab(
                  label: 'Other',
                  isSelected: _selectedTab == 1,
                  colorScheme: colorScheme,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _IslamicTabContent(colorScheme: colorScheme),
                _OtherTabContent(colorScheme: colorScheme),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 2),
    );
  }
}

class _BadgeTab extends StatelessWidget {
  const _BadgeTab({
    required this.label,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

class _IslamicTabContent extends StatelessWidget {
  const _IslamicTabContent({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
      children: [
        _NextPrayerHero(colorScheme: colorScheme),
        const SizedBox(height: HabitFocusTheme.sectionGap),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _DailyShalatSection(colorScheme: colorScheme),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: _SunnahDzikirSection(colorScheme: colorScheme),
                  ),
                ],
              );
            }
            return Column(
              children: [
                _DailyShalatSection(colorScheme: colorScheme),
                const SizedBox(height: HabitFocusTheme.sectionGap),
                _SunnahDzikirSection(colorScheme: colorScheme),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _NextPrayerHero extends StatelessWidget {
  const _NextPrayerHero({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Upcoming Prayer',
                    style: textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Asr',
                  style: textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '15:30',
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.schedule,
                  size: 32,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 8),
                Text(
                  '01:42:15',
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'remaining',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
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

class _DailyShalatSection extends StatelessWidget {
  const _DailyShalatSection({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Shalat',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '2/5 Completed',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
        _PrayerCard(
          name: 'Fajr',
          time: '04:45 AM',
          isChecked: true,
          borderColor: colorScheme.outlineVariant,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
        _PrayerCard(
          name: 'Dhuhr',
          time: '12:15 PM',
          isChecked: true,
          borderColor: colorScheme.outlineVariant,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
        _PrayerCard(
          name: 'Asr',
          time: '03:30 PM',
          isChecked: false,
          borderColor: colorScheme.primary,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
        _PrayerCard(
          name: 'Maghrib',
          time: '06:05 PM',
          isChecked: false,
          borderColor: colorScheme.tertiary,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
        _PrayerCard(
          name: 'Isha',
          time: '07:20 PM',
          isChecked: false,
          borderColor: colorScheme.tertiary,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({
    required this.name,
    required this.time,
    required this.isChecked,
    required this.borderColor,
    required this.colorScheme,
  });

  final String name;
  final String time;
  final bool isChecked;
  final Color borderColor;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Opacity(
      opacity: isChecked ? 0.8 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isChecked
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
          boxShadow: isChecked ? null : [HabitFocusTheme.ambientShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color: isChecked
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isChecked ? Icons.done_all : Icons.schedule,
              color: isChecked
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SunnahDzikirSection extends StatelessWidget {
  const _SunnahDzikirSection({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sunnah & Dzikir',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [HabitFocusTheme.ambientShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      Icons.self_improvement,
                      size: 20,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Morning Dzikir',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: colorScheme.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completed',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  Text(
                    '33/33',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
      ],
    );
  }
}

class _CustomDevotionHero extends StatelessWidget {
  const _CustomDevotionHero({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Next Devotion',
                    style: textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Evening Prayer',
                  style: textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '19:00',
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.schedule,
                  size: 32,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 8),
                Text(
                  '04:03:18',
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'remaining',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
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

class _OtherTabContent extends StatefulWidget {
  const _OtherTabContent({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  State<_OtherTabContent> createState() => _OtherTabContentState();
}

class _OtherTabContentState extends State<_OtherTabContent> {
  final TextEditingController _devotionNameController = TextEditingController();
  final _customDevotionController = CustomDevotionController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 6, minute: 0);
  bool _isAddingDevotion = false;

  @override
  void dispose() {
    _devotionNameController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handleAddDevotion() async {
    final name = _devotionNameController.text.trim();

    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a devotion name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAddingDevotion = true);

    try {
      final newDevotion = CustomDevotion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        scheduledTime: _selectedTime,
        isCompleted: false,
        date: DateTime.now(),
        completedAt: null,
      );

      await _customDevotionController.create(newDevotion);

      _devotionNameController.clear();
      setState(() {
        _selectedTime = const TimeOfDay(hour: 6, minute: 0);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Devotion added successfully! ✨'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding devotion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingDevotion = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = widget.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
      children: [
        // Hero Section for Custom Devotions
        _CustomDevotionHero(colorScheme: colorScheme),
        const SizedBox(height: HabitFocusTheme.sectionGap),

        Text(
          'Custom Devotions',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),

        // Devotion List from controller
        ..._customDevotionController.getTodayDevotions().map((devotion) {
          return Padding(
            padding: const EdgeInsets.only(bottom: HabitFocusTheme.stackGap),
            child: _DevotionCard(
              devotion: devotion,
              colorScheme: colorScheme,
              onDelete: () async {
                await _customDevotionController.delete(devotion.id);
                setState(() {});
              },
              onToggle: () async {
                if (devotion.isCompleted) {
                  await _customDevotionController.markIncomplete(devotion.id);
                } else {
                  await _customDevotionController.markCompleted(devotion.id);
                }
                setState(() {});
              },
            ),
          );
        }),

        const SizedBox(height: HabitFocusTheme.sectionGap),

        // Add New Devotion Form
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant, width: 2),
            boxShadow: [HabitFocusTheme.ambientShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add New Devotion',
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _devotionNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter devotion name',
                      hintStyle: TextStyle(color: colorScheme.outline),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Time Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: _selectedTime.format(context),
                      hintStyle: TextStyle(color: colorScheme.onSurface),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      suffixIcon: Icon(
                        Icons.access_time,
                        color: colorScheme.primary,
                      ),
                    ),
                    readOnly: true,
                    onTap: _pickTime,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAddingDevotion ? null : _handleAddDevotion,
                  icon: _isAddingDevotion
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add, size: 20),
                  label: const Text('Add Devotion'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DevotionCard extends StatelessWidget {
  const _DevotionCard({
    required this.devotion,
    required this.colorScheme,
    required this.onDelete,
    required this.onToggle,
  });

  final CustomDevotion devotion;
  final ColorScheme colorScheme;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final timeString = devotion.scheduledTime.format(context);

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: devotion.isCompleted
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: devotion.isCompleted
                  ? colorScheme.primary
                  : colorScheme.tertiary,
              width: 4,
            ),
          ),
          boxShadow: devotion.isCompleted
              ? null
              : [HabitFocusTheme.ambientShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: devotion.isCompleted
                    ? colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: devotion.isCompleted
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: devotion.isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    devotion.name,
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeString,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}
