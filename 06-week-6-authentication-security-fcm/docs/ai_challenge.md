# AI Prompt Challenge — Week 6: Authentication, Security & FCM

**Mahasiswa:** Rani Miftahus Saadah  
**NIM:** 244107020057  
**Kelas:** TI_3F

---

## Prompt yang Digunakan

```
Aplikasi Flutter Campus Notification App.
Stack: flutter_secure_storage, go_router, Riverpod, Dio.
(Tanpa Firebase sungguhan — pakai mock auth + simulasi FCM)

Buatkan:
1. TokenStore: simpan access + refresh token ke flutter_secure_storage
2. AuthRepository: login mock (delay 600ms, validasi email+panjang password),
   refresh mock (delay 300ms)
3. Dio interceptor: tambah Bearer header, auto-refresh saat 401
4. AuthNotifier: build() baca token dari store, login(), logout()
5. GoRouter redirect: guard /login berdasarkan authProvider
6. Simulasi FCM payload (notification + data) dengan dialog
7. AnnouncementPage: deep link /pengumuman/:id dari data.route

Tandai bagian yang:
- BERBEDA untuk Android 13+ vs iOS (izin notifikasi)
- Tidak boleh mengakses BuildContext
- Secret/token tidak boleh di-log atau hardcode
```

---

## Output AI (Claude Sonnet)

### Tabel Perbandingan Model Autentikasi

| Model | Cara kerja | Kapan dipakai |
|---|---|---|
| **Firebase Auth** | SDK Firebase tukar kredensial → ID token JWT | Butuh login cepat tanpa server auth sendiri |
| **JWT + refresh** | Server terbitkan access (15 mnt) + refresh (7 hari) | Backend sendiri, kontrol penuh |
| **OAuth/Google** | Authorization code → token via provider | Login sosial / SSO kampus |
| **Mock (codelab)** | Delay + validasi sederhana, token string dummy | Belajar alur tanpa backend nyata |

### Token Hierarchy

```
ID token    → bukti identitas (siapa user)
Access token → izin akses berumur pendek (~15 mnt)
Refresh token → tiket perbarui access tanpa login ulang (~7 hari)
```

### Perbedaan Android 13+ vs iOS

| Aspek | Android 13+ | iOS |
|---|---|---|
| Izin notifikasi | `POST_NOTIFICATIONS` wajib diminta runtime | `requestPermission()` via UNUserNotificationCenter |
| Default | Notifikasi **diblokir** sampai user izinkan | Muncul prompt izin otomatis saat `requestPermission()` |
| Exact alarm | Butuh `SCHEDULE_EXACT_ALARM` terpisah | Tidak ada analog |

### Tiga App State FCM

| State | Handler | Catatan |
|---|---|---|
| **Foreground** | `FirebaseMessaging.onMessage` | Harus tampil manual via `flutter_local_notifications` |
| **Background** | Banner sistem otomatis + `onMessageOpenedApp` | Jangan akses BuildContext di background handler |
| **Terminated** | `getInitialMessage()` saat startup | Panggil setelah router siap |

---

## Perbaikan yang Dilakukan pada Output AI

| Masalah | Perbaikan |
|---|---|
| AI menambahkan `firebase_core` + `firebase_messaging` | Dihapus — codelab memakai mock tanpa Firebase sungguhan (tidak ada `google-services.json`) |
| AI memakai `@pragma('vm:entry-point')` untuk background handler | Dihapus — tidak relevan tanpa Firebase |
| AI menyarankan log token untuk debugging | Dihapus — melanggar prinsip keamanan |
| AI membuat GoRouter sebagai `final` global | Diubah ke fungsi `buildRouter(WidgetRef)` agar bisa baca provider |
| AI memakai `ref.read` di dalam `redirect` synchronous | OK karena redirect hanya membaca nilai cached, bukan `Future` |

---

## Checklist Implementasi

- [x] `TokenStore`: simpan/baca/hapus token via `flutter_secure_storage`
- [x] `AuthRepository`: login mock dengan validasi + delay; refresh mock
- [x] Dio interceptor: Bearer header + auto-refresh 401 + retry sekali
- [x] `AuthNotifier`: build() baca token, login(), logout(), guard redirect
- [x] GoRouter: redirect `/login` ↔ `/` berdasarkan status login
- [x] Halaman Login: form email+password, toggle visibility, error state
- [x] Halaman Home: daftar pengumuman, tombol logout, simulasi push
- [x] Halaman Detail: deep link `/pengumuman/:id`, tabel tiga app state FCM
- [x] Dialog simulasi FCM payload (notification + data)
- [x] Token tidak di-log, tidak hardcode di kode, disimpan di secure storage
- [x] Test: routeFromMessage (4 kasus), TokenStore (3 kasus), auth logic (3), payload (2)
