# AI Prompt Challenge — Week 5: Local Storage & Offline First

**Mahasiswa:** Rani Miftahus Saadah  
**NIM:** 244107020057  
**Kelas:** TI_3F

---

## Prompt yang Digunakan

```
Saya membangun aplikasi Flutter offline-first. Saya perlu menyimpan:
1. Preferensi kecil: tema gelap/terang, waktu terakhir dibuka
2. Catatan teks: CRUD, perlu dirty flag untuk sinkronisasi

Bandingkan trade-off antara:
- SharedPreferences
- Hive
- SQLite (sqflite)
- Drift (TypeSafe SQLite)

Untuk setiap opsi jelaskan: kapabilitas, kelebihan, kekurangan, dan rekomendasi kapan dipakai.
Kemudian rekomendasikan kombinasi terbaik untuk kasus saya.
```

---

## Output AI (Claude Sonnet)

### Tabel Perbandingan Storage

| Kriteria | SharedPreferences | Hive | SQLite (sqflite) | Drift |
|---|---|---|---|---|
| **Jenis** | Key-Value | NoSQL (box) | Relasional | Relasional (typed) |
| **Format** | String/bool/int/double | Binary (Hive Box) | SQL `.db` file | SQL + Dart codegen |
| **Query kompleks** | ❌ Tidak ada | ⚠️ Terbatas | ✅ Full SQL | ✅ Full SQL + tipe aman |
| **Performa baca** | ⚡ Sangat cepat (RAM cache) | ⚡ Cepat (binary) | 🟡 Cukup (disk) | 🟡 Cukup (disk) |
| **Null safety** | ✅ | ✅ | ⚠️ Manual (`Map<String,dynamic>`) | ✅ (codegen) |
| **Relasi antar tabel** | ❌ | ❌ | ✅ JOIN, FK | ✅ JOIN, FK + tipe aman |
| **Migration schema** | N/A | ⚠️ Manual | ⚠️ Manual (`onUpgrade`) | ✅ Otomatis (Drift) |
| **Ukuran package** | 🟢 Kecil | 🟡 Sedang | 🟢 Kecil | 🟡 Sedang |
| **Boilerplate** | 🟢 Minimal | 🟡 Sedang | 🟡 Sedang | 🔴 Tinggi (codegen) |
| **Testing** | ⚠️ Butuh mock | ✅ In-memory box | ✅ `sqflite_common_ffi` | ✅ In-memory DB |
| **Cocok untuk** | Preferensi, flag, token | Cache semi-terstruktur, offline NoSQL | CRUD terstruktur, dirty flag, sync | Aplikasi besar, schema kompleks |

### Rekomendasi untuk Kasus Ini

**Preferensi (tema, last opened):** → **SharedPreferences**  
Alasan: data kecil, tidak perlu query, langsung dari RAM cache, API sangat sederhana.

**Catatan CRUD dengan dirty flag:** → **SQLite (sqflite)**  
Alasan:
- Dirty flag membutuhkan `WHERE dirty = 1` yang efisien dengan SQL
- `countDirty()` dan `markAllSynced()` trivial dengan SQL
- `updated_at` untuk *last-write-wins* conflict resolution mudah diquery
- `sqflite_common_ffi` memudahkan testing dengan in-memory database

**Mengapa bukan Hive?** Hive tidak mendukung query SQL — `countDirty()` harus iterasi semua data di memori, tidak efisien untuk banyak catatan.

**Mengapa bukan Drift?** Drift lebih cocok untuk proyek besar dengan banyak tabel dan relasi. Untuk CRUD sederhana, overhead codegen tidak sebanding.

---

## Perbaikan yang Dilakukan pada Output AI

| Masalah | Perbaikan |
|---|---|
| AI menyarankan `HiveType` annotation untuk model | Dihapus — tidak memakai Hive |
| AI menyarankan `@riverpod` annotation (codegen) | Diubah ke manual `AsyncNotifierProvider` agar tidak perlu `build_runner` untuk fitur utama |
| AI menulis `sqflite_common_ffi` untuk produksi | Dipindah ke `dev_dependencies` — hanya untuk test |
| AI tidak menyertakan `close()` pada repository | Ditambahkan untuk menghindari connection leak di test |

---

## Checklist Implementasi

- [x] `Note.fromMap` / `toMap` null-safe dengan default value
- [x] `NoteRepository`: insert, fetchAll, fetchById, update, delete, countDirty, markAllSynced
- [x] `PrefsRepository`: getDarkMode, setDarkMode, getLastOpened, updateLastOpened
- [x] `NoteListNotifier`: add, update, delete, invalidateSelf
- [x] `dirtyCountProvider`: menghitung catatan belum sync
- [x] `SyncNotifier`: simulasi upload + markAllSynced
- [x] `darkModeProvider`: toggle + persisten ke SharedPreferences
- [x] `lastOpenedProvider`: update tiap buka Settings
- [x] `NoteTile`: badge "belum sync" jika dirty=true
- [x] `NotesPage`: list, tambah, hapus, badge dirty di AppBar
- [x] `NoteDetailPage`: edit judul/isi, auto-mark dirty, navigasi GoRouter
- [x] `SettingsPage`: toggle tema, tampil last opened
- [x] GoRouter: `/`, `/note/:id`, `/settings`
- [x] Test: `Note.fromMap` (4 kasus), NoteRepository in-memory (8 kasus), NoteListNotifier (2 kasus)
