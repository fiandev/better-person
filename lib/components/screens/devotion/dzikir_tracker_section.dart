import 'package:material_ui/material_ui.dart';

import '../../../controllers/controllers.dart';
import '../../../models/models.dart';
import '../../../utils/habit_auto_checker.dart';

class DzikirTrackerSection extends StatefulWidget {
  const DzikirTrackerSection({super.key});

  @override
  State<DzikirTrackerSection> createState() => _DzikirTrackerSectionState();
}

class _DzikirTrackerSectionState extends State<DzikirTrackerSection> {
  final _controller = DzikirEntryController();
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _seedToday();
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _seedToday() async {
    try {
      final today = _controller.getTodayEntries();
      final names = today.map((entry) => entry.name).toSet();
      const defaults = [
        ('Morning', 'SubhanAllah'),
        ('Morning', 'Alhamdulillah'),
        ('Morning', 'Allahu Akbar'),
        ('Evening', 'SubhanAllah'),
        ('Evening', 'Alhamdulillah'),
        ('Evening', 'Allahu Akbar'),
      ];
      final date = DateTime.now();
      for (final (period, phrase) in defaults) {
        final name = '$period: $phrase';
        if (names.contains(name)) {
          continue;
        }
        await _controller.create(
          DzikirEntry(
            id: 'dzikir_${date.year}_${date.month}_${date.day}_${period}_$phrase',
            name: name,
            current: 0,
            total: 33,
            date: DateTime(date.year, date.month, date.day),
          ),
        );
      }
      if (mounted) setState(() => _loading = false);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _loading = false;
        });
      }
    }
  }

  Future<void> _increment(DzikirEntry entry) async {
    final updated = await _controller.increment(entry.id);
    if (updated != null) await UserController().recordActivity();
    if (updated == null ||
        !updated.isCompleted ||
        entry.isCompleted ||
        !mounted) {
      return;
    }
    await HabitAutoChecker().onDzikirProgressComplete();
  }

  Future<void> _reset(DzikirEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset counter?'),
        content: Text('Reset ${entry.name} to zero?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep count'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _controller.reset(entry.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dzikir counters could not be loaded.'),
          TextButton(onPressed: _seedToday, child: const Text('Retry')),
        ],
      );
    }
    final entries = _controller.getTodayEntries();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sunnah and dzikir',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          const Text('No counters yet. Refresh to set up today’s entries.')
        else
          ...entries.map(
            (entry) => _DzikirCounterCard(
              entry: entry,
              onIncrement: () => _increment(entry),
              onReset: () => _reset(entry),
            ),
          ),
      ],
    );
  }
}

class _DzikirCounterCard extends StatelessWidget {
  const _DzikirCounterCard({
    required this.entry,
    required this.onIncrement,
    required this.onReset,
  });

  final DzikirEntry entry;
  final VoidCallback onIncrement;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  entry.countLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: entry.progress),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.isCompleted
                        ? 'Target reached'
                        : 'Target: ${entry.total}',
                  ),
                ),
                IconButton(
                  tooltip: 'Reset ${entry.name}',
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt),
                ),
                FilledButton.tonalIcon(
                  onPressed: entry.isCompleted ? null : onIncrement,
                  icon: const Icon(Icons.add),
                  label: const Text('Count'),
                  style: FilledButton.styleFrom(
                    foregroundColor: colors.onSecondaryContainer,
                    minimumSize: const Size(44, 44),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
