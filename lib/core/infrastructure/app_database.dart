import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Abre (y crea la primera vez) la base de datos SQLite de la app.
///
/// Es infraestructura compartida: los repositorios de cada módulo reciben la
/// [Database] ya abierta. El esquema se versiona con [version]; para cambiarlo
/// en el futuro se sube la versión y se añade la migración en `onUpgrade`.
abstract final class AppDatabase {
  static const fileName = 'ws_movil.db';
  static const version = 1;

  /// [factory] y [path] solo se indican en los tests (SQLite en memoria).
  static Future<Database> open({DatabaseFactory? factory, String? path}) async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await dbFactory.getDatabasesPath(), fileName);

    return dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: version,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _createSchema,
      ),
    );
  }

  static Future<void> _createSchema(Database db, int version) async {
    final batch = db.batch()
      ..execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          salt TEXT NOT NULL
        )
      ''')
      // Solo puede haber una sesión activa (id = 1).
      ..execute('''
        CREATE TABLE sessions (
          id INTEGER PRIMARY KEY CHECK (id = 1),
          user_id INTEGER NOT NULL REFERENCES users (id) ON DELETE CASCADE,
          username TEXT NOT NULL,
          started_at TEXT NOT NULL,
          expires_at TEXT NOT NULL
        )
      ''')
      ..execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL DEFAULT '',
          priority TEXT NOT NULL,
          due_date TEXT,
          is_done INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    await batch.commit(noResult: true);
  }
}
