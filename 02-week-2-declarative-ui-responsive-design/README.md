# Minggu 2 - Declarative UI & Responsive Design

| | |
|---|---|
| **Nama** | Rani Miftahus Saadah |
| **NIM** | 244107020057 |
| **Kelas** | TI_3F |
| **Mata Kuliah** | Pemrograman Mobile |
| **Program Studi** | Teknik Informatika, Politeknik Negeri Malang |

## 1. Tujuan

Membangun halaman **Academic Overview**, sebuah dashboard mahasiswa yang:

- menampilkan **1 kolom** pada layar sempit dan **2 kolom** pada layar lebar,
- mendukung **tema terang dan gelap** dengan toggle manual,
- memakai `Row`, `Column`, `Expanded`, dan `Container`,
- memiliki **label aksesibilitas** pada elemen penting,
- dilengkapi widget test dan refactoring sesuai codelab Minggu 2.

## 2. Fitur Utama

- Header profil mahasiswa (avatar, nama, NIM, program studi).
- Empat kartu informasi: Assignments, Attendance, Portfolio, Current week.
- Layout responsif memakai `LayoutBuilder` dengan breakpoint 700 (`kWideBreakpoint`).
- Toggle tema memakai `CupertinoSwitch`; state dikelola `StatefulWidget`.
- Warna dan tipografi memakai `Theme.of(context)`.
- Label `Semantics` pada toggle, header profil, dan setiap kartu.
- Dua widget test untuk perilaku responsif.

## 3. Stack Teknologi

- Flutter (Material 3) dan Dart
- Widget utama: `LayoutBuilder`, `GridView.count`, `Card`, `CupertinoSwitch`, `Semantics`, `ExcludeSemantics`
- Testing: `flutter_test`
- Perangkat uji: [ISI: misal HP Android M2101K7BNY dan Google Chrome]

## 4. Struktur Folder

```
244107020057_PemrogramanMobile/
└── 02-week-2-declarative-ui-responsive-design/
    ├── lib/main.dart
    ├── test/widget_test.dart
    ├── docs/ai-log.md
    ├── screenshots/
    ├── pubspec.yaml
    └── README.md
```

## 6. Hasil Praktikum

### 6.1 Warm-up: Kartu Profil

Sebelum membuat dashboard, saya melatih widget dasar dengan kartu profil sederhana. Kartu memakai `Container` (ukuran, padding, dekorasi), `Column` (susunan vertikal), `Row` (susunan horizontal), dan `Expanded` (pembagian ruang tersisa).

![Warm-up kartu profil](screenshots/01-warmup-card.jpg)

**Eksperimen warm-up:**

| Eksperimen | Hasil pengamatan |
|---|---|
| Menghapus `Expanded` pada baris nama | Teks yang panjang tidak membungkus dan meluber keluar kartu; muncul garis kuning-hitam bertuliskan *RIGHT OVERFLOWED BY ... PIXELS*. |
| Menghapus `mainAxisSize: MainAxisSize.min` | Tinggi `Column` terluar mengikuti ruang maksimum sehingga kartu menjadi lebih tinggi dan tidak lagi pas dengan isinya. |
| Menambah baris `Email` | Berhasil dengan pola `Row` + `Expanded` yang sama seperti baris NIM dan Kelas. |

![Warm-up tanpa Expanded](screenshots/02-warmup-tanpa-expanded.jpg)

![Warm-up tanpa mainAxisSize](screenshots/03-warmup-tanpa-mainaxissize.jpg)

![Warm-up menambahkan email](screenshots/04-tambah-baris-email.jpg)

**Penjelasan:** `Row` memberi anak yang tidak fleksibel lebar tak terbatas pada sumbu utama. Tanpa `Expanded`, `Column` di samping avatar tidak mendapat batas lebar, sehingga teks tidak punya alasan untuk membungkus. Dengan `Expanded`, `Column` hanya mengisi sisa ruang setelah avatar dan jarak, sehingga teks otomatis turun ke baris berikutnya.

### 6.2 Dashboard Responsif

