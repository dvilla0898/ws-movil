import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';

/// Descripción de una tarea: opcional, como máximo [maxLength] caracteres.
final class TaskDescription {
  const TaskDescription._(this.value);

  static const maxLength = 500;

  final String value;

  static Result<TaskDescription> create(String raw) {
    final value = raw.trim();
    if (value.length > maxLength) {
      return const Err(
        ValidationFailure(
          'description',
          ValidationError.tooLong,
          limit: maxLength,
        ),
      );
    }
    return Ok(TaskDescription._(value));
  }
}
