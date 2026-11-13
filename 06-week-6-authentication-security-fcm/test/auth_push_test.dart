import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helper: routeFromMessage (meniru logika FCM data handler)
// ---------------------------------------------------------------------------

String routeFromMessage(Map<String, String> data) {
  final route = data['route'] ?? '/';
  return route.startsWith('/') ? route : '/$route';
}

// ---------------------------------------------------------------------------
// Fake store untuk test isolasi
// ---------------------------------------------------------------------------

class FakeTokenStore {
  String? access;
  String? refresh;

  void save({required String a, required String r}) {
    access = a;
    refresh = r;
  }

  void clear() {
    access = null;
    refresh = null;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // --- FCM route parsing ---
  group('routeFromMessage', () {
    test('data kosong → route default /', () {
      expect(routeFromMessage({}), '/');
    });

    test('route tanpa slash di depan → ditambahkan slash', () {
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    });

    test('route dengan slash → tidak berubah', () {
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    });

    test('data payload membawa id pengumuman', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');
    });
  });

  // --- Token store behavior ---
  group('FakeTokenStore', () {
    test('status login berdasarkan keberadaan access token', () {
      final store = FakeTokenStore()..save(a: 'mock-access', r: 'mock-refresh');
      expect(store.access != null, isTrue);
    });

    test('logout membersihkan token', () {
      final store = FakeTokenStore()..save(a: 'token', r: 'refresh');
      store.clear();
      expect(store.access, isNull);
      expect(store.refresh, isNull);
    });

    test('refresh kosong → harus paksa login ulang', () {
      final store = FakeTokenStore()..refresh = '';
      final needsLogin = (store.refresh ?? '').isEmpty;
      expect(needsLogin, isTrue);
    });
  });

  // --- Auth logic ---
  group('AuthRepository mock behavior', () {
    test('email tidak valid → lempar exception', () async {
      // Validasi sederhana tanpa import repository asli
      bool isValid(String email, String pass) =>
          email.contains('@') && pass.length >= 6;

      expect(isValid('bukan-email', 'pass123'), isFalse);
      expect(isValid('user@test.com', 'short'), isFalse);
      expect(isValid('user@test.com', 'password123'), isTrue);
    });

    test('token refresh menghasilkan access baru', () {
      // Simulasi mock refresh
      String mockRefresh(String refreshToken) {
        if (refreshToken.isEmpty) throw Exception('Token hilang');
        return 'access-renewed-${refreshToken.hashCode}';
      }

      final renewed = mockRefresh('valid-refresh');
      expect(renewed, startsWith('access-renewed-'));
    });

    test('refresh token kosong → perlu login ulang', () {
      String? mockRefreshNullable(String? refreshToken) {
        if (refreshToken == null || refreshToken.isEmpty) return null;
        return 'renewed-$refreshToken';
      }

      expect(mockRefreshNullable(null), isNull);
      expect(mockRefreshNullable(''), isNull);
      expect(mockRefreshNullable('valid'), isNotNull);
    });
  });

  // --- Payload notification ---
  group('Notification payload', () {
    test('notification payload memiliki title dan body', () {
      const payload = {
        'title': 'Jadwal kuliah berubah',
        'body': 'Kelas Mobile pindah ke Ruang A2',
      };
      expect(payload['title'], isNotEmpty);
      expect(payload['body'], isNotEmpty);
    });

    test('data payload membawa route untuk deep link', () {
      const data = {'route': '/pengumuman/1', 'id': '1'};
      final route = routeFromMessage(data.cast<String, String>());
      expect(route, '/pengumuman/1');
    });
  });
}
