import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../models/user.dart';

class DbService {
  static const String _tasksKey = 'tasks';
  static const String _seededKey = 'seeded';

  // Fixed team list (no real sign-up in this app)
  List<AppUser> getUsers() {
    return [
      AppUser(id: 'u1', name: 'Erin', role: 'Data & Logic Lead'),
      AppUser(id: 'u2', name: 'Cynthia', role: 'Team Screen'),
      AppUser(id: 'u3', name: 'Cherish', role: 'Task Browsing'),
      AppUser(id: 'u4', name: 'Merveille', role: 'Forms & Dashboard'),
    ];
  }

  static const String _currentUserKey = 'currentUserId';

  Future<void> saveCurrentUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, id);
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool(_seededKey) ?? false)) {
      await _seedSampleTasks(prefs);
    }

    final raw = prefs.getString(_tasksKey);
    if (raw == null) return [];

    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return []; // corrupted data: start empty instead of crashing
    }
  }

  Future<void> saveTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getTasks();

    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task; // edit an existing task
    } else {
      tasks.add(task); // add a new task
    }
    await _writeTasks(prefs, tasks);
  }

  Future<void> deleteTask(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    await _writeTasks(prefs, tasks);
  }

  Future<void> _writeTasks(SharedPreferences prefs, List<Task> tasks) async {
    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, encoded);
  }

  // Sample tasks on first launch, so all four SLA states are visible
  Future<void> _seedSampleTasks(SharedPreferences prefs) async {
    final now = DateTime.now();
    final samples = [
      Task(
        id: 't1',
        title: 'Design login screen',
        description: 'Finish the user selection layout',
        assigneeId: 'u1',
        priority: 'High',
        deadline: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: 't2',
        title: 'Write validation rules',
        description: 'Title and deadline are required',
        assigneeId: 'u4',
        priority: 'Medium',
        deadline: now.add(const Duration(hours: 24)),
      ),
      Task(
        id: 't3',
        title: 'Build team screen',
        description: 'List members and their tasks',
        assigneeId: 'u2',
        priority: 'Low',
        deadline: now.add(const Duration(days: 7)),
      ),
      Task(
        id: 't4',
        title: 'Set up repository',
        description: 'Create branches for everyone',
        assigneeId: 'u1',
        priority: 'Medium',
        deadline: now.add(const Duration(days: 2)),
        isCompleted: true,
      ),
    ];
    await _writeTasks(prefs, samples);
    await prefs.setBool(_seededKey, true);
  }
}
