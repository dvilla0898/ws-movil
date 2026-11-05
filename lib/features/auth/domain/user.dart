import 'package:equatable/equatable.dart';

/// Usuario registrado. Nunca guarda la contraseña, solo su hash y la sal.
class User extends Equatable {
  const User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.salt,
  });

  final int id;
  final String username;
  final String passwordHash;
  final String salt;

  @override
  List<Object?> get props => [id, username, passwordHash, salt];
}
