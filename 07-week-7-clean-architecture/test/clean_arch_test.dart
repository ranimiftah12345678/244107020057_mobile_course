import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:week7_clean/core/failures.dart';
import 'package:week7_clean/features/notes/domain/entities/note.dart';
import 'package:week7_clean/features/notes/domain/repositories/note_repository.dart';
import 'package:week7_clean/features/notes/domain/usecases/note_usecases.dart';
import 'package:week7_clean/features/notes/data/models/note_model.dart';
import 'package:week7_clean/features/notes/data/repositories/note_repository_impl.dart';

// ---------------------------------------------------------------------------
// In-memory repository helper
// ---------------------------------------------------------------------------

Future<NoteRepositoryImpl> buildRepo() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final repo = NoteRepositoryImpl(
    openDb: () => openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE notes (
          id         INTEGER PRIMARY KEY AUTOINCREMENT,
          title      TEXT    NOT NULL DEFAULT '',
          body       TEXT    NOT NULL DEFAULT '',
          dirty      INTEGER NOT NULL DEFAULT 1,
          updated_at TEXT    NOT NULL
        )
      '''),
    ),
  );
  return repo;
}

// ---------------------------------------------------------------------------
// Fake repository untuk use case tests
// ---------------------------------------------------------------------------

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});
  final List<Note> items;
  final bool fail;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('db locked (simulasi)')
      );
    }
    return (notes: items, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    return (
      note: Note(title: title, body: body, updatedAt: DateTime.now()),
      failure: null,
    );
  }

  @override
  Future<({Note? note, Failure? failure})> updateNote(Note note) async =>
      (note: note, failure: null);

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async =>
      (success: true, failure: null);

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    if (fail) return (count: 0, failure: const LocalFailure('db locked (simulasi)'));
    return (count: items.where((n) => n.dirty).length, failure: null);
  }

  @override
  Future<({bool success, Failure? failure})> markAllSynced() async =>
      (success: true, failure: null);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // --- NoteModel ---
  group('NoteModel', () {
    test('fromMap → toEntity round-trip', () {
      final model = NoteModel.fromMap({
        'id': 1,
        'title': 'Judul',
        'body': 'Isi',
        'dirty': 1,
        'updated_at': '2026-09-27T10:00:00.000',
      });
      final entity = model.toEntity();
      expect(entity.id, 1);
      expect(entity.title, 'Judul');
      expect(entity.dirty, true);
    });

    test('fromMap field null → default', () {
      final model = NoteModel.fromMap(
          {'id': null, 'title': null, 'body': null, 'dirty': null, 'updated_at': null});
      expect(model.title, '');
      expect(model.dirty, false);
    });

    test('fromEntity → toMap roundtrip', () {
      final note = Note(
        id: 5,
        title: 'Test',
        body: 'Body',
        updatedAt: DateTime(2026, 9, 27),
        dirty: false,
      );
      final model = NoteModel.fromEntity(note);
      expect(model.toMap()['title'], 'Test');
      expect(model.toMap()['dirty'], 0);
    });
  });

  // --- GetNotes use case ---
  group('GetNotes use case', () {
    test('meneruskan daftar dari repository', () async {
      final repo = FakeNoteRepository(items: [
        Note(title: 'A', updatedAt: DateTime(2026, 9, 27)),
      ]);
      final result = await GetNotes(repo).call();
      expect(result.failure, isNull);
      expect(result.notes.length, 1);
      expect(result.notes.first.title, 'A');
    });

    test('meneruskan failure tanpa melempar', () async {
      final repo = FakeNoteRepository(fail: true);
      final result = await GetNotes(repo).call();
      expect(result.failure, isA<LocalFailure>());
      expect(result.notes, isEmpty);
    });
  });

  // --- NoteRepositoryImpl (in-memory SQLite) ---
  group('NoteRepositoryImpl (in-memory)', () {
    late NoteRepositoryImpl repo;

    setUp(() async {
      repo = await buildRepo();
    });

    tearDown(() => repo.close());

    test('fetchNotes kosong awalnya', () async {
      final result = await repo.fetchNotes();
      expect(result.failure, isNull);
      expect(result.notes, isEmpty);
    });

    test('addNote → tersimpan dengan dirty=true', () async {
      final result = await repo.addNote(title: 'Halo', body: 'Dunia');
      expect(result.failure, isNull);
      expect(result.note?.title, 'Halo');
      expect(result.note?.dirty, true);
    });

    test('fetchNotes setelah add → 1 catatan', () async {
      await repo.addNote(title: 'Satu', body: '');
      final result = await repo.fetchNotes();
      expect(result.notes.length, 1);
    });

    test('deleteNote → catatan terhapus', () async {
      final added = await repo.addNote(title: 'Hapus', body: '');
      await repo.deleteNote(added.note!.id!);
      final result = await repo.fetchNotes();
      expect(result.notes, isEmpty);
    });

    test('countDirty → jumlah benar sebelum sync', () async {
      await repo.addNote(title: 'A', body: '');
      await repo.addNote(title: 'B', body: '');
      final result = await repo.countDirty();
      expect(result.count, 2);
    });

    test('markAllSynced → dirty = 0', () async {
      await repo.addNote(title: 'A', body: '');
      await repo.markAllSynced();
      final count = await repo.countDirty();
      expect(count.count, 0);
    });
  });

  // --- SyncNotes use case ---
  group('SyncNotes use case', () {
    test('sync berhasil → returns jumlah yang disync', () async {
      final repo = FakeNoteRepository(items: [
        Note(title: 'A', updatedAt: DateTime(2026, 9, 27), dirty: true),
        Note(title: 'B', updatedAt: DateTime(2026, 9, 27), dirty: true),
      ]);
      final result = await SyncNotes(repo).call();
      expect(result.failure, isNull);
      expect(result.synced, 2);
    });

    test('sync saat repository gagal → returns failure', () async {
      final repo = FakeNoteRepository(fail: true);
      final result = await SyncNotes(repo).call();
      expect(result.failure, isA<LocalFailure>());
      expect(result.synced, 0);
    });
  });
}