Jumlah kolom ditentukan oleh `LayoutBuilder` berdasarkan lebar yang tersedia:

```dart
const double kWideBreakpoint = 700;

// di dalam LayoutBuilder
final columns = constraints.maxWidth >= kWideBreakpoint ? 2 : 1;
```

| Layar sempit (1 kolom) | Layar lebar (2 kolom) |
|---|---|
| ![Layar sempit terang](screenshots/05-hasil-dashboard.jpg) | ![Layar lebar terang](screenshots/06-wide-light.png) |

Halaman terdiri atas `ProfileHeader` di atas dan `GridView.count` di bawahnya (dibungkus `Expanded` agar mengisi sisa tinggi layar).

### 6.3 Tema Terang dan Gelap

Tema diatur melalui `theme`, `darkTheme`, dan `themeMode` pada `MaterialApp`. Toggle `CupertinoSwitch` di AppBar mengubah state `isDark` pada `StatefulWidget`, lalu `MaterialApp` dibangun ulang dengan tema yang sesuai.

```dart
themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
```

| Layar sempit (gelap) | Layar lebar (gelap) |
|---|---|
| ![Layar sempit gelap](screenshots/05-narrow-dark.png) | ![Layar lebar gelap](screenshots/07-wide-dark.png) |

Warna header dan teks diambil dari `ColorScheme` (`primaryContainer` dan `onPrimaryContainer`), sehingga kontras tetap terbaca di kedua tema.

### 6.4 Eksperimen Layout

| Eksperimen | Hasil |
|---|---|
| Breakpoint diubah (500 / 700 / 1000) | [ISI: misal pada breakpoint 500 layar landscape HP sudah 2 kolom; pada 1000 layar tablet masih 1 kolom] |
| `themeMode` dipaksa `ThemeMode.dark` | Aplikasi selalu gelap. Toggle tetap bergerak tetapi tema tidak berubah karena `themeMode` tidak lagi membaca `isDark`. Setelah dikembalikan, toggle berfungsi normal. |
| Ukuran layar berbeda | [ISI: ukuran yang diuji dan jumlah kolomnya, misal HP portrait: 1 kolom; HP landscape: 2 kolom; Chrome 1200 px: 2 kolom] |

![Eksperimen breakpoint](screenshots/08-eksperimen-breakpoint.png)

### 6.5 Aksesibilitas

- Toggle tema dibungkus `Semantics(label: 'Mode gelap')` agar screen reader membacanya sebagai saklar mode gelap, bukan saklar tanpa nama.
- Ikon matahari/bulan diberi `ExcludeSemantics` karena hanya dekoratif.
- Header profil diberi label ringkasan: nama, NIM, dan program studi.
- Setiap `InfoCard` diberi `Semantics(container: true, label: '<judul>: <nilai>')` sehingga terbaca sebagai satu informasi, misalnya "Attendance: 92%".
- Informasi tidak hanya disampaikan melalui warna; setiap kartu memiliki teks judul dan nilai.

Verifikasi dilakukan dengan `showSemanticsDebugger: true` (dipasang sementara, lalu dihapus).

![Semantics debugger](screenshots/09-semantics.png)

## 7. Penjelasan Kode Penting

| Bagian | Fungsi |
|---|---|
| `kWideBreakpoint = 700` | Satu-satunya definisi breakpoint, mudah diubah |
| `LayoutBuilder` | Membaca lebar yang tersedia lalu menentukan jumlah kolom |
| `GridView.count` | Menyusun kartu dalam grid dengan jumlah kolom dinamis |
| `InfoCard` | Widget reusable untuk kartu informasi (`title` dan `value`) |
| `ProfileHeader` | Header profil memakai `Container`, `Row`, `Column`, `Expanded` |
| `Theme.of(context)` | Warna dan gaya teks mengikuti tema terang/gelap secara otomatis |
| `StatefulWidget` pada `DashboardApp` | Menyimpan state `isDark` |
| `CupertinoSwitch` | Contoh widget Cupertino di aplikasi Material |
| `Semantics` + `ExcludeSemantics` | Label screen reader yang jelas tanpa bacaan ganda |

