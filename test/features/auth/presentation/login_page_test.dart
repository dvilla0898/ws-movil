import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ws_movil/app/app.dart';
import 'package:ws_movil/app/dependencies.dart';

import '../../../helpers/fakes.dart';

void main() {
  late AppDependencies dependencies;

  setUp(() async {
    dependencies = inMemoryDependencies();
    await dependencies.seedDefaultUser();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(WsMovilApp(dependencies: dependencies));
    await tester.pumpAndSettle();
  }

  Future<void> signIn(
    WidgetTester tester, {
    required String username,
    required String password,
  }) async {
    await tester.enterText(find.byKey(const Key('login_username')), username);
    await tester.enterText(find.byKey(const Key('login_password')), password);
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('sin sesión muestra el login', (tester) async {
    await pumpApp(tester);

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('con credenciales incorrectas muestra el error', (tester) async {
    await pumpApp(tester);

    await signIn(tester, username: 'admin', password: 'incorrecta');

    expect(find.text('Usuario o contraseña incorrectos'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('muestra el error de validación bajo el campo', (tester) async {
    await pumpApp(tester);

    await signIn(tester, username: '', password: 'admin123');

    expect(find.text('El usuario es obligatorio'), findsOneWidget);
  });

  testWidgets('admin / admin123 entra al listado y puede salir', (
    tester,
  ) async {
    await pumpApp(tester);

    await signIn(tester, username: 'admin', password: 'admin123');

    expect(find.text('Hola, admin'), findsOneWidget);
    expect(find.text('No hay tareas'), findsOneWidget);

    await tester.tap(find.byKey(const Key('logout')));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('el selector de idioma cambia los textos a inglés', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Test user: admin / admin123'), findsOneWidget);
  });
}
