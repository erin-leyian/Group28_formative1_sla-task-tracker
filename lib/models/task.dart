class Task {
  final String id;
  final String title;
  final String description;
  final String assigneeId;
  final String priority; // 'Low', 'Medium', 'High'
  final DateTime deadline;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assigneeId,
    required this.priority,
    required this.deadline,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assigneeId': assigneeId,
      'priority': priority,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      assigneeId: json['assigneeId'],
      priority: json['priority'],
      deadline: DateTime.parse(json['deadline']),
      isCompleted: json['isCompleted'],
    );
  }
}