## 8. Pengujian

Dua widget test memverifikasi perilaku responsif dengan mengubah ukuran layar lewat `tester.view`:

| Test | Ukuran layar | Yang diverifikasi | Hasil |
|---|---|---|---|
| Dashboard satu kolom di layar sempit | 400 x 800 | Lebar kartu kurang dari 700 | [ISI: Lulus] |
| Dashboard dua kolom di layar lebar | 1200 x 800 | Lebar kartu lebih dari 500 | [ISI: Lulus] |

```powershell
flutter analyze   # No issues found!
flutter test      # All tests passed!
```

![flutter analyze](screenshots/10-flutter-analyze.png)

![flutter test](screenshots/11-flutter-test.png)

## 9. Refactoring

Setelah tugas utama berjalan, kode dirapikan:

| No | Perubahan | Sebelum | Sesudah |
|---|---|---|---|
| 1 | Kartu menjadi widget reusable | `DashboardCard` | `InfoCard(title, value)` dipakai empat kali |
| 2 | Warna dan ukuran dari tema | `TextStyle(fontSize: 20, ...)` | `textTheme.titleLarge?.copyWith(...)`, `textTheme.bodyMedium`, `scheme.primary`, `scheme.onPrimary` |
| 3 | Breakpoint menjadi konstanta | angka `700` langsung di kode | `const double kWideBreakpoint = 700;` |
| 4 | Pemeriksaan statis | - | `flutter analyze` tanpa error maupun warning baru |

Tampilan aplikasi tetap sama sebelum dan sesudah refactor; yang berubah hanya struktur kode.

## 10. AI Prompt Challenge

AI dipakai setelah implementasi mandiri selesai, hanya untuk membandingkan alternatif tata letak dan memperkuat konsep. Dokumentasi lengkap ada di [`docs/ai-log.md`](docs/ai-log.md).

| Prompt | Ringkasan output | Keputusan | Alasan teknis |
|---|---|---|---|
| Bandingkan `GridView` dan `LayoutBuilder` + `Column` dari sisi responsif dan aksesibilitas | `GridView` lebih ringkas dan hanya merender yang terlihat, tetapi tinggi kartu terikat `childAspectRatio`. `Column` mengikuti isi kartu, tetapi kodenya lebih panjang dan perlu scroll manual. | [ISI: misal sebagian: tetap `GridView.count`] | [ISI: misal 4 kartu saja dan kode lebih sederhana, tetapi risiko font besar dicatat] |
| Kapan `Expanded` menyebabkan overflow | Empat kasus: lebar `Row` tak terbatas, tinggi `Column` tak terbatas, `Expanded` bukan child langsung, dan saudara berukuran tetap melampaui ruang. | Diterima sebagai penguat konsep | Cocok dengan hasil eksperimen warm-up saya |
| Verifikasi: responsif di bawah 600 px, aksesibilitas, widget stabil | Responsif di bawah 600 px aman (1 kolom). Tinggi tetap pada grid tetap berisiko saat font diperbesar. Semua widget tersedia di Flutter stabil. | [ISI] | [ISI] |

**Temuan verifikasi:** [ISI: satu hal dari saran AI yang Anda uji, misal hasil memperbesar ukuran font di HP ke maksimum, apakah kartu overflow atau tidak, beserta screenshot].

![AI Prompt Challenge](screenshots/12-ai-prompt-challenge.png)

## 11. Kendala dan Solusi

