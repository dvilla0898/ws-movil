import 'package:sqflite/sqflite.dart';

import '../domain/ports/user_repository.dart';
import '../domain/user.dart';

/// Adaptador de [UserRepository] sobre la tabla `users` de SQLite.
class SqliteUserRepository implements UserRepository {
  const SqliteUserRepository(this._db);

  final Database _db;

  static const _table = 'users';

  @override
  Future<User?> findByUsername(String username) async {
    final rows = await _db.query(
      _table,
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return rows.isEmpty ? null : _toUser(rows.first);
  }

  @override
  Future<int> count() async {
    final rows = await _db.rawQuery('SELECT COUNT(*) AS total FROM $_table');
    return rows.first['total']! as int;
  }

  @override
  Future<User> create({
    required String username,
    required String passwordHash,
    required String salt,
  }) async {
    final id = await _db.insert(_table, {
      'username': username,
      'password_hash': passwordHash,
      'salt': salt,
    });
    return User(
      id: id,
      username: username,
      passwordHash: passwordHash,
      salt: salt,
    );
  }

  User _toUser(Map<String, Object?> row) {
    return User(
      id: row['id']! as int,
      username: row['username']! as String,
      passwordHash: row['password_hash']! as String,
      salt: row['salt']! as String,
    );
  }
}
