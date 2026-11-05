import '../../../../core/application/guard.dart';
import '../../../../core/domain/clock.dart';
import '../../../../core/domain/result.dart';
import '../../domain/auth_failures.dart';
import '../../domain/ports/password_hasher.dart';
import '../../domain/ports/session_repository.dart';
import '../../domain/ports/user_repository.dart';
import '../../domain/session.dart';
import '../../domain/value_objects/password.dart';
import '../../domain/value_objects/username.dart';

/// Caso de uso: iniciar sesión.
///
/// 1. Valida el formato del usuario y la contraseña.
/// 2. Busca el usuario y comprueba la contraseña contra su hash.
/// 3. Guarda la sesión para recordarla al reabrir la app.
class LoginUseCase {
  const LoginUseCase({
    required UserRepository users,
    required SessionRepository sessions,
    required PasswordHasher hasher,
    required Clock clock,
  }) : _users = users,
       _sessions = sessions,
       _hasher = hasher,
       _clock = clock;

  final UserRepository _users;
  final SessionRepository _sessions;
  final PasswordHasher _hasher;
  final Clock _clock;

  Future<Result<Session>> call({
    required String username,
    required String password,
  }) {
    return guard(() async {
      final Username validUsername;
      switch (Username.create(username)) {
        case Err(:final failure):
          return Err(failure);
        case Ok(:final value):
          validUsername = value;
      }

      final Password validPassword;
      switch (Password.create(password)) {
        case Err(:final failure):
          return Err(failure);
        case Ok(:final value):
          validPassword = value;
      }

      final user = await _users.findByUsername(validUsername.value);
      if (user == null ||
          !_hasher.verify(
            validPassword.value,
            salt: user.salt,
            hash: user.passwordHash,
          )) {
        return const Err(InvalidCredentialsFailure());
      }

      final now = _clock.now();
      final session = Session(
        userId: user.id,
        username: user.username,
        startedAt: now,
        expiresAt: now.add(Session.duration),
      );
      await _sessions.save(session);
      return Ok(session);
    });
  }
}
