# AI Challenge

## Prompt

> Bangun aplikasi ToDo dengan navigasi dan Riverpod. Buat minimal dua halaman
> menggunakan GoRouter (daftar tugas serta halaman detail atau statistik),
> kelola state dengan Riverpod `Notifier` dan `ConsumerWidget`, tambahkan
> simulasi asinkron dengan state loading, error, dan success, serta sertakan
> unit/widget test yang lulus. Dokumentasikan implementasi dan hasil verifikasi.

## Hasil AI

Implementasi menghasilkan aplikasi dengan:

- `TodoListNotifier` dan `todoListProvider` untuk state daftar tugas.
- `incompleteTodosProvider` sebagai provider turunan untuk menyaring tugas
  yang belum selesai.
- Halaman daftar ToDo, detail tugas, dan statistik.
- GoRouter dengan route `/`, `/stats`, dan `/todo/:index`, serta `NavigationBar`
  untuk berpindah antara daftar dan statistik.
- `StatsNotifier` dengan jeda simulasi dua detik dan peluang gagal sekitar 30%.
- UI statistik yang menangani loading, error dengan tombol retry, serta data
  sukses.
- Unit test provider dan widget test untuk interaksi, navigasi, dan status UI.

## Perbaikan setelah hasil awal

- Mengganti test counter bawaan template menjadi test fitur ToDo.
- Menyediakan notifier override yang deterministic agar test tidak menunggu
  timer dua detik atau bergantung pada peluang acak.
- Menambahkan test UI terpisah untuk loading, error/retry, dan data sukses.
- Menguji route detail melalui interaksi daftar dan navigasi langsung ke path.
- Menambahkan `ProviderScope` di root agar state dapat dipakai lintas halaman.

## Alasan keputusan teknis

- `NotifierProvider` cocok untuk operasi sinkron daftar tugas; `AsyncNotifier`
  menyatukan proses fetch statistik dengan state asinkron Riverpod.
- Provider turunan menjaga logika filter di luar widget dan otomatis mengikuti
  perubahan daftar sumber.
- `StatefulShellRoute.indexedStack` mempertahankan state tab saat pengguna
  berpindah halaman.
- Route detail memakai indeks sebagai identitas sederhana untuk mini project
  tanpa penyimpanan persisten. Detail hanya dapat menampilkan tugas yang ada
  di state saat itu; data daftar belum bertahan setelah aplikasi dimulai ulang.
- Override notifier di test memastikan jalur sukses/error dapat diverifikasi
  terulang secara stabil.

## Verifikasi

Perintah `flutter analyze` dan `flutter test` dijalankan di direktori project.
Hasil akhir dan daftar cakupan test dicatat pada [VERIFIKASI.md](VERIFIKASI.md).
Screenshot bukti tersedia pada [`../Screenshots/`](../Screenshots/).
