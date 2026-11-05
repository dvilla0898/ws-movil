import 'package:ws_movil/app/dependencies.dart';
import 'package:ws_movil/core/domain/clock.dart';
import 'package:ws_movil/features/auth/domain/ports/session_repository.dart';
import 'package:ws_movil/features/auth/domain/ports/user_repository.dart';
import 'package:ws_movil/features/auth/domain/session.dart';
import 'package:ws_movil/features/auth/domain/user.dart';
import 'package:ws_movil/features/auth/infrastructure/sha256_password_hasher.dart';
import 'package:ws_movil/features/tasks/domain/ports/task_repository.dart';
import 'package:ws_movil/features/tasks/domain/task.dart';
import 'package:ws_movil/features/tasks/domain/task_details.dart';

// Adaptadores falsos (en memoria) para los tests.
//
// Gracias a la arquitectura hexagonal, los casos de uso no saben si hablan con
// SQLite o con una lista en memoria: solo conocen los puertos.

class FixedClock implements Clock {
  FixedClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}

class InMemoryUserRepository implements UserRepository {
  final users = <User>[];

  @override
  Future<int> count() async => users.length;

  @override
  Future<User> create({
    required String username,
    required String passwordHash,
    required String salt,
  }) async {
    final user = User(
      id: users.length + 1,
      username: username,
      passwordHash: passwordHash,
      salt: salt,
    );
    users.add(user);
    return user;
  }

  @override
  Future<User?> findByUsername(String username) async {
    for (final user in users) {
      if (user.username == username) return user;
    }
    return null;
  }
}

class InMemorySessionRepository implements SessionRepository {
  Session? session;

  @override
  Future<void> clear() async {
    session = null;
  }

  @override
  Future<Session?> current() async => session;

  @override
  Future<void> save(Session session) async {
    this.session = session;
  }
}

class InMemoryTaskRepository implements TaskRepository {
  final tasks = <int, Task>{};
  var _nextId = 1;

  @override
  Future<bool> delete(int id) async => tasks.remove(id) != null;

  @override
  Future<List<Task>> findAll() async => tasks.values.toList();

  @override
  Future<Task?> findById(int id) async => tasks[id];

  @override
  Future<Task> insert(TaskDetails details, {required DateTime createdAt}) async {
    final task = Task(
      id: _nextId++,
      title: details.title,
      description: details.description,
      priority: details.priority,
      dueDate: details.dueDate,
      isDone: false,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    tasks[task.id] = task;
    return task;
  }

  @override
  Future<bool> update(Task task) async {
    if (!tasks.containsKey(task.id)) return false;
    tasks[task.id] = task;
    return true;
  }
}

/// Dependencias de la app con todo en memoria (para los tests de widgets).
AppDependencies inMemoryDependencies({Clock? clock}) {
  return AppDependencies(
    users: InMemoryUserRepository(),
    sessions: InMemorySessionRepository(),
    tasks: InMemoryTaskRepository(),
    hasher: Sha256PasswordHasher(),
    clock: clock ?? const SystemClock(),
  );
}
