import '../../../../core/application/guard.dart';
import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../domain/ports/task_repository.dart';
import '../../domain/task.dart';

/// Caso de uso: obtener una tarea por su id (para la pantalla de edición).
class GetTaskUseCase {
  const GetTaskUseCase({required TaskRepository tasks}) : _tasks = tasks;

  final TaskRepository _tasks;

  Future<Result<Task>> call(int id) {
    return guard(() async {
      final task = await _tasks.findById(id);
      return task == null ? const Err(NotFoundFailure()) : Ok(task);
    });
  }
}
