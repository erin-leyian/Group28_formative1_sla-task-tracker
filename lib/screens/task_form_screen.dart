import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/user.dart';
import '../services/db_service.dart';
import '../theme/app_theme.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DbService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();

  late final List<AppUser> _users;
  String? _assigneeId;
  String _priority = 'Medium';
  DateTime? _deadline;
  Task? _editing; // null = creating a new task
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _users = _db.getUsers();
  }

  // Route arguments are only available here, not in initState
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Task) {
      _editing = args;
      _titleController.text = args.title;
      _descController.text = args.description;
      _assigneeId = args.assigneeId;
      _priority = args.priority;
      _deadline = args.deadline;
      _dateController.text = _formatDate(args.deadline);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      // End of the chosen day, so a task due today is not instantly overdue
      _deadline = DateTime(picked.year, picked.month, picked.day, 23, 59);
      _dateController.text = _formatDate(picked);
    });
  }

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Title is required';
    if (text.length < 3) return 'Title must be at least 3 characters';
    return null;
  }

  String? _validateDeadline(String? _) {
    if (_deadline == null) return 'Please choose a deadline';
    if (_editing == null && _deadline!.isBefore(DateTime.now())) {
      return 'Deadline cannot be in the past';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: _editing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      assigneeId: _assigneeId!,
      priority: _priority,
      deadline: _deadline!,
      isCompleted: _editing?.isCompleted ?? false,
    );

    try {
      await _db.saveTask(task);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editing == null ? 'Task created' : 'Task updated'),
        ),
      );
      Navigator.pop(context, task);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the task. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing == null ? 'New task' : 'Edit task')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: _validateTitle,
              ),
              const SizedBox(height: AppSpacing.page),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: AppSpacing.item),
              DropdownButtonFormField<String>(
                value: _assigneeId,
                decoration: const InputDecoration(labelText: 'Assignee'),
                items: [
                  for (final u in _users)
                    DropdownMenuItem(value: u.id, child: Text(u.name)),
                ],
                onChanged: (v) => setState(() => _assigneeId = v),
                validator: (v) =>
                    v == null ? 'Please select an assignee' : null,
              ),
              const SizedBox(height: AppSpacing.page),
              Text('Priority', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpacing.item),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Low', label: Text('Low')),
                  ButtonSegment(value: 'Medium', label: Text('Medium')),
                  ButtonSegment(value: 'High', label: Text('High')),
                ],
                selected: {_priority},
                onSelectionChanged: (s) => setState(() => _priority = s.first),
              ),
              const SizedBox(height: AppSpacing.section),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _pickDate,
                validator: _validateDeadline,
              ),
              const SizedBox(height: AppSpacing.section),
              FilledButton(
                onPressed: _save,
                child: Text(_editing == null ? 'Save task' : 'Update task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
