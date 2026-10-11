import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/user.dart';
import '../routes.dart';
import '../services/db_service.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final DbService _db = DbService();
  late final List<AppUser> _users;
  List<Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _users = _db.getUsers();
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

  List<Task> _tasksFor(AppUser user) {
    return _tasks.where((t) => t.assigneeId == user.id).toList();
  }

  String _countText(int n) => n == 1 ? '1 task' : '$n tasks';

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _showTasks(AppUser user) {
    final memberTasks = _tasksFor(user);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${user.name}'s tasks",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.item),
              if (memberTasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.section),
                  child: Center(child: Text('No tasks assigned')),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: memberTasks.length,
                    itemBuilder: (context, index) {
                      final task = memberTasks[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(task.title),
                        subtitle: Text(
                          'Due ${_date(task.deadline)} · ${task.priority}',
                        ),
                        trailing: StatusChip(status: computeSlaStatus(task)),
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.taskDetails,
                            arguments: task,
                          );
                          _loadTasks();
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.page),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final count = _tasksFor(user).length;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(user.name[0])),
                    title: Text(user.name),
                    subtitle: Text(user.role),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_countText(count)),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => _showTasks(user),
                  ),
                );
              },
            ),
    );
  }
}
