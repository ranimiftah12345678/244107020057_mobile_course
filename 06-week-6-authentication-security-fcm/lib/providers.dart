import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/auth_repository.dart';
import 'data/announcement.dart';
import 'data/token_store.dart';

// ---------------------------------------------------------------------------
// Repository & store providers
// ---------------------------------------------------------------------------

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

// ---------------------------------------------------------------------------
// Announcements provider
// ---------------------------------------------------------------------------

final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  // Simulasi delay seperti fetch dari API
  await Future.delayed(const Duration(milliseconds: 800));
  return kMockAnnouncements;
});

final announcementDetailProvider =
    FutureProvider.family<Announcement?, String>((ref, id) async {
  final list = await ref.watch(announcementsProvider.future);
  return list.where((a) => a.id == id).firstOrNull;
});

// ---------------------------------------------------------------------------
// Push notification mock state
// ---------------------------------------------------------------------------

class PushNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void simulatePush(String route) {
    state = route;
  }

  void clearRoute() {
    state = null;
  }
}

final pushProvider = NotifierProvider<PushNotifier, String?>(PushNotifier.new);
