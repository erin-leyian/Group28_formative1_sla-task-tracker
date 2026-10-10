import 'package:flutter/material.dart';

import '../models/task.dart';
import '../routes.dart';
import '../services/db_service.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final DbService _db = DbService();
  List<Task> _tasks = [];
  String _query = '';
  SlaStatus? _filter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _db.getTasks();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  List<Task> get _visibleTasks {
    return _tasks.where((t) {
      final matchesSearch = t.title.toLowerCase().contains(
        _query.toLowerCase(),
      );
      final matchesFilter = _filter == null || computeSlaStatus(t) == _filter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  String _assigneeName(String id) {
    for (final u in _db.getUsers()) {
      if (u.id == id) return u.name;
    }
    return 'Unassigned';
  }

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _label(SlaStatus? s) {
    switch (s) {
      case null:
        return 'All';
      case SlaStatus.onTrack:
        return 'On Track';
      case SlaStatus.atRisk:
        return 'At Risk';
      case SlaStatus.overdue:
        return 'Overdue';
      case SlaStatus.completed:
        return 'Completed';
    }
  }

  Future<void> _open(String route, {Object? args}) async {
    await Navigator.pushNamed(context, route, arguments: args);
    _loadTasks(); // refresh after coming back
  }

  @override
  Widget build(BuildContext context) {
    final filters = <SlaStatus?>[
      null,
      SlaStatus.onTrack,
      SlaStatus.atRisk,
      SlaStatus.overdue,
      SlaStatus.completed,
    ];
    final tasks = _visibleTasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _open(AppRoutes.taskForm),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search tasks',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.item),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final f in filters)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.item),
                      child: ChoiceChip(
                        label: Text(_label(f)),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.item),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : tasks.isEmpty
                  ? const Center(child: Text('No tasks found'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Card(
                          child: ListTile(
                            title: Text(task.title),
                            subtitle: Text(
                              '${_assigneeName(task.assigneeId)} · '
                              'Due ${_date(task.deadline)} · '
                              '${task.priority}',
                            ),
                            trailing: StatusChip(
                              status: computeSlaStatus(task),
                            ),
                            onTap: () =>
                                _open(AppRoutes.taskDetails, args: task),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
