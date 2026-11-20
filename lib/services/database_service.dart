import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  Future<Database>? _opening;

  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    // No navegador, o SQLite roda em WebAssembly e persiste no IndexedDB.
    // Em Android/iOS/macOS, continuamos usando o plugin sqflite nativo.
    final factory = kIsWeb ? databaseFactoryFfiWeb : databaseFactory;
    final dbPath = kIsWeb
        ? 'organizaja.db'
        : p.join(await getDatabasesPath(), 'organizaja.db');
    return factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
          await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            responsible TEXT NOT NULL DEFAULT '',
            completed INTEGER NOT NULL DEFAULT 0,
            priority INTEGER NOT NULL DEFAULT 2,
            due_date TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
          await db.execute(
            'CREATE INDEX idx_tasks_user ON tasks(user_id, completed, due_date)',
          );
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // Algumas instalações da v1 já criaram a coluna, mas outras não.
            // Consultamos o esquema para evitar erro de coluna duplicada.
            final columns = await db.rawQuery('PRAGMA table_info(tasks)');
            final hasResponsible = columns.any(
              (column) => column['name'] == 'responsible',
            );
            if (!hasResponsible) {
              await db.execute(
                "ALTER TABLE tasks ADD COLUMN responsible TEXT NOT NULL DEFAULT ''",
              );
            }
          }
        },
      ),
    );
  }
}
