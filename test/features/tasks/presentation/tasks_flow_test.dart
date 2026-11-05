import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ws_movil/app/app.dart';
import 'package:ws_movil/app/dependencies.dart';
import 'package:ws_movil/features/tasks/application/task_input.dart';

import '../../../helpers/fakes.dart';

/// Recorre las pantallas de tareas como lo haría un usuario: registrar,
/// actualizar, marcar como hecha y eliminar con el modal.
void main() {
  late AppDependencies dependencies;

  setUp(() async {
    dependencies = inMemoryDependencies();
    await dependencies.seedDefaultUser();
    await dependencies.login(username: 'admin', password: 'admin123');
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(WsMovilApp(dependencies: dependencies));
    await tester.pumpAndSettle();
  }

  testWidgets('registra una tarea nueva', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('new_task')));
    await tester.pumpAndSettle();
    expect(find.text('Nueva tarea'), findsWidgets);

    await tester.enterText(
      find.byKey(const Key('task_title')),
      'Comprar fruta',
    );
    await tester.tap(find.text('Alta'));
    await tester.tap(find.byKey(const Key('task_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Tarea creada'), findsOneWidget);
    expect(find.text('Comprar fruta'), findsOneWidget);
    expect(find.text('Alta'), findsOneWidget);
  });

  testWidgets('no deja guardar sin título', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('new_task')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('task_submit')));
    await tester.pumpAndSettle();

    expect(find.text('El título es obligatorio'), findsOneWidget);
  });

  testWidgets('actualiza una tarea existente', (tester) async {
    await dependencies.createTask(const TaskInput(title: 'Comprar fruta'));
    await pumpApp(tester);

    await tester.tap(find.text('Comprar fruta'));
    await tester.pumpAndSettle();
    expect(find.text('Editar tarea'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('task_title')),
      'Comprar verdura',
    );
    await tester.tap(find.byKey(const Key('task_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Tarea actualizada'), findsOneWidget);
    expect(find.text('Comprar verdura'), findsOneWidget);
    expect(find.text('Comprar fruta'), findsNothing);
  });

  testWidgets('marca una tarea como hecha y la filtra', (tester) async {
    await dependencies.createTask(const TaskInput(title: 'Comprar fruta'));
    await pumpApp(tester);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();

    expect(find.text('Comprar fruta'), findsNothing);

    await tester.tap(find.text('Hechas'));
    await tester.pumpAndSettle();

    expect(find.text('Comprar fruta'), findsOneWidget);
  });

  testWidgets('el modal de eliminar permite cancelar o confirmar', (
    tester,
  ) async {
    await dependencies.createTask(const TaskInput(title: 'Comprar fruta'));
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('¿Eliminar tarea?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Comprar fruta'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_delete')));
    await tester.pumpAndSettle();

    expect(find.text('Tarea eliminada'), findsOneWidget);
    expect(find.text('No hay tareas'), findsOneWidget);
  });
}
