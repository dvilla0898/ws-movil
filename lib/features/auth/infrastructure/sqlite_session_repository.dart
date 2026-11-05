import 'package:sqflite/sqflite.dart';

import '../domain/ports/session_repository.dart';
import '../domain/session.dart';

/// Adaptador de [SessionRepository] sobre la tabla `sessions` de SQLite.
///
/// La tabla solo admite una fila (id = 1): guardar una sesión reemplaza la
/// anterior.
class SqliteSessionRepository implements SessionRepository {
  const SqliteSessionRepository(this._db);

  final Database _db;

  static const _table = 'sessions';

  @override
  Future<Session?> current() async {
    final rows = await _db.query(_table, where: 'id = 1', limit: 1);
    if (rows.isEmpty) return null;

    final row = rows.first;
    return Session(
      userId: row['user_id']! as int,
      username: row['username']! as String,
      startedAt: DateTime.parse(row['started_at']! as String),
      expiresAt: DateTime.parse(row['expires_at']! as String),
    );
  }

  @override
  Future<void> save(Session session) async {
    await _db.insert(_table, {
      'id': 1,
      'user_id': session.userId,
      'username': session.username,
      'started_at': session.startedAt.toIso8601String(),
      'expires_at': session.expiresAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> clear() async {
    await _db.delete(_table);
  }
}
