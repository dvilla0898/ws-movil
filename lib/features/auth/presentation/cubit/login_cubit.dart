import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../application/use_cases/login_use_case.dart';
import '../../domain/session.dart';

enum LoginStatus { idle, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.idle,
    this.failure,
    this.session,
  });

  final LoginStatus status;
  final Failure? failure;
  final Session? session;

  /// Error de validación de un campo concreto (`username` o `password`).
  ValidationFailure? fieldFailure(String field) {
    final current = failure;
    return current is ValidationFailure && current.field == field
        ? current
        : null;
  }

  @override
  List<Object?> get props => [status, failure, session];
}

/// Cubit del formulario de login. Solo llama al caso de uso y expone el estado.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._login) : super(const LoginState());

  final LoginUseCase _login;

  Future<void> submit({
    required String username,
    required String password,
  }) async {
    if (state.status == LoginStatus.submitting) return;
    emit(const LoginState(status: LoginStatus.submitting));

    final result = await _login(username: username, password: password);
    emit(switch (result) {
      Ok(:final value) => LoginState(
        status: LoginStatus.success,
        session: value,
      ),
      Err(:final failure) => LoginState(
        status: LoginStatus.failure,
        failure: failure,
      ),
    });
  }
}
