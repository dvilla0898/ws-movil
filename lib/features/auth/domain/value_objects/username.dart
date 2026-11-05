import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';

/// Nombre de usuario válido. Solo se puede crear con [Username.create], así que
/// si tienes un [Username] sabes que cumple las reglas.
final class Username {
  const Username._(this.value);

  static const minLength = 3;
  static const maxLength = 30;

  final String value;

  static Result<Username> create(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return const Err(ValidationFailure('username', ValidationError.required));
    }
    if (value.length < minLength) {
      return const Err(
        ValidationFailure(
          'username',
          ValidationError.tooShort,
          limit: minLength,
        ),
      );
    }
    if (value.length > maxLength) {
      return const Err(
        ValidationFailure(
          'username',
          ValidationError.tooLong,
          limit: maxLength,
        ),
      );
    }
    return Ok(Username._(value));
  }
}
