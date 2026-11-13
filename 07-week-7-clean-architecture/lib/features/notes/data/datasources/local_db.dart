import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> openNotesDb() async {
  final dbPath = await getDatabasesPath();
  return openDatabase(
    join(dbPath, 'notes_clean.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes (
          id         INTEGER PRIMARY KEY AUTOINCREMENT,
          title      TEXT    NOT NULL DEFAULT '',
          body       TEXT    NOT NULL DEFAULT '',
          dirty      INTEGER NOT NULL DEFAULT 1,
          updated_at TEXT    NOT NULL
        )
      ''');
    },
  );
}
