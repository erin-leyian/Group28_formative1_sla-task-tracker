import 'package:flutter/material.dart';

import '../models/task.dart';
import '../routes.dart';
import '../services/db_service.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final DbService _db = DbService();
  Task? _task;

  // Route arguments are only available here, not in initState
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _task ??= ModalRoute.of(context)!.settings.arguments as Task;
  }

  String _assigneeName(String id) {
    for (final u in _db.getUsers()) {
      if (u.id == id) return u.name;
    }
    return 'Unassigned';
  }

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> _toggleCompleted() async {
    final t = _task!;
    final updated = Task(
      id: t.id,
      title: t.title,
      description: t.description,
      assigneeId: t.assigneeId,
      priority: t.priority,
      deadline: t.deadline,
      isCompleted: !t.isCompleted,
    );
    await _db.saveTask(updated);
    if (!mounted) return;
    setState(() => _task = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(updated.isCompleted ? 'Marked completed' : 'Reopened'),
      ),
    );
  }

  Future<void> _edit() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.taskForm,
      arguments: _task,
    );
    if (result is Task && mounted) {
      setState(() => _task = result);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _db.deleteTask(_task!.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = _task!;
    final status = computeSlaStatus(task);

    return Scaffold(
      appBar: AppBar(title: const Text('Task details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                StatusChip(status: status),
              ],
            ),
            const SizedBox(height: AppSpacing.page),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Assignee', _assigneeName(task.assigneeId)),
                    const Divider(height: 1),
                    _row('Priority', task.priority),
                    const Divider(height: 1),
                    _row('Deadline', _date(task.deadline)),
                    const Divider(height: 1),
                    _row(
                      'Description',
                      task.description.isEmpty
                          ? 'No description'
                          : task.description,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            FilledButton(
              onPressed: _toggleCompleted,
              child: Text(task.isCompleted ? 'Reopen task' : 'Mark completed'),
            ),
            const SizedBox(height: AppSpacing.item),
            OutlinedButton(
              onPressed: _edit,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Edit'),
            ),
            const SizedBox(height: AppSpacing.item),
            OutlinedButton(
              onPressed: _delete,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: Colors.red.shade700,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
