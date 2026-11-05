import '../user.dart';

/// Puerto de salida: dónde se guardan los usuarios.
///
/// El dominio solo conoce esta interfaz; la implementación con SQLite vive en
/// `infrastructure/`. En los tests se usa una versión en memoria.
abstract interface class UserRepository {
  Future<User?> findByUsername(String username);

  Future<int> count();

  Future<User> create({
    required String username,
    required String passwordHash,
    required String salt,
  });
}
