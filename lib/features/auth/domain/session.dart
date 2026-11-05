import 'package:equatable/equatable.dart';

/// Sesión iniciada. Se guarda para no pedir el login cada vez que se abre la app.
class Session extends Equatable {
  const Session({
    required this.userId,
    required this.username,
    required this.startedAt,
    required this.expiresAt,
  });

  /// Cuánto dura una sesión antes de pedir el login otra vez.
  static const duration = Duration(days: 7);

  final int userId;
  final String username;
  final DateTime startedAt;
  final DateTime expiresAt;

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  @override
  List<Object?> get props => [userId, username, startedAt, expiresAt];
}
