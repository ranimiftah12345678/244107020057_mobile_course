import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({required this._openDb});

  final Future<Database> Function() _openDb;
  Database? _db;

  Future<Database> get _database async {
    _db ??= await _openDb();
    return _db!;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final db = await _database;
      final rows = await db.query('notes', orderBy: 'updated_at DESC');
      final notes = rows
          .map((r) => NoteModel.fromMap(r).toEntity())
          .toList();
      return (notes: notes, failure: null);
    } catch (e) {
      return (
        notes: const <Note>[],
        failure: LocalFailure('Gagal membaca catatan: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    try {
      final db = await _database;
      final now = DateTime.now();
      final model = NoteModel(
        title: title,
        body: body,
        updatedAt: now,
        dirty: true,
      );
      final id = await db.insert('notes', model.toMap());
      return (
        note: Note(
          id: id,
          title: title,
          body: body,
          updatedAt: now,
          dirty: true,
        ),
        failure: null,
      );
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal menyimpan: $e'));
    }
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) async {
    try {
      final db = await _database;
      final model = NoteModel.fromEntity(
        note.copyWith(dirty: true, updatedAt: DateTime.now()),
      );
      await db.update(
        'notes',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      return (note: model.toEntity(), failure: null);
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal mengupdate: $e'));
    }
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    try {
      final db = await _database;
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      return (success: true, failure: null);
    } catch (e) {
      return (success: false, failure: LocalFailure('Gagal menghapus: $e'));
    }
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    try {
      final db = await _database;
      final result = await db
          .rawQuery('SELECT COUNT(*) as c FROM notes WHERE dirty = 1');
      final count = (result.first['c'] as int?) ?? 0;
      return (count: count, failure: null);
    } catch (e) {
      return (count: 0, failure: LocalFailure('Gagal menghitung: $e'));
    }
  }

  @override
  Future<({bool success, Failure? failure})> markAllSynced() async {
    try {
      final db = await _database;
      await db.update('notes', {'dirty': 0});
      return (success: true, failure: null);
    } catch (e) {
      return (success: false, failure: LocalFailure('Gagal sync: $e'));
    }
  }
}
