import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../core/domain/failure.dart';
import '../../features/auth/domain/auth_failures.dart';
import '../../features/tasks/domain/task_priority.dart';

/// Textos de la interfaz.
///
/// Cada idioma es una clase que implementa todos los getters: si añades un
/// texto aquí y olvidas traducirlo, el código no compila.
///
/// Uso en un widget: `AppStrings.of(context).loginTitle`.
abstract class AppStrings {
  const AppStrings();

  static const supportedLocales = [Locale('es'), Locale('en')];

  static const LocalizationsDelegate<AppStrings> delegate = _AppStringsDelegate();

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  static AppStrings forLocale(Locale locale) {
    return switch (locale.languageCode) {
      'en' => const EnStrings(),
      _ => const EsStrings(),
    };
  }

  // General
  String get appTitle;
  String get language;
  String get save;
  String get cancel;
  String get delete;
  String get retry;

  // Login
  String get loginTitle;
  String get loginHint;
  String get usernameLabel;
  String get passwordLabel;
  String get loginButton;
  String get showPassword;
  String get hidePassword;
  String get logout;

  // Listado
  String greeting(String username);
  String get filterAll;
  String get filterPending;
  String get filterDone;
  String get emptyTasks;
  String get emptyTasksHint;
  String get newTask;
  String get editTask;
  String get taskCreated;
  String get taskUpdated;
  String get taskDeleted;
  String get overdue;
  String dueOn(String date);
  String get markDone;
  String get markPending;

  // Formulario
  String get titleLabel;
  String get descriptionLabel;
  String get priorityLabel;
  String priorityName(TaskPriority priority);
  String get dueDateLabel;
  String get noDueDate;
  String get pickDate;
  String get clearDate;

  // Modal de eliminar
  String get deleteTaskTitle;
  String deleteTaskMessage(String title);

  // Errores
  String fieldName(String field);
  String get invalidCredentials;
  String get taskNotFound;
  String get unexpectedError;
  String requiredField(String field);
  String tooShort(String field, int min);
  String tooLong(String field, int max);

  /// Traduce un fallo del dominio a un mensaje para el usuario.
  String failure(Failure failure) {
    return switch (failure) {
      InvalidCredentialsFailure() => invalidCredentials,
      NotFoundFailure() => taskNotFound,
      ValidationFailure(:final field, error: ValidationError.required) =>
        requiredField(fieldName(field)),
      ValidationFailure(:final field, error: ValidationError.tooShort, :final limit) =>
        tooShort(fieldName(field), limit ?? 0),
      ValidationFailure(:final field, error: ValidationError.tooLong, :final limit) =>
        tooLong(fieldName(field), limit ?? 0),
      _ => unexpectedError,
    };
  }
}

class EsStrings extends AppStrings {
  const EsStrings();

  @override
  String get appTitle => 'Mis tareas';
  @override
  String get language => 'Idioma';
  @override
  String get save => 'Guardar';
  @override
  String get cancel => 'Cancelar';
  @override
  String get delete => 'Eliminar';
  @override
  String get retry => 'Reintentar';

  @override
  String get loginTitle => 'Iniciar sesión';
  @override
  String get loginHint => 'Usuario de prueba: admin / admin123';
  @override
  String get usernameLabel => 'Usuario';
  @override
  String get passwordLabel => 'Contraseña';
  @override
  String get loginButton => 'Entrar';
  @override
  String get showPassword => 'Mostrar contraseña';
  @override
  String get hidePassword => 'Ocultar contraseña';
  @override
  String get logout => 'Cerrar sesión';

  @override
  String greeting(String username) => 'Hola, $username';
  @override
  String get filterAll => 'Todas';
  @override
  String get filterPending => 'Pendientes';
  @override
  String get filterDone => 'Hechas';
  @override
  String get emptyTasks => 'No hay tareas';
  @override
  String get emptyTasksHint => 'Pulsa «Nueva tarea» para crear la primera.';
  @override
  String get newTask => 'Nueva tarea';
  @override
  String get editTask => 'Editar tarea';
  @override
  String get taskCreated => 'Tarea creada';
  @override
  String get taskUpdated => 'Tarea actualizada';
  @override
  String get taskDeleted => 'Tarea eliminada';
  @override
  String get overdue => 'Vencida';
  @override
  String dueOn(String date) => 'Vence: $date';
  @override
  String get markDone => 'Marcar como hecha';
  @override
  String get markPending => 'Marcar como pendiente';

