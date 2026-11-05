import '../../../../core/application/guard.dart';
import '../../../../core/domain/clock.dart';
import '../../../../core/domain/result.dart';
import '../../domain/ports/task_repository.dart';
import '../../domain/task.dart';
import '../../domain/task_details.dart';
import '../task_input.dart';

/// Caso de uso: registrar una tarea nueva (empieza como pendiente).
class CreateTaskUseCase {
  const CreateTaskUseCase({required TaskRepository tasks, required Clock clock})
    : _tasks = tasks,
      _clock = clock;

  final TaskRepository _tasks;
  final Clock _clock;

  Future<Result<Task>> call(TaskInput input) {
    return guard(() async {
      final TaskDetails details;
      switch (TaskDetails.create(
        title: input.title,
        description: input.description,
        priority: input.priority,
        dueDate: input.dueDate,
      )) {
        case Err(:final failure):
          return Err(failure);
        case Ok(:final value):
          details = value;
      }

      final task = await _tasks.insert(details, createdAt: _clock.now());
      return Ok(task);
    });
  }
}
