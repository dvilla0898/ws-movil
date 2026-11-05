import '../../../../core/application/guard.dart';
import '../../../../core/domain/result.dart';
import '../../domain/ports/password_hasher.dart';
import '../../domain/ports/user_repository.dart';

/// Caso de uso: crear el usuario de prueba la primera vez que se abre la app.
///
/// Solo actúa si no existe ningún usuario. Credenciales: `admin` / `admin123`.
class SeedDefaultUserUseCase {
  const SeedDefaultUserUseCase({
    required UserRepository users,
    required PasswordHasher hasher,
  }) : _users = users,
       _hasher = hasher;

  static const defaultUsername = 'admin';
  static const defaultPassword = 'admin123';

  final UserRepository _users;
  final PasswordHasher _hasher;

  /// Devuelve `true` si ha creado el usuario.
  Future<Result<bool>> call() {
    return guard(() async {
      if (await _users.count() > 0) return const Ok(false);

      final salt = _hasher.generateSalt();
      await _users.create(
        username: defaultUsername,
        passwordHash: _hasher.hash(defaultPassword, salt),
        salt: salt,
      );
      return const Ok(true);
    });
  }
}
