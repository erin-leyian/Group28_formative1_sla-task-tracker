import 'package:flutter_test/flutter_test.dart';
import 'package:sla_task_tracker/models/task.dart';
import 'package:sla_task_tracker/services/sla_service.dart';

Task makeTask({
  required DateTime deadline,
  bool done = false,
  String priority = 'Medium',
}) {
  return Task(
    id: 't1',
    title: 'Test task',
    description: '',
    assigneeId: 'u1',
    priority: priority,
    deadline: deadline,
    isCompleted: done,
  );
}

void main() {
  final now = DateTime(2026, 10, 11, 12, 0);

  test('completed task is Completed even if the deadline passed', () {
    final task = makeTask(
      deadline: now.subtract(const Duration(days: 2)),
      done: true,
    );
    expect(computeSlaStatus(task, now: now), SlaStatus.completed);
  });

  test('unfinished task past its deadline is Overdue', () {
    final task = makeTask(deadline: now.subtract(const Duration(hours: 1)));
    expect(computeSlaStatus(task, now: now), SlaStatus.overdue);
  });

  test('task with exactly 48 hours left is At Risk', () {
    final task = makeTask(deadline: now.add(const Duration(hours: 48)));
    expect(computeSlaStatus(task, now: now), SlaStatus.atRisk);
  });

  test('High priority task with 60 hours left is At Risk', () {
    final task = makeTask(
      deadline: now.add(const Duration(hours: 60)),
      priority: 'High',
    );
    expect(computeSlaStatus(task, now: now), SlaStatus.atRisk);
  });

  test('Medium priority task with 60 hours left is On Track', () {
    final task = makeTask(deadline: now.add(const Duration(hours: 60)));
    expect(computeSlaStatus(task, now: now), SlaStatus.onTrack);
  });
}
