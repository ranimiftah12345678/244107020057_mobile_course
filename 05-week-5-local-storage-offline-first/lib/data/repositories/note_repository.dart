import 'package:sqflite/sqflite.dart';

import '../local/note.dart';

typedef DbOpener = Future<Database> Function();

class NoteRepository {
  NoteRepository(this._openDb);

  final DbOpener _openDb;
  Database? _db;

  Future<Database> get _database async {
    _db ??= await _openDb();
    return _db!;
  }

  Future<List<Note>> fetchAll() async {
    final db = await _database;
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note?> fetchById(int id) async {
    final db = await _database;
    final rows = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Note.fromMap(rows.first);
  }

  Future<Note> insert(Note note) async {
    final db = await _database;
    final id = await db.insert('notes', note.toMap());
    return note.copyWith(id: id);
  }

  Future<void> update(Note note) async {
    final db = await _database;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countDirty() async {
    final db = await _database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as c FROM notes WHERE dirty = 1');
    return (result.first['c'] as int?) ?? 0;
  }

  Future<void> markAllSynced() async {
    final db = await _database;
    await db.update('notes', {'dirty': 0});
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
