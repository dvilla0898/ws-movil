import '../session.dart';

/// Puerto de salida: dónde se recuerda la sesión iniciada.
abstract interface class SessionRepository {
  Future<Session?> current();

  Future<void> save(Session session);

  Future<void> clear();
}
