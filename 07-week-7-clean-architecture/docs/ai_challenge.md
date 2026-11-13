# AI Prompt Challenge — Week 7: Clean Architecture

**Mahasiswa:** Rani Miftahus Saadah  
**NIM:** 244107020057  
**Kelas:** TI_3F

---

## Prompt yang Digunakan

```
Project Flutter saya: week5_offline_notes (notes CRUD + dirty flag + SharedPreferences).
Kondisi kini: lib/{data/local, data/repositories, data/prefs, pages, widgets},
repository langsung diakses widget lewat Riverpod provider.

Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur notes.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana
   (use case per satu baris vs use case yang gabungkan logika bisnis).
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
5. Pastikan domain tidak mengimpor Flutter/sqflite/SharedPreferences.
Jelaskan trade-off setiap keputusan.
```

---

## Output AI (Claude Sonnet)

### Pemetaan File Lama → Tujuan Baru

| File lama (Week 5) | Layer | Tujuan baru (Week 7) |
|---|---|---|
| `lib/data/local/note.dart` | data | Pecah: `domain/entities/note.dart` (entity murni) + `data/models/note_model.dart` (mapping SQLite) |
| `lib/data/local/db.dart` | data | Pindah: `data/datasources/local_db.dart` |
| `lib/data/repositories/note_repository.dart` | data | Pecah: `domain/repositories/note_repository.dart` (interface) + `data/repositories/note_repository_impl.dart` (implementasi) |
| `lib/data/providers.dart` | presentation | Pindah: `core/providers.dart` — wiring DI global |
| `lib/pages/notes_page.dart` | presentation | Pindah: `features/notes/presentation/pages/notes_page.dart` |
| `lib/data/prefs.dart` | data | Tetap di `core/` — tidak fitur-spesifik |
| `lib/data/sync.dart` | domain | Angkat ke `domain/usecases/note_usecases.dart` → `SyncNotes` |

### Struktur Target

```
lib/
├── core/
│   ├── failures.dart                      # Sealed class Failure (domain murni)
│   └── providers.dart                     # Riverpod DI wiring
├── features/
│   └── notes/
│       ├── domain/
│       │   ├── entities/note.dart         # Entity: tidak ada toMap/fromJson
│       │   ├── repositories/              # Interface kontrak
│       │   │   └── note_repository.dart
│       │   └── usecases/
│       │       └── note_usecases.dart     # GetNotes, AddNote, DeleteNote, SyncNotes
│       ├── data/
│       │   ├── datasources/local_db.dart  # openNotesDb()
│       │   ├── models/note_model.dart     # NoteModel extends Note + toMap/fromMap
│       │   └── repositories/
│       │       └── note_repository_impl.dart
│       └── presentation/
│           ├── pages/notes_page.dart
│           └── pages/note_detail_page.dart
└── main.dart
```

### Aturan Dependensi (Dependency Rule)

```
presentation  →  domain  ←  data
```

- `domain` tidak mengimpor `flutter`, `sqflite`, atau package lain
- `data` mengimplementasikan interface dari `domain`
- `presentation` hanya memanggil use case / repository lewat provider

### Kapan Use Case Benar-benar Dibutuhkan?

| Operasi | Butuh use case? | Alasan |
|---|---|---|
| `fetchNotes()` → langsung tampil | ⚠️ Optional | Satu baris, tidak ada logika bisnis |
| `addNote()` → insert + dirty=true | ⚠️ Optional | Logika sederhana, bisa di repository |
| `SyncNotes()` → countDirty + delay + markAllSynced | ✅ **Ya** | Gabungkan 3 operasi, ada logika orchestrasi |
| `deleteNote()` → satu DELETE | ❌ Over-engineering | Langsung dari repository sudah cukup |

---

## Verifikasi Dependency Rule

### Grep Sterilitas — Hasil dari Project Week 7

**1. Presentation bebas dari data mentah (harus NOL hasil):**
```bash
rg "sqflite|getDatabasesPath|SharedPreferences" lib/features/notes/presentation lib/core/providers.dart
# Hasil: 0 match ✅
```

**2. Domain bebas dari framework & package (harus NOL hasil):**
```bash
rg "import 'package:flutter|import 'package:sqflite|import 'package:dio" lib/features/notes/domain lib/core/failures.dart
# Hasil: 0 match ✅
```

**3. Interface repository tinggal di domain:**
```bash
rg "abstract class NoteRepository" lib/
# Hasil: lib/features/notes/domain/repositories/note_repository.dart ✅
```

---

## Perbaikan yang Dilakukan pada Output AI

| Masalah | Perbaikan |
|---|---|
| AI membuat use case terpisah untuk setiap CRUD (GetNoteById, UpdateNote, dll) | Digabung dalam satu file `note_usecases.dart`; `updateNote` langsung dari repository di detail page |
| AI menyarankan `Either<Failure, T>` dari `fpdart` | Diganti record Dart `({T value, Failure? failure})` — lebih idiomatic tanpa package tambahan |
| AI memakai `@override` di use case untuk interface | Dihapus — use case tidak implements interface, hanya memanggil repository |
| AI membuat `NoteModel extends Note` lalu override `==` dan `hashCode` | Dihapus — tidak dibutuhkan untuk CRUD sederhana |

---

## Checklist Implementasi

- [x] `core/failures.dart`: sealed class `Failure` → `LocalFailure`, `NetworkFailure` (domain murni)
- [x] `domain/entities/note.dart`: entity tanpa `toMap`/`fromMap`
- [x] `domain/repositories/note_repository.dart`: interface kontrak dengan record return type
- [x] `domain/usecases/note_usecases.dart`: `GetNotes`, `AddNote`, `DeleteNote`, `SyncNotes`
- [x] `data/models/note_model.dart`: `NoteModel extends Note` + `toMap`/`fromMap`/`toEntity`/`fromEntity`
- [x] `data/datasources/local_db.dart`: `openNotesDb()`
- [x] `data/repositories/note_repository_impl.dart`: implements `NoteRepository`
- [x] `core/providers.dart`: wiring DI Riverpod (repository + use case providers)
- [x] `presentation/pages/notes_page.dart`: hanya baca state dari provider
- [x] `presentation/pages/note_detail_page.dart`: edit + save via repository
- [x] Test: `NoteModel` (3), `GetNotes` use case (2), `NoteRepositoryImpl` (6), `SyncNotes` (2), entity (2)
- [x] Dependency rule terbukti: 3 grep sterilitas hasilkan 0 match
