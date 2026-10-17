import 'dart:async';

import 'package:flutter/material.dart';

import '../../../controllers/controllers.dart';
import '../../../models/models.dart';
import '../../../utils/habit_auto_checker.dart';

class PrayerTrackerSection extends StatefulWidget {
  const PrayerTrackerSection({super.key});

  @override
  State<PrayerTrackerSection> createState() => _PrayerTrackerSectionState();
}

class _PrayerTrackerSectionState extends State<PrayerTrackerSection> {
  final _controller = PrayerController();
  Timer? _clock;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onPrayersChanged);
    _load();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _controller.removeListener(_onPrayersChanged);
    super.dispose();
  }

  void _onPrayersChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      await _controller.initializeDailyPrayers();
      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggle(Prayer prayer, bool checked) async {
    if (checked) {
      await _controller.checkPrayer(prayer.id);
    } else {
      await _controller.uncheckPrayer(prayer.id);
    }
    if (!checked || !mounted) return;
    await UserController().recordActivity();
    if (!mounted) return;
    await HabitAutoChecker().onPrayersComplete();
  }

  DateTime? _nextAt(Prayer? prayer) {
    if (prayer == null) return null;
    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      prayer.scheduledTime.hour,
      prayer.scheduledTime.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _countdown(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Prayer times could not be loaded.'),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    }
    final prayers = _controller.getTodayPrayers();
    final nextPrayer = _controller.getNextPrayer();
    final nextAt = _nextAt(nextPrayer);
    final completed = prayers.where((item) => item.isChecked).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (nextPrayer != null && nextAt != null)
          _NextPrayerCard(
            name: nextPrayer.getPrayerLabel(),
            time: MaterialLocalizations.of(
              context,
            ).formatTimeOfDay(nextPrayer.scheduledTime),
            remaining: _countdown(nextAt.difference(DateTime.now())),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                'Daily Shalat',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Text('$completed/${PrayerName.values.length} completed'),
          ],
        ),
        const SizedBox(height: 12),
        if (prayers.isEmpty)
          const Text('No prayer records for today. Pull to retry.')
        else
          ...prayers.map(
            (prayer) => _PrayerRow(
              prayer: prayer,
              onChanged: (value) => _toggle(prayer, value),
            ),
          ),
      ],
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({
    required this.name,
    required this.time,
    required this.remaining,
  });

  final String name;
  final String time;
  final String remaining;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Next prayer', style: TextStyle(color: colors.onPrimary)),
              const SizedBox(height: 8),
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: colors.onPrimary),
              ),
              Text(time, style: TextStyle(color: colors.onPrimary)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time remaining', style: TextStyle(color: colors.onPrimary)),
              Text(
                remaining,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: colors.onPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({required this.prayer, required this.onChanged});
  final Prayer prayer;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Card(
    child: CheckboxListTile(
      value: prayer.isChecked,
      onChanged: (value) => onChanged(value ?? false),
      title: Text(prayer.getPrayerLabel()),
      subtitle: Text(
        MaterialLocalizations.of(context).formatTimeOfDay(prayer.scheduledTime),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    ),
  );
}
