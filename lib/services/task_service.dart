import 'package:sqflite/sqflite.dart';

import '../models/task_item.dart';
import 'database_service.dart';

class TaskService {
  TaskService(this._database);
  final DatabaseService _database;

  Future<List<TaskItem>> list(int userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed ASC, due_date IS NULL ASC, due_date ASC, created_at DESC',
    );
    return rows.map(TaskItem.fromMap).toList();
  }

  Future<int> create(TaskItem item) async {
    final db = await _database.database;
    return db.insert('tasks', item.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<bool> update(TaskItem item) async {
    if (item.id == null) return false;
    final db = await _database.database;
    final count = await db.update(
      'tasks',
      item.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [item.id, item.userId],
    );
    return count > 0;
  }

  Future<bool> delete(TaskItem item) async {
    if (item.id == null) return false;
    final db = await _database.database;
    final count = await db.delete(
      'tasks',
      where: 'id = ? AND user_id = ?',
      whereArgs: [item.id, item.userId],
    );
    return count > 0;
  }
}
