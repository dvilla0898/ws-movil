import '../domain/task_priority.dart';

/// Datos que llegan desde el formulario para crear o actualizar una tarea.
///
/// Aún no están validados: eso lo hacen los casos de uso con `TaskDetails`.
class TaskInput {
  const TaskInput({
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.dueDate,
  });

  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime? dueDate;
}
