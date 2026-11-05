import '../../../../core/application/guard.dart';
import '../../../../core/domain/result.dart';
import '../../domain/ports/session_repository.dart';

/// Caso de uso: cerrar sesión (olvida la sesión guardada).
class LogoutUseCase {
  const LogoutUseCase({required SessionRepository sessions})
    : _sessions = sessions;

  final SessionRepository _sessions;

  Future<Result<void>> call() {
    return guard(() async {
      await _sessions.clear();
      return const Ok(null);
    });
  }
}
