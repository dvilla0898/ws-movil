import 'package:flutter_test/flutter_test.dart';
import 'package:ws_movil/core/domain/failure.dart';
import 'package:ws_movil/core/domain/result.dart';
import 'package:ws_movil/features/auth/application/use_cases/get_current_session_use_case.dart';
import 'package:ws_movil/features/auth/application/use_cases/login_use_case.dart';
import 'package:ws_movil/features/auth/application/use_cases/logout_use_case.dart';
import 'package:ws_movil/features/auth/application/use_cases/seed_default_user_use_case.dart';
import 'package:ws_movil/features/auth/domain/auth_failures.dart';
import 'package:ws_movil/features/auth/domain/session.dart';
import 'package:ws_movil/features/auth/infrastructure/sha256_password_hasher.dart';

import '../../../helpers/fakes.dart';

void main() {
  late InMemoryUserRepository users;
  late InMemorySessionRepository sessions;
  late FixedClock clock;
  late Sha256PasswordHasher hasher;
  late LoginUseCase login;

  setUp(() async {
    users = InMemoryUserRepository();
    sessions = InMemorySessionRepository();
    clock = FixedClock(DateTime(2026, 11, 4, 10));
    hasher = Sha256PasswordHasher();
    login = LoginUseCase(
      users: users,
      sessions: sessions,
      hasher: hasher,
      clock: clock,
    );
    await SeedDefaultUserUseCase(users: users, hasher: hasher)();
  });

  group('SeedDefaultUserUseCase', () {
    test('crea admin una sola vez y sin guardar la contraseña', () async {
      final again = await SeedDefaultUserUseCase(users: users, hasher: hasher)();

      expect((again as Ok<bool>).value, isFalse);
      expect(users.users, hasLength(1));
      expect(users.users.single.username, 'admin');
      expect(users.users.single.passwordHash, isNot(contains('admin123')));
    });
  });

  group('LoginUseCase', () {
    test('con admin / admin123 inicia sesión y la guarda', () async {
      final result = await login(username: 'admin', password: 'admin123');

      final session = (result as Ok<Session>).value;
      expect(session.username, 'admin');
      expect(session.expiresAt, clock.current.add(Session.duration));
      expect(sessions.session, session);
    });

    test('con contraseña incorrecta falla sin guardar sesión', () async {
      final result = await login(username: 'admin', password: 'otra-clave');

      expect((result as Err).failure, const InvalidCredentialsFailure());
      expect(sessions.session, isNull);
    });

    test('con un usuario que no existe da el mismo error', () async {
      final result = await login(username: 'nadie', password: 'admin123');

      expect((result as Err).failure, const InvalidCredentialsFailure());
    });

    test('valida el formato antes de consultar el repositorio', () async {
      final result = await login(username: '', password: 'admin123');

      expect((result as Err).failure, isA<ValidationFailure>());
    });
  });

  group('GetCurrentSessionUseCase y LogoutUseCase', () {
    test('recupera la sesión guardada mientras no caduque', () async {
      await login(username: 'admin', password: 'admin123');
      final getSession = GetCurrentSessionUseCase(
        sessions: sessions,
        clock: clock,
      );

      expect((await getSession() as Ok<Session?>).value, isNotNull);

      clock.current = clock.current.add(Session.duration);
      expect((await getSession() as Ok<Session?>).value, isNull);
      expect(sessions.session, isNull);
    });

    test('logout borra la sesión', () async {
      await login(username: 'admin', password: 'admin123');

      await LogoutUseCase(sessions: sessions)();

      expect(sessions.session, isNull);
    });
  });
}
