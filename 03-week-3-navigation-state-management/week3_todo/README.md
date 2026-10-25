# ToDo dengan GoRouter dan Riverpod

Aplikasi Flutter untuk mengelola daftar tugas dan melihat statistik simulasi.
Project ini dibuat sebagai mini project minggu 3: navigasi dengan GoRouter,
state management Riverpod, dan UI asinkron yang dapat menangani loading,
error, serta success.

## Fitur

- Daftar tugas hanya menampilkan tugas yang belum selesai.
- Tambah, tandai selesai, hapus, dan buka detail tugas.
- Navigasi tab GoRouter: `/` untuk daftar ToDo dan `/stats` untuk statistik.
- Route detail `/todo/:index` dengan tombol kembali.
- Statistik dimuat setelah jeda 2 detik dan memiliki simulasi error sekitar 30%.
- Pesan error menyediakan tombol untuk mencoba memuat kembali.

## Teknologi

- Flutter / Dart
- `flutter_riverpod` untuk state (`Notifier`, `AsyncNotifier`, dan provider turunan)
- `go_router` untuk routing dan navigasi tab
- `flutter_test` untuk unit test dan widget test

## Menjalankan aplikasi

Jalankan perintah dari direktori project ini:

```bash
flutter pub get
flutter run
```

Untuk menjalankan pemeriksaan:

```bash
flutter analyze
flutter test
```

## Struktur penting

```text
lib/
  app_router.dart
  main.dart
  pages/
  providers/
  widgets/
test/
Screenshots/
docs/
```

## Screenshot

Bukti tampilan dan hasil pemeriksaan tersedia di [`Screenshots/`](Screenshots/):

- [Daftar ToDo kosong](Screenshots/04-p2-kosong.jpg)
- [Tambah tugas](Screenshots/05-p2-tambah-tugas.jpg)
- [Daftar tugas](Screenshots/06-p2-daftar-tugas.jpg)
- [Status loading](Screenshots/07-p3-loading-10s.jpg)
- [Status berhasil](Screenshots/08-p3-succes.jpg)
- [Status error](Screenshots/09-p3-error.jpg)
- [Hasil AI Challenge](Screenshots/10-hasil-ai-challenge.jpg)
- [Hasil flutter analyze](Screenshots/11-flutter-analyze.png)
- [Hasil flutter test](Screenshots/12-flutter-test.png)
- [Bukti refactoring dan validasi](Screenshots/)

## Dokumentasi

- [Prompt, hasil AI, perbaikan, dan keputusan teknis](docs/AI_CHALLENGE.md)
- [Checklist dan hasil verifikasi](docs/VERIFIKASI.md)
