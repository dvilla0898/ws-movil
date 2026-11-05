import 'package:sqflite/sqflite.dart';

import '../domain/ports/task_repository.dart';
import '../domain/task.dart';
import '../domain/task_details.dart';
import '../domain/task_priority.dart';

/// Adaptador de [TaskRepository] sobre la tabla `tasks` de SQLite.
///
/// Se encarga de traducir entre filas (`Map`) y entidades [Task]. SQLite no
/// tiene tipos para fechas ni booleanos: las fechas se guardan como texto
/// ISO-8601 y `is_done` como 0/1.
class SqliteTaskRepository implements TaskRepository {
  const SqliteTaskRepository(this._db);

  final Database _db;

  static const _table = 'tasks';

  @override
  Future<List<Task>> findAll() async {
    final rows = await _db.query(_table);
    return rows.map(_toTask).toList();
  }

  @override
  Future<Task?> findById(int id) async {
    final rows = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _toTask(rows.first);
  }

  @override
  Future<Task> insert(TaskDetails details, {required DateTime createdAt}) async {
    final row = {
      'title': details.title,
      'description': details.description,
      'priority': details.priority.name,
      'due_date': details.dueDate?.toIso8601String(),
      'is_done': 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': createdAt.toIso8601String(),
    };
    final id = await _db.insert(_table, row);
    return _toTask({...row, 'id': id});
  }

  @override
  Future<bool> update(Task task) async {
    final changed = await _db.update(
      _table,
      {
        'title': task.title,
        'description': task.description,
        'priority': task.priority.name,
        'due_date': task.dueDate?.toIso8601String(),
        'is_done': task.isDone ? 1 : 0,
        'updated_at': task.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return changed > 0;
  }

  @override
  Future<bool> delete(int id) async {
    final deleted = await _db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
    return deleted > 0;
  }

  Task _toTask(Map<String, Object?> row) {
    final dueDate = row['due_date'] as String?;
    return Task(
      id: row['id']! as int,
      title: row['title']! as String,
      description: row['description']! as String,
      priority: TaskPriority.fromName(row['priority']! as String),
      dueDate: dueDate == null ? null : DateTime.parse(dueDate),
      isDone: row['is_done'] == 1,
      createdAt: DateTime.parse(row['created_at']! as String),
      updatedAt: DateTime.parse(row['updated_at']! as String),
    );
  }
}
