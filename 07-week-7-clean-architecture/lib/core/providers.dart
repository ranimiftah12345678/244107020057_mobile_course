import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/notes/data/datasources/local_db.dart';
import '../features/notes/data/repositories/note_repository_impl.dart';
import '../features/notes/domain/entities/note.dart';
import '../features/notes/domain/repositories/note_repository.dart';
import '../features/notes/domain/usecases/note_usecases.dart';

// ---------------------------------------------------------------------------
// Repository + use case providers
// ---------------------------------------------------------------------------

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final addNoteProvider = Provider<AddNote>((ref) {
  return AddNote(ref.watch(noteRepositoryProvider));
});

final deleteNoteProvider = Provider<DeleteNote>((ref) {
  return DeleteNote(ref.watch(noteRepositoryProvider));
});

final syncNotesProvider = Provider<SyncNotes>((ref) {
  return SyncNotes(ref.watch(noteRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Notes list notifier
// ---------------------------------------------------------------------------

class NoteListNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final result = await ref.watch(getNotesProvider).call();
    if (result.failure != null) throw Exception(result.failure!.message);
    return result.notes;
  }

  Future<void> add(String title, String body) async {
    await ref.read(addNoteProvider).call(title: title, body: body);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(deleteNoteProvider).call(id);
    ref.invalidateSelf();
  }
}

final noteListProvider =
    AsyncNotifierProvider<NoteListNotifier, List<Note>>(NoteListNotifier.new);

// ---------------------------------------------------------------------------
// Dirty count provider
// ---------------------------------------------------------------------------

final dirtyCountProvider = FutureProvider<int>((ref) async {
  ref.watch(noteListProvider);
  final result =
      await ref.read(noteRepositoryProvider).countDirty();
  return result.count;
});

// ---------------------------------------------------------------------------
// Sync notifier
// ---------------------------------------------------------------------------

class SyncNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async => 'idle';

  Future<void> sync() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(syncNotesProvider).call();
      if (result.failure != null) throw Exception(result.failure!.message);
      ref.invalidate(noteListProvider);
      return 'Berhasil sync ${result.synced} catatan';
    });
  }
}

final syncProvider =
    AsyncNotifierProvider<SyncNotifier, String>(SyncNotifier.new);
