import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:week5_local/data/local/note.dart';
import 'package:week5_local/data/providers.dart';
import 'package:week5_local/data/repositories/note_repository.dart';

// ---------------------------------------------------------------------------
// In-memory database helper untuk test
// ---------------------------------------------------------------------------

Future<NoteRepository> buildInMemoryRepo() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final repo = NoteRepository(() => openDatabase(
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
      ));
  return repo;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // --- Unit test: Note.fromMap ---
  group('Note.fromMap', () {
    test('semua field hadir', () {
      final note = Note.fromMap({
        'id': 1,
        'title': 'Judul',
        'body': 'Isi',
        'dirty': 1,
        'updated_at': '2026-01-01T10:00:00.000',
      });
      expect(note.id, 1);
      expect(note.title, 'Judul');
      expect(note.body, 'Isi');
      expect(note.dirty, true);
    });

    test('dirty = 0 → false', () {
      final note = Note.fromMap({
        'id': 2,
        'title': 'A',
        'body': 'B',
        'dirty': 0,
        'updated_at': '2026-01-01T10:00:00.000',
      });
      expect(note.dirty, false);
    });

    test('field hilang → nilai default', () {
      final note = Note.fromMap({'id': 3, 'updated_at': '2026-01-01T10:00:00.000'});
      expect(note.title, '');
      expect(note.body, '');
      expect(note.dirty, true);
    });

    test('field null → nilai default', () {
      final note = Note.fromMap({
        'id': null,
        'title': null,
        'body': null,
        'dirty': null,
        'updated_at': null,
      });
      expect(note.title, '');
      expect(note.dirty, true);
    });

    test('toMap → fromMap round-trip', () {
      final original = Note(
        id: 5,
        title: 'Test',
        body: 'Body',
        dirty: false,
        updatedAt: DateTime(2026, 6, 1),
      );
      final roundTrip = Note.fromMap(original.toMap());
      expect(roundTrip.id, 5);
      expect(roundTrip.title, 'Test');
      expect(roundTrip.dirty, false);
    });
  });

  // --- Unit test: NoteRepository dengan in-memory SQLite ---
  group('NoteRepository (in-memory)', () {
    late NoteRepository repo;

    setUp(() async {
      repo = await buildInMemoryRepo();
    });

    tearDown(() async {
      await repo.close();
    });

    test('fetchAll → kosong awalnya', () async {
      final notes = await repo.fetchAll();
      expect(notes, isEmpty);
    });

    test('insert → fetchAll mengembalikan 1 catatan', () async {
      await repo.insert(Note(title: 'Halo', body: 'Dunia'));
      final notes = await repo.fetchAll();
      expect(notes.length, 1);
      expect(notes.first.title, 'Halo');
    });

    test('catatan baru dirty = true', () async {
      await repo.insert(Note(title: 'Dirty', body: ''));
      final notes = await repo.fetchAll();
      expect(notes.first.dirty, true);
    });

    test('markAllSynced → dirty = false', () async {
      await repo.insert(Note(title: 'A', body: ''));
      await repo.insert(Note(title: 'B', body: ''));
      await repo.markAllSynced();
      final notes = await repo.fetchAll();
      expect(notes.every((n) => !n.dirty), true);
    });

    test('countDirty → jumlah benar', () async {
      await repo.insert(Note(title: 'A', body: ''));
      await repo.insert(Note(title: 'B', body: ''));
      expect(await repo.countDirty(), 2);
      await repo.markAllSynced();
      expect(await repo.countDirty(), 0);
    });

    test('delete → catatan terhapus', () async {
      final inserted = await repo.insert(Note(title: 'Del', body: ''));
      await repo.delete(inserted.id!);
      expect(await repo.fetchAll(), isEmpty);
    });

    test('update → perubahan tersimpan', () async {
      final note = await repo.insert(Note(title: 'Lama', body: ''));
      final updated = note.copyWith(title: 'Baru', dirty: false);
      await repo.update(updated);
      final fetched = await repo.fetchById(note.id!);
      expect(fetched?.title, 'Baru');
      expect(fetched?.dirty, false);
    });

    test('fetchById unknown id → null', () async {
      final note = await repo.fetchById(9999);
      expect(note, isNull);
    });
  });

  // --- Unit test: NoteListNotifier via ProviderContainer ---
  group('NoteListNotifier', () {
    late NoteRepository repo;

    setUp(() async {
      repo = await buildInMemoryRepo();
    });

    tearDown(() => repo.close());

    test('add lalu list bertambah', () async {
      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(noteListProvider.future);
      await container.read(noteListProvider.notifier).add('Judul Baru', 'Isi');
      final notes = await container.read(noteListProvider.future);
      expect(notes.length, 1);
      expect(notes.first.title, 'Judul Baru');
      expect(notes.first.dirty, true);
    });

    test('delete lalu list berkurang', () async {
      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(noteListProvider.notifier).add('Hapus ini', '');
      final notes = await container.read(noteListProvider.future);
      await container.read(noteListProvider.notifier).delete(notes.first.id!);
      final after = await container.read(noteListProvider.future);
      expect(after, isEmpty);
    });
  });
}
