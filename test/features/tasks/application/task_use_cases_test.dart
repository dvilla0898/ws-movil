import 'package:flutter_test/flutter_test.dart';
import 'package:ws_movil/core/domain/failure.dart';
import 'package:ws_movil/core/domain/result.dart';
import 'package:ws_movil/features/tasks/application/task_input.dart';
import 'package:ws_movil/features/tasks/application/use_cases/create_task_use_case.dart';
import 'package:ws_movil/features/tasks/application/use_cases/delete_task_use_case.dart';
import 'package:ws_movil/features/tasks/application/use_cases/get_task_use_case.dart';
import 'package:ws_movil/features/tasks/application/use_cases/list_tasks_use_case.dart';
import 'package:ws_movil/features/tasks/application/use_cases/toggle_task_status_use_case.dart';
import 'package:ws_movil/features/tasks/application/use_cases/update_task_use_case.dart';
import 'package:ws_movil/features/tasks/domain/task.dart';
import 'package:ws_movil/features/tasks/domain/task_priority.dart';

import '../../../helpers/fakes.dart';

void main() {
  late InMemoryTaskRepository repository;
  late FixedClock clock;
  late CreateTaskUseCase createTask;

  setUp(() {
    repository = InMemoryTaskRepository();
    clock = FixedClock(DateTime(2026, 11, 4, 9));
    createTask = CreateTaskUseCase(tasks: repository, clock: clock);
  });

  Future<Task> create(
    String title, {
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    final result = await createTask(
      TaskInput(title: title, priority: priority, dueDate: dueDate),
    );
    return (result as Ok<Task>).value;
  }

  test('CreateTask guarda una tarea pendiente con la hora del reloj', () async {
    final task = await create('Comprar fruta');

    expect(task.isDone, isFalse);
    expect(task.createdAt, clock.current);
    expect(repository.tasks, hasLength(1));
  });

  test('CreateTask no guarda nada si el título no es válido', () async {
    final result = await createTask(const TaskInput(title: ' '));

    expect((result as Err).failure, isA<ValidationFailure>());
    expect(repository.tasks, isEmpty);
  });

  test('GetTask devuelve NotFound si no existe', () async {
    final result = await GetTaskUseCase(tasks: repository)(99);

    expect((result as Err).failure, const NotFoundFailure());
  });

  test('UpdateTask cambia el contenido y la fecha de actualización', () async {
    final task = await create('Comprar fruta');
    clock.current = clock.current.add(const Duration(hours: 1));

    final result = await UpdateTaskUseCase(tasks: repository, clock: clock)(
      task.id,
      const TaskInput(title: 'Comprar verdura', priority: TaskPriority.high),
    );

    final updated = (result as Ok<Task>).value;
    expect(updated.title, 'Comprar verdura');
    expect(updated.priority, TaskPriority.high);
    expect(updated.createdAt, task.createdAt);
    expect(updated.updatedAt, clock.current);
    expect(repository.tasks[task.id], updated);
  });

  test('ToggleTaskStatus alterna entre hecha y pendiente', () async {
    final task = await create('Comprar fruta');
    final toggle = ToggleTaskStatusUseCase(tasks: repository, clock: clock);

    expect(((await toggle(task.id)) as Ok<Task>).value.isDone, isTrue);
    expect(((await toggle(task.id)) as Ok<Task>).value.isDone, isFalse);
  });

  test('DeleteTask elimina la tarea y avisa si no existe', () async {
    final task = await create('Comprar fruta');
    final deleteTask = DeleteTaskUseCase(tasks: repository);

    expect(((await deleteTask(task.id)) as Ok<int>).value, task.id);
    expect(repository.tasks, isEmpty);
    expect(
      ((await deleteTask(task.id)) as Err).failure,
      const NotFoundFailure(),
    );
  });

  group('ListTasks', () {
    late ListTasksUseCase listTasks;

    setUp(() => listTasks = ListTasksUseCase(tasks: repository));

    Future<List<String>> titles({TaskFilter filter = TaskFilter.all}) async {
      final result = await listTasks(filter: filter);
      return (result as Ok<List<Task>>).value.map((t) => t.title).toList();
    }

    test('ordena: pendientes primero, por fecha y luego prioridad', () async {
      await create('Sin fecha');
      await create(
        'Baja mañana',
        priority: TaskPriority.low,
        dueDate: DateTime(2026, 11, 5),
      );
      await create(
        'Alta mañana',
        priority: TaskPriority.high,
        dueDate: DateTime(2026, 11, 5),
      );
      await create('Hoy', dueDate: DateTime(2026, 11, 4));
      final done = await create('Hecha', dueDate: DateTime(2026, 11, 1));
      await ToggleTaskStatusUseCase(tasks: repository, clock: clock)(done.id);

      expect(await titles(), [
        'Hoy',
        'Alta mañana',
        'Baja mañana',
        'Sin fecha',
        'Hecha',
      ]);
    });

    test('filtra por pendientes y hechas', () async {
      await create('Pendiente');
      final done = await create('Hecha');
      await ToggleTaskStatusUseCase(tasks: repository, clock: clock)(done.id);

      expect(await titles(filter: TaskFilter.pending), ['Pendiente']);
      expect(await titles(filter: TaskFilter.done), ['Hecha']);
    });
  });
}
