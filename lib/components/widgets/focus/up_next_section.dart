import 'package:material_ui/material_ui.dart';

import '../../theme/habit_focus_theme.dart';
import 'task_item.dart';
import 'add_task_button.dart';
import '../../../models/models.dart';

class UpNextSection extends StatefulWidget {
  const UpNextSection({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onEdit,
    required this.onAddTask,
    required this.onDelete,
    required this.onReorder,
  });

  final List<Task> tasks;
  final Function(Task) onToggle;
  final Function(Task) onEdit;
  final VoidCallback onAddTask;
  final Function(Task) onDelete;
  final ValueChanged<List<Task>> onReorder;

  @override
  State<UpNextSection> createState() => _UpNextSectionState();
}

class _UpNextSectionState extends State<UpNextSection> {
  String _selectedTag = 'All tags';

  List<Task> get _visibleTasks => _selectedTag == 'All tags'
      ? widget.tasks
      : widget.tasks.where((task) => task.tags.contains(_selectedTag)).toList();

  List<String> get _tags => [
    'All tags',
    ...widget.tasks.expand((task) => task.tags).toSet().toList()..sort(),
  ];

  void _reorder(int oldIndex, int newIndex) {
    final visible = [..._visibleTasks];
    final moved = visible.removeAt(oldIndex);
    visible.insert(newIndex, moved);
    final updatedAll = [...widget.tasks];
    for (var index = 0; index < visible.length; index++) {
      final fullIndex = updatedAll.indexWhere(
        (task) => task.id == visible[index].id,
      );
      updatedAll[fullIndex] = visible[index];
    }
    widget.onReorder(updatedAll);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visible = _visibleTasks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Up next',
                style: textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
            ),
            if (widget.tasks.any((task) => task.tags.isNotEmpty))
              DropdownButton<String>(
                value: _tags.contains(_selectedTag) ? _selectedTag : 'All tags',
                onChanged: (value) {
                  if (value != null) setState(() => _selectedTag = value);
                },
                items: _tags
                    .map(
                      (tag) => DropdownMenuItem(
                        value: tag,
                        child: Text(tag, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
        const SizedBox(height: HabitFocusTheme.stackGap),
        if (widget.tasks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No tasks in the queue.'),
            ),
          )
        else if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No queued tasks use this tag.'),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: visible.length,
            onReorderItem: _reorder,
            itemBuilder: (context, index) {
              final task = visible[index];
              return Padding(
                key: ValueKey(task.id),
                padding: EdgeInsets.only(
                  bottom: index < visible.length - 1 ? 8 : 0,
                ),
                child: ReorderableDelayedDragStartListener(
                  index: index,
                  child: TaskItem(
                    task: task,
                    onToggle: () => widget.onToggle(task),
                    onEdit: () => widget.onEdit(task),
                    onDelete: () => widget.onDelete(task),
                    isDisabled: true,
                    showDragHandle: true,
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        AddTaskButton(onTap: widget.onAddTask),
      ],
    );
  }
}
