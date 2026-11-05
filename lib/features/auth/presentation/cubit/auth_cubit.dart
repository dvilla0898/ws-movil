import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/result.dart';
import '../../application/use_cases/get_current_session_use_case.dart';
import '../../application/use_cases/logout_use_case.dart';
import '../../domain/session.dart';

/// Estado global de autenticación: decide qué pantalla ve el usuario.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Comprobando si hay una sesión guardada (al abrir la app).
final class AuthChecking extends AuthState {
  const AuthChecking();
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);

  final Session session;

  @override
  List<Object?> get props => [session];
}

/// Cubit de la sesión. Vive durante toda la app.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required GetCurrentSessionUseCase getCurrentSession,
    required LogoutUseCase logout,
  }) : _getCurrentSession = getCurrentSession,
       _logout = logout,
       super(const AuthChecking());

  final GetCurrentSessionUseCase _getCurrentSession;
  final LogoutUseCase _logout;

  Future<void> checkSession() async {
    final result = await _getCurrentSession();
    emit(switch (result) {
      Ok(value: final Session session) => AuthAuthenticated(session),
      _ => const AuthUnauthenticated(),
    });
  }

  /// Lo llama la pantalla de login cuando el caso de uso tiene éxito.
  void signedIn(Session session) => emit(AuthAuthenticated(session));

  Future<void> signOut() async {
    await _logout();
    emit(const AuthUnauthenticated());
  }
}
