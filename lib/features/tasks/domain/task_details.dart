import 'package:equatable/equatable.dart';

import '../../../core/domain/result.dart';
import 'task_priority.dart';
import 'value_objects/task_description.dart';
import 'value_objects/task_title.dart';

/// Contenido editable de una tarea, ya validado.
///
/// Se usa al crear y al actualizar: los dos casos de uso comparten las mismas
/// reglas de validación.
class TaskDetails extends Equatable {
  const TaskDetails._({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
  });

  final String title;
  final String description;
  final TaskPriority priority;

  /// Fecha límite (solo el día, sin hora). Opcional.
  final DateTime? dueDate;

  static Result<TaskDetails> create({
    required String title,
    required String description,
    required TaskPriority priority,
    DateTime? dueDate,
  }) {
    final TaskTitle validTitle;
    switch (TaskTitle.create(title)) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        validTitle = value;
    }

    final TaskDescription validDescription;
    switch (TaskDescription.create(description)) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        validDescription = value;
    }

    return Ok(
      TaskDetails._(
        title: validTitle.value,
        description: validDescription.value,
        priority: priority,
        dueDate: dueDate == null
            ? null
            : DateTime(dueDate.year, dueDate.month, dueDate.day),
      ),
    );
  }

  @override
  List<Object?> get props => [title, description, priority, dueDate];
}
