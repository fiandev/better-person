import 'package:material_ui/material_ui.dart';

import '../../../models/task.dart';

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.tags,
    required this.priority,
  });

  final String title;
  final List<String> tags;
  final TaskPriority priority;
}

class TaskEditor {
  static Future<TaskDraft?> show(BuildContext context, {Task? task}) =>
      showModalBottomSheet<TaskDraft>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => _TaskEditorSheet(task: task),
      );
}

class _TaskEditorSheet extends StatefulWidget {
  const _TaskEditorSheet({this.task});
  final Task? task;

  @override
  State<_TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<_TaskEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _tagsController;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _tagsController = TextEditingController(
      text: widget.task?.tags.join(', ') ?? '',
    );
    _priority = widget.task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  List<String> get _tags => _tagsController.text
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toSet()
      .toList();

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(
      context,
      TaskDraft(title: title, tags: _tags, priority: _priority),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 20,
      right: 20,
      top: 20,
      bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.task == null ? 'Add task' : 'Edit task',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Task',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagsController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Tags',
              hintText: 'Separate tags with commas',
              border: OutlineInputBorder(),
            ),
          ),
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _tags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<TaskPriority>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: TaskPriority.values
                .map(
                  (priority) => DropdownMenuItem(
                    value: priority,
                    child: Text(
                      priority.name[0].toUpperCase() +
                          priority.name.substring(1),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _priority = value);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: Text(widget.task == null ? 'Add task' : 'Save task'),
            ),
          ),
        ],
      ),
    ),
  );
}
