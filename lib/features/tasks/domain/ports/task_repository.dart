import '../task.dart';
import '../task_details.dart';

/// Puerto de salida: dónde se guardan las tareas.
abstract interface class TaskRepository {
  Future<List<Task>> findAll();

  Future<Task?> findById(int id);

  /// Crea una tarea pendiente y la devuelve con su `id`.
  Future<Task> insert(TaskDetails details, {required DateTime createdAt});

  /// Guarda los cambios. Devuelve `false` si la tarea no existe.
  Future<bool> update(Task task);

  /// Devuelve `false` si la tarea no existe.
  Future<bool> delete(int id);
}
