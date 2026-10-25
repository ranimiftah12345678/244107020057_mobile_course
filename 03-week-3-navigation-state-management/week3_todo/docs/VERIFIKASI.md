# Checklist dan hasil verifikasi

## Checklist fitur

- [x] Navigasi GoRouter ke `/` (daftar), `/stats` (statistik), dan
  `/todo/:index` (detail).
- [x] Tombol `NavigationBar` berpindah antara daftar dan statistik.
- [x] Route detail dapat dibuka melalui path dan kembali ke daftar.
- [x] `ProviderScope` membungkus root aplikasi dan state daftar bertahan saat
  berpindah tab.
- [x] Riverpod mengelola state dengan `Notifier`, `AsyncNotifier`, dan provider
  turunan.
- [x] UI statistik menangani loading, error dengan tombol retry, dan data sukses.
- [x] Unit test dan widget test disertakan.
- [x] Prompt AI Challenge, ringkasan hasil, perbaikan, dan alasan keputusan
  teknis didokumentasikan di [AI_CHALLENGE.md](AI_CHALLENGE.md).
- [x] Screenshot dan bukti pemeriksaan tersedia pada [`../Screenshots/`](../Screenshots/).

## Perintah validasi

Jalankan dari folder `week3_todo`:

```text
flutter analyze
No issues found!

flutter test
All tests passed!
```

Test mencakup:

- sukses dan error pada `StatsNotifier`;
- loading, error/retry, dan data sukses pada `StatsPage`;
- filter tugas yang belum selesai;
- interaksi pada `TodoTile`;
- tambah tugas, navigasi tab, route detail langsung, dan tombol kembali.

## Catatan batasan

Daftar ToDo hanya disimpan dalam memori. Path `/todo/:index` dapat membuka
halaman detail langsung, tetapi hanya dapat menampilkan tugas jika indeks
tersebut tersedia pada state saat ini. Persistensi lintas restart belum
termasuk ruang lingkup mini project.
