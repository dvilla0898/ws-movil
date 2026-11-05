import '../../../../core/application/guard.dart';
import '../../../../core/domain/clock.dart';
import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../domain/ports/task_repository.dart';
import '../../domain/task.dart';

/// Caso de uso: marcar una tarea como hecha o volver a dejarla pendiente.
class ToggleTaskStatusUseCase {
  const ToggleTaskStatusUseCase({
    required TaskRepository tasks,
    required Clock clock,
  }) : _tasks = tasks,
       _clock = clock;

  final TaskRepository _tasks;
  final Clock _clock;

  Future<Result<Task>> call(int id) {
    return guard(() async {
      final current = await _tasks.findById(id);
      if (current == null) return const Err(NotFoundFailure());

      final updated = current.withDone(!current.isDone, updatedAt: _clock.now());
      await _tasks.update(updated);
      return Ok(updated);
    });
  }
}
