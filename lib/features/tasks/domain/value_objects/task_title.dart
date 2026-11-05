import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';

/// Título de una tarea: obligatorio, entre [minLength] y [maxLength] caracteres.
final class TaskTitle {
  const TaskTitle._(this.value);

  static const minLength = 3;
  static const maxLength = 80;

  final String value;

  static Result<TaskTitle> create(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return const Err(ValidationFailure('title', ValidationError.required));
    }
    if (value.length < minLength) {
      return const Err(
        ValidationFailure('title', ValidationError.tooShort, limit: minLength),
      );
    }
    if (value.length > maxLength) {
      return const Err(
        ValidationFailure('title', ValidationError.tooLong, limit: maxLength),
      );
    }
    return Ok(TaskTitle._(value));
  }
}
