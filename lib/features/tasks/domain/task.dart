import 'package:equatable/equatable.dart';

import 'task_details.dart';
import 'task_priority.dart';

/// Entidad principal del módulo: una tarea de la lista.
class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.isDone,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool isDone;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Pendiente y con la fecha límite ya pasada.
  bool isOverdueAt(DateTime now) {
    final due = dueDate;
    if (isDone || due == null) return false;
    final today = DateTime(now.year, now.month, now.day);
    return due.isBefore(today);
  }

  /// Devuelve una copia con el contenido nuevo (lo usa "actualizar tarea").
  Task withDetails(TaskDetails details, {required DateTime updatedAt}) {
    return Task(
      id: id,
      title: details.title,
      description: details.description,
      priority: details.priority,
      dueDate: details.dueDate,
      isDone: isDone,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Devuelve una copia marcada como hecha o pendiente.
  Task withDone(bool done, {required DateTime updatedAt}) {
    return Task(
      id: id,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      isDone: done,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    priority,
    dueDate,
    isDone,
    createdAt,
    updatedAt,
  ];
}
