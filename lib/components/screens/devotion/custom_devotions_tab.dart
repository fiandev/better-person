import 'package:flutter/material.dart';

import '../../../components/theme/habit_focus_theme.dart';
import '../../../controllers/custom_devotion_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/custom_devotion.dart';

class CustomDevotionsTab extends StatefulWidget {
  const CustomDevotionsTab({super.key});

  @override
  State<CustomDevotionsTab> createState() => _CustomDevotionsTabState();
}

class _CustomDevotionsTabState extends State<CustomDevotionsTab> {
  final _controller = CustomDevotionController();
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _load();
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      await _controller.init();
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

  Future<void> _add() async {
    final nameController = TextEditingController();
    var time = TimeOfDay.now();
    final result = await showDialog<(String, TimeOfDay)?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add a devotion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (picked != null) {
                    setDialogState(() => time = picked);
                  }
                },
                icon: const Icon(Icons.schedule),
                label: Text(time.format(context)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) Navigator.pop(context, (name, time));
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    if (result == null) return;
    final now = DateTime.now();
    await _controller.create(
      CustomDevotion(
        id: 'custom_${now.microsecondsSinceEpoch}',
        name: result.$1,
        scheduledTime: result.$2,
        isCompleted: false,
        date: DateTime(now.year, now.month, now.day),
      ),
    );
  }

  Future<void> _toggle(CustomDevotion devotion) async {
    if (devotion.isCompleted) {
      await _controller.markIncomplete(devotion.id);
    } else {
      await _controller.markCompleted(devotion.id);
      await UserController().recordActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Custom devotions could not be loaded.'),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final devotions = _controller.getTodayDevotions();
    return ListView(
      padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
      children: [
        Text(
          'Custom devotions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (devotions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('No custom devotions scheduled for today.'),
          )
        else
          ...devotions.map(
            (devotion) => _DevotionTile(
              devotion: devotion,
              onToggle: () => _toggle(devotion),
              onDelete: () => _controller.delete(devotion.id),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _add,
          icon: const Icon(Icons.add),
          label: const Text('Add a devotion'),
        ),
      ],
    );
  }
}

class _DevotionTile extends StatelessWidget {
  const _DevotionTile({
    required this.devotion,
    required this.onToggle,
    required this.onDelete,
  });

  final CustomDevotion devotion;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            value: devotion.isCompleted,
            onChanged: (_) => onToggle(),
            title: Text(devotion.name),
            subtitle: Text(
              MaterialLocalizations.of(
                context,
              ).formatTimeOfDay(devotion.scheduledTime),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Delete ${devotion.name}',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
  );
}
