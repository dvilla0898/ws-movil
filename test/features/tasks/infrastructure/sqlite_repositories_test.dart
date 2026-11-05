import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ws_movil/core/infrastructure/app_database.dart';
import 'package:ws_movil/features/auth/domain/session.dart';
import 'package:ws_movil/features/auth/infrastructure/sqlite_session_repository.dart';
import 'package:ws_movil/features/auth/infrastructure/sqlite_user_repository.dart';
import 'package:ws_movil/features/tasks/domain/task_details.dart';
import 'package:ws_movil/features/tasks/domain/task_priority.dart';
import 'package:ws_movil/features/tasks/infrastructure/sqlite_task_repository.dart';
import 'package:ws_movil/core/domain/result.dart';

/// Tests de los adaptadores de SQLite con una base de datos en memoria.
/// `sqflite_common_ffi` permite usar SQLite en el ordenador, fuera del móvil.
void main() {
  late Database db;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
  });

  tearDown(() => db.close());

  TaskDetails details(String title, {DateTime? dueDate}) {
    final result = TaskDetails.create(
      title: title,
      description: 'Descripción',
      priority: TaskPriority.high,
      dueDate: dueDate,
    );
    return (result as Ok<TaskDetails>).value;
  }

  group('SqliteTaskRepository', () {
    test('inserta y lee una tarea con todos sus campos', () async {
      final repository = SqliteTaskRepository(db);
      final createdAt = DateTime(2026, 11, 4, 9);

      final inserted = await repository.insert(
        details('Comprar fruta', dueDate: DateTime(2026, 11, 10)),
        createdAt: createdAt,
      );
      final found = await repository.findById(inserted.id);

      expect(found, inserted);
      expect(found!.priority, TaskPriority.high);
      expect(found.dueDate, DateTime(2026, 11, 10));
      expect(found.isDone, isFalse);
    });

    test('actualiza y elimina', () async {
      final repository = SqliteTaskRepository(db);
      final task = await repository.insert(
        details('Comprar fruta'),
        createdAt: DateTime(2026),
      );

      final done = task.withDone(true, updatedAt: DateTime(2026, 2));
      expect(await repository.update(done), isTrue);
      expect((await repository.findById(task.id))!.isDone, isTrue);

      expect(await repository.delete(task.id), isTrue);
      expect(await repository.findAll(), isEmpty);
      expect(await repository.delete(task.id), isFalse);
    });
  });

  group('SqliteUserRepository y SqliteSessionRepository', () {
    test('crea y busca usuarios', () async {
      final users = SqliteUserRepository(db);

      expect(await users.count(), 0);
      await users.create(username: 'admin', passwordHash: 'h', salt: 's');

      expect(await users.count(), 1);
      expect((await users.findByUsername('admin'))!.salt, 's');
      expect(await users.findByUsername('otro'), isNull);
    });

    test('guarda una única sesión y la borra', () async {
      final users = SqliteUserRepository(db);
      final sessions = SqliteSessionRepository(db);
      final user = await users.create(
        username: 'admin',
        passwordHash: 'h',
        salt: 's',
      );
      final session = Session(
        userId: user.id,
        username: user.username,
        startedAt: DateTime(2026, 11, 4),
        expiresAt: DateTime(2026, 11, 11),
      );

      await sessions.save(session);
      await sessions.save(session);

      expect(await sessions.current(), session);
      await sessions.clear();
      expect(await sessions.current(), isNull);
    });
  });
}
