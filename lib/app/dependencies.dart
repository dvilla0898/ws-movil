import 'package:sqflite/sqflite.dart';

import '../core/domain/clock.dart';
import '../features/auth/application/use_cases/get_current_session_use_case.dart';
import '../features/auth/application/use_cases/login_use_case.dart';
import '../features/auth/application/use_cases/logout_use_case.dart';
import '../features/auth/application/use_cases/seed_default_user_use_case.dart';
import '../features/auth/domain/ports/password_hasher.dart';
import '../features/auth/domain/ports/session_repository.dart';
import '../features/auth/domain/ports/user_repository.dart';
import '../features/auth/infrastructure/sha256_password_hasher.dart';
import '../features/auth/infrastructure/sqlite_session_repository.dart';
import '../features/auth/infrastructure/sqlite_user_repository.dart';
import '../features/tasks/application/use_cases/create_task_use_case.dart';
import '../features/tasks/application/use_cases/delete_task_use_case.dart';
import '../features/tasks/application/use_cases/get_task_use_case.dart';
import '../features/tasks/application/use_cases/list_tasks_use_case.dart';
import '../features/tasks/application/use_cases/toggle_task_status_use_case.dart';
import '../features/tasks/application/use_cases/update_task_use_case.dart';
import '../features/tasks/domain/ports/task_repository.dart';
import '../features/tasks/infrastructure/sqlite_task_repository.dart';

/// Raíz de composición: el único lugar donde se eligen los adaptadores
/// concretos (SQLite, SHA-256...) y se conectan con los casos de uso.
///
/// El resto de la app solo conoce los casos de uso. En los tests se crea con
/// repositorios en memoria en lugar de SQLite.
class AppDependencies {
  AppDependencies({
    required UserRepository users,
    required SessionRepository sessions,
    required TaskRepository tasks,
    required PasswordHasher hasher,
    Clock clock = const SystemClock(),
  }) : seedDefaultUser = SeedDefaultUserUseCase(users: users, hasher: hasher),
       login = LoginUseCase(
         users: users,
         sessions: sessions,
         hasher: hasher,
         clock: clock,
       ),
       logout = LogoutUseCase(sessions: sessions),
       getCurrentSession = GetCurrentSessionUseCase(
         sessions: sessions,
         clock: clock,
       ),
       listTasks = ListTasksUseCase(tasks: tasks),
       getTask = GetTaskUseCase(tasks: tasks),
       createTask = CreateTaskUseCase(tasks: tasks, clock: clock),
       updateTask = UpdateTaskUseCase(tasks: tasks, clock: clock),
       toggleTaskStatus = ToggleTaskStatusUseCase(tasks: tasks, clock: clock),
       deleteTask = DeleteTaskUseCase(tasks: tasks);

  /// Versión de producción: todo se guarda en SQLite.
  factory AppDependencies.sqlite(Database db) {
    return AppDependencies(
      users: SqliteUserRepository(db),
      sessions: SqliteSessionRepository(db),
      tasks: SqliteTaskRepository(db),
      hasher: Sha256PasswordHasher(),
    );
  }

  // Autenticación
  final SeedDefaultUserUseCase seedDefaultUser;
  final LoginUseCase login;
  final LogoutUseCase logout;
  final GetCurrentSessionUseCase getCurrentSession;

  // Tareas
  final ListTasksUseCase listTasks;
  final GetTaskUseCase getTask;
  final CreateTaskUseCase createTask;
  final UpdateTaskUseCase updateTask;
  final ToggleTaskStatusUseCase toggleTaskStatus;
  final DeleteTaskUseCase deleteTask;
}
