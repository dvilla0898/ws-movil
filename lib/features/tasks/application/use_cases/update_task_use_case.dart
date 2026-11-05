import '../../../../core/application/guard.dart';
import '../../../../core/domain/clock.dart';
import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../domain/ports/task_repository.dart';
import '../../domain/task.dart';
import '../../domain/task_details.dart';
import '../task_input.dart';

/// Caso de uso: actualizar el contenido de una tarea existente.
class UpdateTaskUseCase {
  const UpdateTaskUseCase({required TaskRepository tasks, required Clock clock})
    : _tasks = tasks,
      _clock = clock;

  final TaskRepository _tasks;
  final Clock _clock;

  Future<Result<Task>> call(int id, TaskInput input) {
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

      final current = await _tasks.findById(id);
      if (current == null) return const Err(NotFoundFailure());

      final updated = current.withDetails(details, updatedAt: _clock.now());
      await _tasks.update(updated);
      return Ok(updated);
    });
  }
}
