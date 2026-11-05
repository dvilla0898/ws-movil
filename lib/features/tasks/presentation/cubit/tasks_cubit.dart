import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../application/use_cases/delete_task_use_case.dart';
import '../../application/use_cases/list_tasks_use_case.dart';
import '../../application/use_cases/toggle_task_status_use_case.dart';
import '../../domain/task.dart';

enum TasksStatus { loading, ready, failure }

class TasksState extends Equatable {
  const TasksState({
    this.status = TasksStatus.loading,
    this.tasks = const [],
    this.filter = TaskFilter.all,
    this.failure,
  });

  final TasksStatus status;
  final List<Task> tasks;
  final TaskFilter filter;
  final Failure? failure;

  TasksState copyWith({
    TasksStatus? status,
    List<Task>? tasks,
    TaskFilter? filter,
    Failure? failure,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, tasks, filter, failure];
}

/// Cubit de la pantalla de listado.
class TasksCubit extends Cubit<TasksState> {
  TasksCubit({
    required ListTasksUseCase listTasks,
    required ToggleTaskStatusUseCase toggleTaskStatus,
    required DeleteTaskUseCase deleteTask,
  }) : _listTasks = listTasks,
       _toggleTaskStatus = toggleTaskStatus,
       _deleteTask = deleteTask,
       super(const TasksState());

  final ListTasksUseCase _listTasks;
  final ToggleTaskStatusUseCase _toggleTaskStatus;
  final DeleteTaskUseCase _deleteTask;

  Future<void> load() async {
    // Solo muestra el indicador de carga la primera vez; al recargar se
    // mantiene la lista visible.
    if (state.tasks.isEmpty) emit(state.copyWith(status: TasksStatus.loading));

    final result = await _listTasks(filter: state.filter);
    emit(switch (result) {
      Ok(:final value) => state.copyWith(
        status: TasksStatus.ready,
        tasks: value,
      ),
      Err(:final failure) => state.copyWith(
        status: TasksStatus.failure,
        failure: failure,
      ),
    });
  }

  Future<void> changeFilter(TaskFilter filter) async {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter, status: TasksStatus.loading));
    await load();
  }

  /// Devuelve el fallo, o `null` si salió bien.
  Future<Failure?> toggle(int id) async {
    final result = await _toggleTaskStatus(id);
    await load();
    return result is Err<Task> ? result.failure : null;
  }

  /// Devuelve el fallo, o `null` si salió bien.
  Future<Failure?> delete(int id) async {
    final result = await _deleteTask(id);
    await load();
    return result is Err<int> ? result.failure : null;
  }
}
