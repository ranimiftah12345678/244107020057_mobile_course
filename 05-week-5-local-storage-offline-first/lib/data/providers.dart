import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/db.dart';
import 'local/note.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';

// ---------------------------------------------------------------------------
// Repository providers
// ---------------------------------------------------------------------------

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(openNotesDb),
);

final prefsRepositoryProvider = Provider<PrefsRepository>(
  (ref) => PrefsRepository(),
);

// ---------------------------------------------------------------------------
// Notes list provider
// ---------------------------------------------------------------------------

class NoteListNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => _load();

  Future<List<Note>> _load() =>
      ref.read(noteRepositoryProvider).fetchAll();

  Future<void> add(String title, String body) async {
    final repo = ref.read(noteRepositoryProvider);
    final note = Note(title: title, body: body);
    await repo.insert(note);
    ref.invalidateSelf();
  }

  Future<void> updateNote(Note note) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.update(note.copyWith(dirty: true, updatedAt: DateTime.now()));
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.delete(id);
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
  return ref.read(noteRepositoryProvider).countDirty();
});

// ---------------------------------------------------------------------------
// Sync provider (manual trigger)
// ---------------------------------------------------------------------------

class SyncNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async => 'idle';

  Future<void> sync() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(noteRepositoryProvider);
      final dirty = await repo.countDirty();
      // Simulasi upload ke server
      await Future.delayed(const Duration(seconds: 1));
      await repo.markAllSynced();
      ref.invalidate(noteListProvider);
      return 'Berhasil sync $dirty catatan';
    });
  }
}

final syncProvider =
    AsyncNotifierProvider<SyncNotifier, String>(SyncNotifier.new);

// ---------------------------------------------------------------------------
// Dark mode provider
// ---------------------------------------------------------------------------

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.read(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final current = state.value ?? false;
    await ref.read(prefsRepositoryProvider).setDarkMode(!current);
    state = AsyncData(!current);
  }
}

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

// ---------------------------------------------------------------------------
// Last opened provider
// ---------------------------------------------------------------------------

final lastOpenedProvider = FutureProvider<DateTime?>((ref) async {
  final prefs = ref.read(prefsRepositoryProvider);
  await prefs.updateLastOpened();
  return prefs.getLastOpened();
});

// helpers for tests
Future<List<Note>> readNotesOnce(ProviderContainer c) async {
  final sub = c.listen(noteListProvider, (prev, next) {});
  await c.read(noteListProvider.future);
  sub.close();
  return c.read(noteListProvider).value ?? [];
}
