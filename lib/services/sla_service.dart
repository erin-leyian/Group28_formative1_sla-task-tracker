import '../models/task.dart';

enum SlaStatus { onTrack, atRisk, overdue, completed }

SlaStatus computeSlaStatus(Task task, {DateTime? now}) {
  final current = now ?? DateTime.now();

  if (task.isCompleted) return SlaStatus.completed;
  if (task.deadline.isBefore(current)) return SlaStatus.overdue;

  final hoursLeft = task.deadline.difference(current).inHours;
  if (hoursLeft <= 48) return SlaStatus.atRisk;
  if (task.priority == 'High' && hoursLeft <= 72) return SlaStatus.atRisk;

  return SlaStatus.onTrack;
}
