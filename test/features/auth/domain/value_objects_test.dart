import 'package:flutter_test/flutter_test.dart';
import 'package:ws_movil/core/domain/failure.dart';
import 'package:ws_movil/core/domain/result.dart';
import 'package:ws_movil/features/auth/domain/value_objects/password.dart';
import 'package:ws_movil/features/auth/domain/value_objects/username.dart';

void main() {
  group('Username', () {
    test('quita los espacios de los extremos', () {
      final result = Username.create('  admin  ');
      expect(result, isA<Ok<Username>>());
      expect((result as Ok<Username>).value.value, 'admin');
    });

    test('es obligatorio', () {
      final result = Username.create('   ');
      expect(
        (result as Err).failure,
        const ValidationFailure('username', ValidationError.required),
      );
    });

    test('exige un mínimo de caracteres', () {
      final result = Username.create('ab');
      expect(
        (result as Err).failure,
        const ValidationFailure(
          'username',
          ValidationError.tooShort,
          limit: Username.minLength,
        ),
      );
    });
  });

  group('Password', () {
    test('acepta una contraseña válida tal cual', () {
      final result = Password.create('admin123');
      expect((result as Ok<Password>).value.value, 'admin123');
    });

    test('es obligatoria', () {
      final result = Password.create('');
      expect(
        (result as Err).failure,
        const ValidationFailure('password', ValidationError.required),
      );
    });

    test('exige un mínimo de caracteres', () {
      expect(Password.create('123').isOk, isFalse);
    });
  });
}
