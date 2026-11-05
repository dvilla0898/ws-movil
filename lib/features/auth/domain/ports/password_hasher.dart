/// Puerto de salida: cómo se transforma una contraseña en un hash.
abstract interface class PasswordHasher {
  /// Valor aleatorio que se mezcla con la contraseña antes de calcular el hash.
  String generateSalt();

  String hash(String password, String salt);

  bool verify(String password, {required String salt, required String hash});
}
