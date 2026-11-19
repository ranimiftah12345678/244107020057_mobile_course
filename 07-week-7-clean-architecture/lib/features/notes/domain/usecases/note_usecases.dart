import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNotes {
  const GetNotes(this._repository);
  final NoteRepository _repository;

  Future<({List<Note> notes, Failure? failure})> call() {
    return _repository.fetchNotes();
  }
}

class AddNote {
  const AddNote(this._repository);
  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call({
    required String title,
    String body = '',
  }) {
    if (title.trim().isEmpty) {
      return Future.value((
        note: null,
        failure: const ValidationFailure('Judul tidak boleh kosong'),
      ));
    }
    return _repository.addNote(title: title, body: body);
  }
}

class DeleteNote {
  const DeleteNote(this._repository);
  final NoteRepository _repository;

  Future<({bool success, Failure? failure})> call(int id) {
    return _repository.deleteNote(id);
  }
}

class SyncNotes {
  const SyncNotes(this._repository);
  final NoteRepository _repository;

  Future<({int synced, Failure? failure})> call() async {
    final countResult = await _repository.countDirty();
    if (countResult.failure != null) {
      return (synced: 0, failure: countResult.failure);
    }
    final count = countResult.count;
    // Simulasi upload ke server
    await Future.delayed(const Duration(seconds: 1));
    final syncResult = await _repository.markAllSynced();
    if (syncResult.failure != null) {
      return (synced: 0, failure: syncResult.failure);
    }
    return (synced: count, failure: null);
  }
}
