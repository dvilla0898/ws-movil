import '../../../../core/application/guard.dart';
import '../../../../core/domain/result.dart';
import '../../domain/ports/task_repository.dart';
import '../../domain/task.dart';

/// Qué tareas mostrar en el listado.
enum TaskFilter { all, pending, done }

/// Caso de uso: listar las tareas filtradas y ordenadas.
///
/// Orden: primero las pendientes; dentro de cada grupo, la fecha límite más
/// cercana (sin fecha al final), luego la prioridad más alta y luego la más
/// reciente.
class ListTasksUseCase {
  const ListTasksUseCase({required TaskRepository tasks}) : _tasks = tasks;

  final TaskRepository _tasks;

  Future<Result<List<Task>>> call({TaskFilter filter = TaskFilter.all}) {
    return guard(() async {
      final all = await _tasks.findAll();
      final filtered = switch (filter) {
        TaskFilter.all => all,
        TaskFilter.pending => all.where((task) => !task.isDone).toList(),
        TaskFilter.done => all.where((task) => task.isDone).toList(),
      };
      return Ok([...filtered]..sort(_compare));
    });
  }

  static int _compare(Task a, Task b) {
    if (a.isDone != b.isDone) return a.isDone ? 1 : -1;

    final aDue = a.dueDate;
    final bDue = b.dueDate;
    if (aDue != bDue) {
      if (aDue == null) return 1;
      if (bDue == null) return -1;
      return aDue.compareTo(bDue);
    }

    if (a.priority != b.priority) {
      return b.priority.index.compareTo(a.priority.index);
    }
    return b.createdAt.compareTo(a.createdAt);
  }
}
