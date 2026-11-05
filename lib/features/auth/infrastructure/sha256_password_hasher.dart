import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../domain/ports/password_hasher.dart';

/// Adaptador de [PasswordHasher] con SHA-256 y sal aleatoria.
///
/// Suficiente para aprender. En una app real el login lo valida un servidor
/// con un algoritmo lento pensado para contraseñas (bcrypt, Argon2...).
class Sha256PasswordHasher implements PasswordHasher {
  Sha256PasswordHasher({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  @override
  String generateSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Url.encode(bytes);
  }

  @override
  String hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  @override
  bool verify(String password, {required String salt, required String hash}) {
    final candidate = this.hash(password, salt);
    if (candidate.length != hash.length) return false;

    // Compara todos los caracteres aunque encuentre una diferencia, para que el
    // tiempo de respuesta no dé pistas sobre el hash.
    var difference = 0;
    for (var i = 0; i < hash.length; i++) {
      difference |= candidate.codeUnitAt(i) ^ hash.codeUnitAt(i);
    }
    return difference == 0;
  }
}
