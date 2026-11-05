import '../../../../core/application/guard.dart';
import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../domain/ports/task_repository.dart';

/// Caso de uso: eliminar una tarea. Devuelve el id eliminado.
class DeleteTaskUseCase {
  const DeleteTaskUseCase({required TaskRepository tasks}) : _tasks = tasks;

  final TaskRepository _tasks;

  Future<Result<int>> call(int id) {
    return guard(() async {
      final deleted = await _tasks.delete(id);
      return deleted ? Ok(id) : const Err(NotFoundFailure());
    });
  }
}