| Kendala | Penyebab | Solusi |
|---|---|---|
| `flutter run` gagal dengan `No pubspec.yaml file found` | Perintah dijalankan dari folder root portfolio, padahal root bukan project Flutter | Pindah ke folder minggu 2 (`cd 02-week-2-...`) lalu jalankan ulang |
| `flutter analyze` melaporkan error `MyApp`/`DashboardApp` tidak dikenal di `test/` | File `widget_test.dart` masih berisi tes counter bawaan `flutter create` | Isi `widget_test.dart` diganti dengan tes dashboard |
| Instalasi ke HP gagal: `INSTALL_FAILED_USER_RESTRICTED` | HP Xiaomi memblokir instalasi lewat USB | Mengaktifkan **Instal via USB** (dan debugging USB keamanan) di Opsi pengembang, lalu menyetujui dialog instalasi di HP |
| `flutter test` gagal: `Bad state: Too many elements` | `tester.getSize(find.byType(Card))` membutuhkan tepat satu elemen, sedangkan halaman memiliki empat `Card` | Finder diubah menjadi `find.byType(Card).first` |
| Build pertama sangat lama (sekitar 749 detik pada `assembleDebug`) | Gradle mengunduh dependensi pada build pertama | Dibiarkan sampai selesai; build berikutnya jauh lebih cepat |

![Error Too many elements](screenshots/14-error-too-many-elements.png)

## 12. Refleksi

**Apa perbedaan cara berpikir imperative dan declarative saat membangun UI?**
Pada pendekatan imperative, developer mengubah elemen UI satu per satu ketika data berubah. Pada pendekatan declarative, developer mendeskripsikan tampilan berdasarkan state saat ini, dan Flutter membangun ulang bagian yang relevan ketika state berubah. Pada tugas ini, toggle tema hanya mengubah `isDark` lewat `setState`, lalu `themeMode` pada `MaterialApp` membaca nilai tersebut. Tidak ada kode yang mengubah warna widget satu per satu.

**Kapan `Expanded` membantu dan kapan penggunaannya justru menghasilkan layout error?**
`Expanded` membantu membagi sisa ruang di dalam `Row` atau `Column`, misalnya agar teks panjang membungkus alih-alih meluber. Pada eksperimen warm-up, menghapus `Expanded` membuat `Column` di samping avatar tidak punya batas lebar sehingga teks overflow. Sebaliknya, `Expanded` bisa menimbulkan error jika sumbu utamanya tidak terbatas (misalnya `Row` di dalam scroll horizontal atau `Column` di dalam `ListView`), atau jika `Expanded` bukan child langsung dari `Row`/`Column`/`Flex`.

**Bagaimana breakpoint dan theme memengaruhi pengalaman pengguna?**
Breakpoint memastikan informasi tetap nyaman dibaca di layar kecil maupun besar: satu kolom di layar sempit agar kartu tidak terlalu sempit, dan dua kolom di layar lebar agar ruang tidak terbuang. Theme yang terpusat membuat tampilan konsisten, dan dark mode membantu kenyamanan di lingkungan gelap, selama kontras warna tetap terjaga. Karena itu warna header diambil dari `ColorScheme`, bukan warna tetap.

**Apa yang Anda verifikasi dari rekomendasi AI setelah tugas inti selesai?**
[ISI dengan hasil percobaan Anda: misal apakah layout tetap responsif di lebar 320/360/599 px, apakah kartu overflow saat ukuran font diperbesar, apakah widget yang disarankan tersedia di Flutter stabil (`flutter analyze` bersih), dan bukti berupa screenshot atau hasil test.]

## 13. Checklist Verifikasi

- [x] `flutter analyze` tidak menghasilkan error
- [x] `flutter test` lulus semua widget test responsif
- [x] Aplikasi berjalan pada ukuran layar sempit dan lebar
- [x] Dark mode memiliki kontras dan teks yang terbaca
- [x] Struktur widget dapat dijelaskan saat code review
- [x] Screenshot, folder `test/`, dan README tersimpan pada folder tugas Week 2

## 14. Kesimpulan

Pada minggu ini saya membangun halaman Academic Overview yang responsif (1 kolom pada layar sempit, 2 kolom pada layar lebar), mendukung tema terang dan gelap dengan toggle, serta memiliki label aksesibilitas. Praktikum ini memperjelas cara kerja `Expanded` pada `Row`, peran `LayoutBuilder` dalam layout responsif, dan manfaat memusatkan warna serta tipografi pada `Theme`. Kendala yang muncul (struktur folder, tes bawaan, izin instalasi di HP, dan finder `Card`) menjadi pelajaran tentang membaca pesan error dengan teliti.