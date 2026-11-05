import 'failure.dart';

/// Resultado de una operación: o un valor ([Ok]) o un fallo ([Err]).
///
/// Así los casos de uso no lanzan excepciones para los errores esperados y quien
/// los llama está obligado a tratar los dos caminos:
///
/// ```dart
/// switch (await login(username, password)) {
///   case Ok(:final value): ...
///   case Err(:final failure): ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
