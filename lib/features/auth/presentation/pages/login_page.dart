import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependencies.dart';
import '../../../../app/l10n/app_strings.dart';
import '../../../../app/l10n/language_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/login_cubit.dart';

/// Pantalla de inicio de sesión.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(context.read<AppDependencies>().login),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  var _obscurePassword = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<LoginCubit>().submit(
      username: _username.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (previous, current) => current.status == LoginStatus.success,
      listener: (context, state) {
        context.read<AuthCubit>().signedIn(state.session!);
      },
      builder: (context, state) {
        final submitting = state.status == LoginStatus.submitting;
        final usernameError = state.fieldFailure('username');
        final passwordError = state.fieldFailure('password');
        final generalError =
            state.status == LoginStatus.failure &&
                usernameError == null &&
                passwordError == null
            ? strings.failure(state.failure!)
            : null;

        return Scaffold(
          appBar: AppBar(actions: const [LanguageButton()]),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        strings.loginTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.loginHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        key: const Key('login_username'),
                        controller: _username,
                        enabled: !submitting,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: strings.usernameLabel,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: const OutlineInputBorder(),
                          errorText: usernameError == null
                              ? null
                              : strings.failure(usernameError),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('login_password'),
                        controller: _password,
                        enabled: !submitting,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: strings.passwordLabel,
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          errorText: passwordError == null
                              ? null
                              : strings.failure(passwordError),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? strings.showPassword
                                : strings.hidePassword,
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      if (generalError != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          generalError,
                          key: const Key('login_error'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        key: const Key('login_submit'),
                        onPressed: submitting ? null : _submit,
                        child: submitting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(strings.loginButton),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
