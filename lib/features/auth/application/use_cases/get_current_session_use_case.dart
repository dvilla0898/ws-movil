import '../../../../core/application/guard.dart';
import '../../../../core/domain/clock.dart';
import '../../../../core/domain/result.dart';
import '../../domain/ports/session_repository.dart';
import '../../domain/session.dart';

/// Caso de uso: recuperar la sesión guardada al abrir la app.
///
/// Devuelve `null` si no hay sesión o si ya caducó (y en ese caso la borra).
class GetCurrentSessionUseCase {
  const GetCurrentSessionUseCase({
    required SessionRepository sessions,
    required Clock clock,
  }) : _sessions = sessions,
       _clock = clock;

  final SessionRepository _sessions;
  final Clock _clock;

  Future<Result<Session?>> call() {
    return guard(() async {
      final session = await _sessions.current();
      if (session == null) return const Ok(null);

      if (session.isExpiredAt(_clock.now())) {
        await _sessions.clear();
        return const Ok(null);
      }
      return Ok(session);
    });
  }
}
