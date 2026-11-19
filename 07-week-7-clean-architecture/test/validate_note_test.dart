import 'package:flutter_test/flutter_test.dart';

import 'package:week7_clean/core/failures.dart';
import 'package:week7_clean/features/notes/domain/entities/note.dart';
import 'package:week7_clean/features/notes/domain/repositories/note_repository.dart';
import 'package:week7_clean/features/notes/domain/usecases/note_usecases.dart';

class _FakeRepo implements NoteRepository {
  bool called = false;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async =>
      (notes: const <Note>[], failure: null);

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    called = true;
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
  Future<({int count, Failure? failure})> countDirty() async =>
      (count: 0, failure: null);

  @override
  Future<({bool success, Failure? failure})> markAllSynced() async =>
      (success: true, failure: null);
}

void main() {
  group('AddNote title validation', () {
    test(
      'empty title returns ValidationFailure without calling repository',
      () async {
        final repo = _FakeRepo();
        final result = await AddNote(repo).call(title: '');

        expect(result.note, isNull);
        expect(result.failure, isA<ValidationFailure>());
        expect(repo.called, isFalse);
      },
    );

    test('whitespace-only title returns ValidationFailure', () async {
      final result = await AddNote(_FakeRepo()).call(title: '   ');

      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure!.message, 'Judul tidak boleh kosong');
    });

    test('valid title is passed to repository', () async {
      final repo = _FakeRepo();
      final result = await AddNote(repo).call(title: 'Catatan valid');

      expect(result.failure, isNull);
      expect(result.note, isNotNull);
      expect(repo.called, isTrue);
    });
  });
}
