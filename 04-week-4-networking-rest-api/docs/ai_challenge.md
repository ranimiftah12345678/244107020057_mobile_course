# AI Prompt Challenge — Minggu 4

## Prompt yang Digunakan

```
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

## Output Awal AI

AI menghasilkan:
1. `Comment` model dengan `fromJson` — menggunakan cast langsung `json['postId'] as int` **(tanpa null-safety)**.
2. `CommentRepository.fetchComments(int postId)` — benar, menggunakan query parameter `?postId=`.
3. `commentListProvider` sebagai `FutureProvider.family` — bukan `AsyncNotifierProvider.family` seperti yang diminta.
4. `friendlyErrorMessage` hanya menangani `connectionTimeout` dan `badResponse`, **melewatkan `connectionError` dan `sendTimeout`**.
5. Test hanya menguji happy path (`fromJson` dengan semua field hadir).

## Perbaikan yang Dilakukan

| # | Masalah dari AI | Perbaikan |
|---|---|---|
| 1 | Cast langsung `json['postId'] as int` bisa crash jika null | Diganti `(json['postId'] as num?)?.toInt() ?? 0` untuk semua field numeric |
| 2 | `FutureProvider.family` bukan `AsyncNotifierProvider.family` | Diubah ke `AsyncNotifierProvider.family<CommentListFamilyNotifier, List<Comment>, int>` agar konsisten dengan pola minggu ini |
| 3 | `friendlyErrorMessage` tidak menanggani `connectionError` dan `sendTimeout` | Ditambahkan kedua case; fungsi dipindahkan ke `network_errors.dart` agar bisa dipakai ulang di semua halaman |
| 4 | Test hanya happy path | Ditambahkan test: field hilang → nilai default, field null → nilai default, dan test error `connectionError` |
| 5 | Timeout 10 detik tidak diterapkan ke `CommentRepository` | Timeout sudah diatur di `createDio()` (terpusat di `api_client.dart`), tidak perlu per-method |

## Keputusan Teknis

- `friendlyErrorMessage` **dipindahkan ke `network_errors.dart`** (bukan di dalam `providers.dart`) agar bisa diimpor oleh `comment_providers.dart`, `post_list_page.dart`, `post_detail_page.dart`, dan `paged_post_page.dart` tanpa circular import.
- Provider digunakan sebagai **family** (`commentListProvider(postId)`) sehingga setiap postId memiliki state terisolasi dan bisa di-invalidate secara independen.
- UI `PostDetailPage` memanggil `ref.invalidate(commentListProvider(post.id))` untuk retry, bukan `ref.invalidate(commentListProvider)` yang akan membersihkan semua komentar sekaligus.

## Verifikasi Checklist

| Pemeriksaan | Hasil | Catatan |
|---|---|---|
| UI memanggil Dio langsung? | ❌ Tidak | Semua akses via `commentRepositoryProvider` |
| `fromJson` aman null? | ✅ Ya | Pola `(json['x'] as num?)?.toInt() ?? 0` |
| Semua tipe `DioExceptionType` dipetakan? | ✅ Ya | timeout, connectionError, badResponse (404/401/403/5xx) |
| `baseUrl`/timeout terpusat? | ✅ Ya | Di `api_client.dart`, tidak tersebar |
| Test menguji field hilang? | ✅ Ya | 3 kasus: semua hadir, semua null, field tidak ada |
| `flutter analyze` lolos? | ✅ Ya | No issues found |
| `flutter test` lolos? | ✅ Ya | All tests passed |

## Output Awal AI (Disimpan untuk Referensi)

```dart
// Contoh kode AI yang BELUM diperbaiki (cast tidak aman):
factory Comment.fromJson(Map<String, dynamic> json) {
  return Comment(
    postId: json['postId'] as int,  // ← bisa crash jika null
    id: json['id'] as int,          // ← bisa crash jika null
    name: json['name'] as String,   // ← bisa crash jika null
    email: json['email'] as String,
    body: json['body'] as String,
  );
}
```

Setelah diperbaiki:
```dart
factory Comment.fromJson(Map<String, dynamic> json) {
  return Comment(
    postId: (json['postId'] as num?)?.toInt() ?? 0,
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    body: json['body'] as String? ?? '',
  );
}
```
