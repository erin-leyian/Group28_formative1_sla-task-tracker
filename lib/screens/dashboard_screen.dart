import 'package:flutter/material.dart';

import '../models/task.dart';
import '../routes.dart';
import '../services/db_service.dart';
import '../services/sla_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';

// Merveille: Project Dashboard
// Shows overall progress, a count per SLA status, and a "needs attention" list.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DbService _db = DbService();
  List<Task> _tasks = [];
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

  // How many tasks currently have each SLA status
  Map<SlaStatus, int> get _counts {
    final counts = {for (final s in SlaStatus.values) s: 0};
    for (final t in _tasks) {
      final status = computeSlaStatus(t);
      counts[status] = counts[status]! + 1;
    }
    return counts;
  }

  // Overdue first, then At Risk; earliest deadline first inside each group
  List<Task> get _needsAttention {
    final list = _tasks.where((t) {
      final s = computeSlaStatus(t);
      return s == SlaStatus.overdue || s == SlaStatus.atRisk;
    }).toList();
    list.sort((a, b) {
      final aOverdue = computeSlaStatus(a) == SlaStatus.overdue ? 0 : 1;
      final bOverdue = computeSlaStatus(b) == SlaStatus.overdue ? 0 : 1;
      if (aOverdue != bOverdue) return aOverdue.compareTo(bOverdue);
      return a.deadline.compareTo(b.deadline);
    });
    return list;
  }

  String _assigneeName(String id) {
    for (final u in _db.getUsers()) {
      if (u.id == id) return u.name;
    }
    return 'Unassigned';
  }

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _label(SlaStatus s) {
    switch (s) {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(AppRoutes.taskForm),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.page,
                  AppSpacing.page,
                  88, // space so the button does not cover the last card
                ),
                children: [
                  _buildProgressCard(context),
                  const SizedBox(height: AppSpacing.section),
                  Text(
                    'SLA status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.item),
                  _buildStatusGrid(),
                  const SizedBox(height: AppSpacing.section),
                  Text(
                    'Needs attention',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.item),
                  ..._buildAttentionList(),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final total = _tasks.length;
    final done = _counts[SlaStatus.completed]!;
    final percent = total == 0 ? 0 : (done / total * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.item),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.item),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: AppSpacing.item),
            Text('$done of $total tasks completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusGrid() {
    final counts = _counts;
    const order = [
      SlaStatus.onTrack,
      SlaStatus.atRisk,
      SlaStatus.overdue,
      SlaStatus.completed,
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.item,
      crossAxisSpacing: AppSpacing.item,
      childAspectRatio: 1.8,
      children: [
        for (final s in order)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${counts[s]}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.slaColor(s),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(_label(s)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildAttentionList() {
    final tasks = _needsAttention;
    if (tasks.isEmpty) {
      return const [
        Card(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.page),
            child: Text('Nothing needs attention. Great work!'),
          ),
        ),
      ];
    }
    return [
      for (final task in tasks)
        Card(
          child: ListTile(
            title: Text(task.title),
            subtitle: Text(
              '${_assigneeName(task.assigneeId)} · '
              'Due ${_date(task.deadline)} · ${task.priority}',
            ),
            trailing: StatusChip(status: computeSlaStatus(task)),
            onTap: () => _open(AppRoutes.taskDetails, args: task),
          ),
        ),
    ];
  }
}
