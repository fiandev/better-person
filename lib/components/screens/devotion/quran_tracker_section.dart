import 'package:flutter/material.dart';

import '../../../controllers/controllers.dart';
import '../../../models/models.dart';
import '../../../utils/habit_auto_checker.dart';

class QuranTrackerSection extends StatefulWidget {
  const QuranTrackerSection({super.key});

  @override
  State<QuranTrackerSection> createState() => _QuranTrackerSectionState();
}

class _QuranTrackerSectionState extends State<QuranTrackerSection> {
  final _controller = QuranSessionController();
  final _surahController = TextEditingController();
  final _goalController = TextEditingController();
  QuranSession? _session;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_reload);
    _load();
  }

  @override
  void dispose() {
    _controller.removeListener(_reload);
    _surahController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    final updated = _controller.getTodaySession();
    if (updated == null) return;
    setState(() => _session = updated);
  }

  Future<void> _load() async {
    try {
      var session = _controller.getTodaySession();
      if (session == null) {
        final now = DateTime.now();
        session = await _controller.create(
          QuranSession(
            id: 'quran_${now.year}_${now.month}_${now.day}',
            currentSurah: '',
            currentSurahNumber: 0,
            dailyPageGoal: 2,
            pagesReadToday: 0,
            instruction: 'Log pages read toward your daily goal.',
            isCompleted: false,
            date: DateTime(now.year, now.month, now.day),
          ),
        );
      }
      _surahController.text = session.currentSurah;
      _goalController.text = session.dailyPageGoal.toString();
      if (mounted) {
        setState(() {
          _session = session;
          _loading = false;
        });
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

  Future<void> _update({int? pageDelta, bool saveDetails = false}) async {
    final session = _session;
    if (session == null) return;
    final goal =
        int.tryParse(_goalController.text.trim()) ?? session.dailyPageGoal;
    final surah = _surahController.text.trim();
    final previousCompletion = session.isCompleted;
    final updated = await _controller.updateReadingProgress(
      session.id,
      currentSurah: surah,
      dailyPageGoal: goal,
      pagesReadToday: session.pagesReadToday + (pageDelta ?? 0),
    );
    if (updated == null || !mounted) return;
    setState(() => _session = updated);
    if ((pageDelta ?? 0) > 0) {
      await UserController().recordActivity();
    }
    if (updated.isCompleted && !previousCompletion) {
      await HabitAutoChecker().onQuranSessionComplete(updated);
    }
    if (saveDetails && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reading goal saved.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null || _session == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quran progress could not be loaded.'),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    }
    final session = _session!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quran reading',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _surahController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _update(saveDetails: true),
              decoration: const InputDecoration(
                labelText: 'Current surah or reading point',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _update(saveDetails: true),
              decoration: const InputDecoration(
                labelText: 'Daily page goal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: session.progress),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${session.pagesReadToday} of ${session.dailyPageGoal} pages',
                  ),
                ),
                IconButton(
                  tooltip: 'Remove one page',
                  onPressed: session.pagesReadToday == 0
                      ? null
                      : () => _update(pageDelta: -1),
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  tooltip: 'Add one page',
                  onPressed: () => _update(pageDelta: 1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (session.isCompleted)
              Text(
                'Daily page goal reached.',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _update(saveDetails: true),
                child: const Text('Save reading details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
