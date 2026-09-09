# KTK: Kapan Terakhir Kali...?

> Catat hal-hal kecil yang sering dilupakan — dan biarkan KTK menjawab **"kapan terakhir kali gua melakukan ini?"** dalam sekali lirik.

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)
![Offline First](https://img.shields.io/badge/Architecture-Offline--First-2DC653)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-FFB703)

**KTK: Kapan Terakhir Kali...?** adalah aplikasi produktivitas untuk mencatat aktivitas kecil yang "sepele tapi berguna": kapan terakhir ganti oli, potong rambut, cuci AC, bayar langganan, atau jalan sama ayang. Semua riwayat tersimpan 100% lokal di HP — tanpa akun, tanpa login, tanpa cloud, tanpa internet.

Personality-nya seperti teman dekat yang sedikit usil tapi perhatian: pengingat datang dengan bahasa kasual Indonesia bertingkat tone — **Santai**, **Sarcastic/Cewet**, atau **Suportif**.

---

## ✨ Fitur

| Fitur | Status |
|---|---|
| Quick log satu tap + penghitung hari sejak terakhir dilakukan (days-since) | 🚧 Fase 2 |
| Kartu aktivitas accordion dengan warna state (hijau → biru → oranye → merah) | 🚧 Fase 2 |
| Pencarian instan + filter 10 kategori standar | 🚧 Fase 2 |
| Riwayat lengkap per aktivitas (Basic: 5 entri terakhir, Premium: tak terbatas) | 🚧 Fase 3 |
| Form tambah/edit aktivitas dengan emoji icon | 🚧 Fase 4 |
| Pengingat lokal offline dengan 3 tone kepribadian (Premium) | 🚧 Fase 5 |
| Onboarding + profil tanpa akun | 🚧 Fase 6 |
| Paywall Premium + IAP (Rp 15.000/bln atau Rp 119.000 lifetime) | 🚧 Fase 7 |
| Backup/restore terenkripsi `.ktkbackup` (AES-256) | 🚧 Fase 8 |
| Insight: KTK Score, statistik & grafik interval rata-rata (Premium) | 🚧 Fase 8 |
| Home-screen widget quick log (Premium) | 🚧 Fase 9 |
| Foundation: design system, splash, app shell, bottom nav | ✅ Fase 0 |

Roadmap lengkap: [`docs/KTK - Development Plan.md`](../docs/) di workspace, log progres berjalan di [`docs/PROGRESS.md`](docs/PROGRESS.md).

---

## 🛠 Tech Stack

| Kebutuhan | Pilihan | Catatan |
|---|---|---|
| Framework | **Flutter 3.47 / Dart ^3.13.2** | Satu codebase untuk Android 8.0+ & iOS 15+ |
| Database lokal | **drift** (SQLite) | Skema relasional `Activity 1:N Log` dengan `ON DELETE CASCADE` + indeks; query reaktif via stream |
| State management | **flutter_riverpod** | Implementasi MVVM + Repository (ViewModel = Notifier) |
| Notifikasi lokal | `flutter_local_notifications` + `timezone` | Android `AlarmManager` / iOS `UNUserNotificationCenter` — tanpa server |
| In-app purchase | `in_app_purchase` | Play Billing & StoreKit 2, verifikasi lokal |
| Font | **Caveat + DM Sans** (bundled, bukan google_fonts) | Offline penuh sejak first launch |
| Backup | Enkripsi AES-256 → file `.ktkbackup` | Restore = dekripsi + validasi + transaksi tunggal |
| Testing | `flutter_test` + drift in-memory DB | Unit test logika inti + widget test layar |

Library ditambahkan bertahap per fase — apa pun yang masuk wajib lulus aturan **zero-network** (lihat di bawah).

---

## 🏛 Arsitektur

MVVM + Repository, feature-first (SRS §1.2). UI tidak pernah menyentuh database langsung:

```
lib/
├── main.dart              # Entry + ProviderScope + fase app (splash → main)
├── app/
│   ├── app_shell.dart     # Bottom nav 4 tab, routing state-based
│   └── theme/             # ThemeData global
├── core/
│   ├── design/            # AppT tokens — mirror design.md (TANPA hex hardcoded di widget)
│   ├── widgets/           # Komponen lintas-fitur (ClockMascot, dst.)
│   ├── utils/             # days_since & helper tanggal (Fase 1)
│   └── db/                # Drift: AppDatabase, tabel, migrasi (Fase 1)
├── data/
│   ├── models/            # Activity, Log, Category, UserProfile
│   ├── repositories/      # Akses data + business rules
│   └── services/          # NotificationService, BackupService, IapService
└── features/              # splash/ · onboarding/ · home/ · activity_detail/
    └── <feature>/         #   activity_form/ · insight/ · profile/ · settings/
        ├── screens/       #   screens/ · widgets/ · viewmodels/
```

**Alur informasi:** `docs/` (PRD & SRS, requirement) → `DESIGN.md` (tampilan & rasa) → `lib/` (implementasi).

---

## 🚀 Memulai

### Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.13.2` (`flutter --version` untuk cek)
- Emulator/device Android (API 26+) atau iOS 15+ (Mac + Xcode untuk build iOS)

### Menjalankan

```bash
git clone https://github.com/KrisAdw/kapan-terakhir-kali-apps.git
cd kapan-terakhir-kali-apps
flutter pub get
flutter run
```

### Perintah yang dipakai proyek ini

```bash
flutter analyze   # wajib: 0 issues sebelum merge
flutter test      # wajib: semua test hijau
dart format .     # format sebelum commit
```

---

## 🎨 Desain

Desain sistem lengkap ada di [`DESIGN.md`](DESIGN.md): palet cream/ink + aksen, neo-brutalism (border 2.5px, hard shadow blur=0), tipografi Caveat/DM Sans, animasi ≤ 300ms, dan tabel microcopy kasual Indonesia.

Aturan non-negotiable saat menulis UI:

- Semua warna/border/shadow/radius lewat token `AppT` (`lib/core/design/app_tokens.dart`) — **tanpa hardcoded hex di widget**
- Warna penghitung hari: `0 hari` hijau · `1–7` biru · `8–30` oranye · `>30` merah
- Kategori **Kesehatan** wajib mengunci tone pengingat ke `SUPORTIF` (safety-critical)

---

## 📖 Dokumentasi

| Dokumen | Isi |
|---|---|
| [`DESIGN.md`](DESIGN.md) | Design system & microcopy (di dalam repo ini) |
| [`docs/PROGRESS.md`](docs/PROGRESS.md) | **Log progres & perubahan — wajib diperbarui setiap perubahan kode** |
| `docs/KTK - PRD.md` / `docs/KTK - SRS.md` *(di workspace root)* | Requirement, skema DB, arsitektur, edge cases |
| `docs/KTK - Development Plan.md` *(di workspace root)* | Roadmap fase + keputusan stack |

### Aturan main kontribusi (ringkas)

1. **Offline-first, zero network** — tidak ada HTTP call, analytics, crash reporting, remote config. Apa pun.
2. **Privasi** — data tidak pernah keluar device kecuali ekspor `.ktkbackup` yang diinisiasi user.
3. **UI copy bahasa Indonesia kasual** sesuai tabel microcopy di `DESIGN.md` §12.
4. Setiap perubahan dicatat di [`docs/PROGRESS.md`](docs/PROGRESS.md) — perubahan tanpa entri log dianggap belum selesai.
5. Definition of done: `flutter analyze` 0 issues · `flutter test` hijau · UI sesuai token · log terisi.

---

## 📄 Lisensi

Belum ditentukan. Selama belum ada file `LICENSE`, seluruh kode dianggap proprietary © Kris Adiwinata.
