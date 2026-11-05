import '../domain/failure.dart';
import '../domain/result.dart';

/// Ejecuta [body] y convierte cualquier excepción inesperada (por ejemplo, un
/// error de SQLite) en un [Err] con [UnexpectedFailure].
///
/// Los casos de uso lo usan para que la interfaz nunca reciba una excepción.
Future<Result<T>> guard<T>(Future<Result<T>> Function() body) async {
  try {
    return await body();
  } on Object catch (error) {
    return Err(UnexpectedFailure(error.toString()));
  }
}
