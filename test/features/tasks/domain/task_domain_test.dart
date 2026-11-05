import 'package:flutter_test/flutter_test.dart';
import 'package:ws_movil/core/domain/failure.dart';
import 'package:ws_movil/core/domain/result.dart';
import 'package:ws_movil/features/tasks/domain/task.dart';
import 'package:ws_movil/features/tasks/domain/task_details.dart';
import 'package:ws_movil/features/tasks/domain/task_priority.dart';
import 'package:ws_movil/features/tasks/domain/value_objects/task_description.dart';
import 'package:ws_movil/features/tasks/domain/value_objects/task_title.dart';

void main() {
  group('TaskDetails', () {
    test('limpia el texto y guarda la fecha sin hora', () {
      final result = TaskDetails.create(
        title: '  Comprar fruta  ',
        description: ' Manzanas ',
        priority: TaskPriority.high,
        dueDate: DateTime(2026, 11, 10, 18, 30),
      );

      final details = (result as Ok<TaskDetails>).value;
      expect(details.title, 'Comprar fruta');
      expect(details.description, 'Manzanas');
      expect(details.dueDate, DateTime(2026, 11, 10));
    });

    test('el título es obligatorio', () {
      final result = TaskDetails.create(
        title: '',
        description: '',
        priority: TaskPriority.low,
      );

      expect(
        (result as Err).failure,
        const ValidationFailure('title', ValidationError.required),
      );
    });

    test('el título no puede ser demasiado largo', () {
      final result = TaskDetails.create(
        title: 'x' * (TaskTitle.maxLength + 1),
        description: '',
        priority: TaskPriority.low,
      );

      expect(
        ((result as Err).failure as ValidationFailure).error,
        ValidationError.tooLong,
      );
    });

    test('la descripción no puede ser demasiado larga', () {
      final result = TaskDetails.create(
        title: 'Título válido',
        description: 'x' * (TaskDescription.maxLength + 1),
        priority: TaskPriority.low,
      );

      expect(
        ((result as Err).failure as ValidationFailure).field,
        'description',
      );
    });
  });

  group('Task.isOverdueAt', () {
    Task taskDue(DateTime? due, {bool done = false}) => Task(
      id: 1,
      title: 'Tarea',
      description: '',
      priority: TaskPriority.medium,
      dueDate: due,
      isDone: done,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final now = DateTime(2026, 11, 4, 15);

    test('vence si la fecha ya pasó y sigue pendiente', () {
      expect(taskDue(DateTime(2026, 11, 3)).isOverdueAt(now), isTrue);
    });

    test('no vence el mismo día de la fecha límite', () {
      expect(taskDue(DateTime(2026, 11, 4)).isOverdueAt(now), isFalse);
    });

    test('una tarea hecha o sin fecha nunca vence', () {
      expect(
        taskDue(DateTime(2026, 11, 1), done: true).isOverdueAt(now),
        isFalse,
      );
      expect(taskDue(null).isOverdueAt(now), isFalse);
    });
  });
}
