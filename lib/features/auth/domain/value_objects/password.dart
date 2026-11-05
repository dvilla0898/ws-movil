import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';

/// Contraseña válida (en texto plano, solo vive en memoria mientras se usa).
final class Password {
  const Password._(this.value);

  static const minLength = 6;
  static const maxLength = 64;

  final String value;

  static Result<Password> create(String raw) {
    if (raw.isEmpty) {
      return const Err(ValidationFailure('password', ValidationError.required));
    }
    if (raw.length < minLength) {
      return const Err(
        ValidationFailure(
          'password',
          ValidationError.tooShort,
          limit: minLength,
        ),
      );
    }
    if (raw.length > maxLength) {
      return const Err(
        ValidationFailure(
          'password',
          ValidationError.tooLong,
          limit: maxLength,
        ),
      );
    }
    return Ok(Password._(raw));
  }
}