  @override
  String get titleLabel => 'Título';
  @override
  String get descriptionLabel => 'Descripción (opcional)';
  @override
  String get priorityLabel => 'Prioridad';
  @override
  String priorityName(TaskPriority priority) => switch (priority) {
    TaskPriority.low => 'Baja',
    TaskPriority.medium => 'Media',
    TaskPriority.high => 'Alta',
  };
  @override
  String get dueDateLabel => 'Fecha límite';
  @override
  String get noDueDate => 'Sin fecha límite';
  @override
  String get pickDate => 'Elegir fecha';
  @override
  String get clearDate => 'Quitar fecha';

  @override
  String get deleteTaskTitle => '¿Eliminar tarea?';
  @override
  String deleteTaskMessage(String title) =>
      'Se eliminará «$title». Esta acción no se puede deshacer.';

  @override
  String fieldName(String field) => switch (field) {
    'username' => 'El usuario',
    'password' => 'La contraseña',
    'title' => 'El título',
    'description' => 'La descripción',
    _ => 'El campo',
  };
  @override
  String get invalidCredentials => 'Usuario o contraseña incorrectos';
  @override
  String get taskNotFound => 'La tarea ya no existe';
  @override
  String get unexpectedError => 'Ha ocurrido un error inesperado';
  @override
  String requiredField(String field) => '$field es obligatorio';
  @override
  String tooShort(String field, int min) =>
      '$field debe tener al menos $min caracteres';
  @override
  String tooLong(String field, int max) =>
      '$field no puede superar los $max caracteres';
}

class EnStrings extends AppStrings {
  const EnStrings();

  @override
  String get appTitle => 'My tasks';
  @override
  String get language => 'Language';
  @override
  String get save => 'Save';
  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get retry => 'Retry';

  @override
  String get loginTitle => 'Sign in';
  @override
  String get loginHint => 'Test user: admin / admin123';
  @override
  String get usernameLabel => 'Username';
  @override
  String get passwordLabel => 'Password';
  @override
  String get loginButton => 'Sign in';
  @override
  String get showPassword => 'Show password';
  @override
  String get hidePassword => 'Hide password';
  @override
  String get logout => 'Sign out';

  @override
  String greeting(String username) => 'Hi, $username';
  @override
  String get filterAll => 'All';
  @override
  String get filterPending => 'Pending';
  @override
  String get filterDone => 'Done';
  @override
  String get emptyTasks => 'No tasks';
  @override
  String get emptyTasksHint => 'Tap "New task" to create the first one.';
  @override
  String get newTask => 'New task';
  @override
  String get editTask => 'Edit task';
  @override
  String get taskCreated => 'Task created';
  @override
  String get taskUpdated => 'Task updated';
  @override
  String get taskDeleted => 'Task deleted';
  @override
  String get overdue => 'Overdue';
  @override
  String dueOn(String date) => 'Due: $date';
  @override
  String get markDone => 'Mark as done';
  @override
  String get markPending => 'Mark as pending';

  @override
  String get titleLabel => 'Title';
  @override
  String get descriptionLabel => 'Description (optional)';
  @override
  String get priorityLabel => 'Priority';
  @override
  String priorityName(TaskPriority priority) => switch (priority) {
    TaskPriority.low => 'Low',
    TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High',
  };
  @override
  String get dueDateLabel => 'Due date';
  @override
  String get noDueDate => 'No due date';
  @override
  String get pickDate => 'Pick a date';
  @override
  String get clearDate => 'Clear date';

  @override
  String get deleteTaskTitle => 'Delete task?';
  @override
  String deleteTaskMessage(String title) =>
      '"$title" will be deleted. This action cannot be undone.';

  @override
  String fieldName(String field) => switch (field) {
    'username' => 'Username',
    'password' => 'Password',
    'title' => 'Title',
    'description' => 'Description',
    _ => 'This field',
  };
  @override
  String get invalidCredentials => 'Wrong username or password';
  @override
  String get taskNotFound => 'The task no longer exists';
  @override
  String get unexpectedError => 'An unexpected error occurred';
  @override
  String requiredField(String field) => '$field is required';
  @override
  String tooShort(String field, int min) =>
      '$field must be at least $min characters';
  @override
  String tooLong(String field, int max) =>
      '$field cannot exceed $max characters';
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => AppStrings.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppStrings> load(Locale locale) {
    return SynchronousFuture(AppStrings.forLocale(locale));
  }

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
