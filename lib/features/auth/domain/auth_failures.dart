import '../../../core/domain/failure.dart';

/// Usuario o contraseña incorrectos.
///
/// Es el mismo fallo en los dos casos a propósito: así no se revela si un
/// nombre de usuario existe.
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure();
}
