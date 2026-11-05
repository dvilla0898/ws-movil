import 'package:flutter_test/flutter_test.dart';
import 'package:ws_movil/features/auth/infrastructure/sha256_password_hasher.dart';

void main() {
  final hasher = Sha256PasswordHasher();

  test('cada sal es distinta', () {
    expect(hasher.generateSalt(), isNot(hasher.generateSalt()));
  });

  test('la misma contraseña con distinta sal da hashes distintos', () {
    expect(
      hasher.hash('admin123', 'sal-1'),
      isNot(hasher.hash('admin123', 'sal-2')),
    );
  });

  test('verify acepta la contraseña correcta y rechaza otra', () {
    final salt = hasher.generateSalt();
    final hash = hasher.hash('admin123', salt);

    expect(hasher.verify('admin123', salt: salt, hash: hash), isTrue);
    expect(hasher.verify('admin124', salt: salt, hash: hash), isFalse);
  });
}
