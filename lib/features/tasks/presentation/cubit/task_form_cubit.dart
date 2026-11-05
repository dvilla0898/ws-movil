import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../application/task_input.dart';
import '../../application/use_cases/create_task_use_case.dart';
import '../../application/use_cases/get_task_use_case.dart';
import '../../application/use_cases/update_task_use_case.dart';
import '../../domain/task.dart';

enum TaskFormStatus { loading, ready, saving, saved, loadFailure }

class TaskFormState extends Equatable {
  const TaskFormState({required this.status, this.initialTask, this.failure});

  final TaskFormStatus status;

  /// Tarea que se está editando (null al crear una nueva).
  final Task? initialTask;

  /// Último error: de validación (se muestra en el campo) o de otro tipo.
  final Failure? failure;

  ValidationFailure? fieldFailure(String field) {
    final current = failure;
    return current is ValidationFailure && current.field == field
        ? current
        : null;
  }

  @override
  List<Object?> get props => [status, initialTask, failure];
}

/// Cubit del formulario. Sirve para las dos pantallas: registrar y actualizar.
class TaskFormCubit extends Cubit<TaskFormState> {
  /// Formulario vacío para registrar una tarea nueva.
  TaskFormCubit.create({required CreateTaskUseCase createTask})
    : _createTask = createTask,
      _getTask = null,
      _updateTask = null,
      _taskId = null,
      super(const TaskFormState(status: TaskFormStatus.ready));

  /// Formulario para actualizar la tarea [taskId]. Llama a [load] al crearlo.
  TaskFormCubit.edit({
    required int taskId,
    required GetTaskUseCase getTask,
    required UpdateTaskUseCase updateTask,
  }) : _createTask = null,
       _getTask = getTask,
       _updateTask = updateTask,
       _taskId = taskId,
       super(const TaskFormState(status: TaskFormStatus.loading));

  final CreateTaskUseCase? _createTask;
  final GetTaskUseCase? _getTask;
  final UpdateTaskUseCase? _updateTask;
  final int? _taskId;

  bool get isEditing => _taskId != null;

  Future<void> load() async {
    final getTask = _getTask;
    final taskId = _taskId;
    if (getTask == null || taskId == null) return;

    emit(const TaskFormState(status: TaskFormStatus.loading));
    final result = await getTask(taskId);
    emit(switch (result) {
      Ok(:final value) => TaskFormState(
        status: TaskFormStatus.ready,
        initialTask: value,
      ),
      Err(:final failure) => TaskFormState(
        status: TaskFormStatus.loadFailure,
        failure: failure,
      ),
    });
  }

  Future<void> submit(TaskInput input) async {
    if (state.status == TaskFormStatus.saving) return;
    emit(
      TaskFormState(
        status: TaskFormStatus.saving,
        initialTask: state.initialTask,
      ),
    );

    final updateTask = _updateTask;
    final createTask = _createTask;
    final taskId = _taskId;
    final Result<Task> result;
    if (updateTask != null && taskId != null) {
      result = await updateTask(taskId, input);
    } else {
      result = await createTask!(input);
    }

    emit(switch (result) {
      Ok() => TaskFormState(
        status: TaskFormStatus.saved,
        initialTask: state.initialTask,
      ),
      Err(:final failure) => TaskFormState(
        status: TaskFormStatus.ready,
        initialTask: state.initialTask,
        failure: failure,
      ),
    });
  }
}
