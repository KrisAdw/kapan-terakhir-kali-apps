---
type: Progress Log
project: ktk (Flutter production app)
status: Active
created: 2026-09-09
updated: 2026-09-09
---

# PROGRESS.md — Log Progress & Perubahan `ktk/`

> **Log tunggal** untuk semua perubahan pada production Flutter app (`ktk/`).
>
> **Aturan (wajib):** setiap perubahan atau perkembangan — fitur baru, fix, refactor, update dependensi, keputusan teknis — **WAJIB dicatat di sini**. Satu entri per task/fase, entri terbaru di paling atas. Perubahan tanpa entri log dianggap belum selesai.
>
> Referensi plan: `docs/KTK - Development Plan.md` · Spec: `docs/KTK - SRS.md`, `docs/KTK - PRD.md` · Desain: `KTKMobileApp/design.md`

## Format Entri

```
## [YYYY-MM-DD] — Fase X: judul singkat perubahan
- **Status:** In Progress | Done | Blocked
- **Perubahan:**
  - <poin penting: file/fitur/dependensi yang ditambahkan atau diubah>
- **Keputusan:** <jika ada — keputusan + alasan + referensi dokumen (SRS §7 / PRD §12 bila perlu dicatat juga di sana)>
- **Verifikasi:** `flutter analyze` (n issues) · `flutter test` (n pass / n fail)
```

Aturan singkat:
- Entri terbaru **di atas** entri lama.
- Jika status masih `In Progress`, update entri yang sama (jangan buat entri baru tiap edit kecil); tutup jadi `Done` saat task selesai.
- Jika `Blocked`, tulis penyebab dan apa yang dibutuhkan untuk lanjut.
- Keputusan yang mengubah/menyempurnakan spec juga dicatat di SRS §7 (Change Log) / PRD §12 (Decisions) — log ini bukan pengganti dokumen tersebut.

## Status Fase

Sumber fase: `docs/KTK - Development Plan.md` §2.

| Fase | Nama | Status |
|---|---|---|
| 0 | Foundation & App Shell | ✅ Selesai (2026-09-09) |
| 1 | Data Layer (SQLite) | ✅ Selesai (2026-09-09) |
| 2 | Home: Days-Since & Quick Log | Belum mulai |
| 3 | Detail Activity | Belum mulai |
| 4 | Add/Edit Activity Form | Belum mulai |
| 5 | Local Notifications | Belum mulai |
| 6 | Onboarding & Profile | Belum mulai |
| 7 | Premium: Paywall + IAP | Belum mulai |
| 8 | Backup/Restore + Insight | Belum mulai |
| 9 | Widgets, Polish & Release Prep | Belum mulai |

## Log

## [2026-09-09] — Fase 1: Data Layer (SQLite)
- **Status:** Done
- **Perubahan:**
  - `lib/core/utils/days_since.dart` — kalkulasi selisih hari kalender lokal (SRS §3.1)
  - `lib/core/utils/log_guard.dart` — time-travel guard + copy "mesin waktu" (SRS §6.1)
  - `lib/core/db/app_database.dart` — SQLite via `sqlite3` langsung: skema SRS §4 (activities/logs/categories/user_profiles), indeks `IDX_LOG_*`, FK `ON DELETE CASCADE`, `PRAGMA foreign_keys = ON`, WAL, seed 10 kategori, helper transaksi, konstruktor in-memory untuk test
  - `lib/core/db/standard_categories.dart` — 10 kategori standar (emoji+warna) + konstanta `kHealthCategoryId`
  - `lib/data/models/activity.dart` — `Activity`, `LogEntry`, `Category`, enum `ReminderTone` & `SubscriptionPlan`
  - `lib/data/repositories/activity_repository.dart` — `watchAllActivities` (stream reaktif 250 ms), createActivity, addLog (dengan guard), addLogWithNotes, deleteLog, deleteActivity (cascade), categories
  - `lib/data/di.dart` — FutureProvider database + repository
  - `test/data_layer_test.dart` — 18 test baru (total 23 hijau): days-since, guard, seed kategori, CRUD, cascade delete, pragma FK, stream
- **Keputusan (penting):**
  - **Pivot drift → sqlite3 langsung.** Codegen drift konsisten menghasilkan 0 file `.g.dart` di semua kombinasi yang dicoba (drift 2.34/2.20, build_runner 2.16/2.15/2.4.13, AOT/JIT, folder project bersih di /tmp). Diagnostik menunjukkan analyzer drift sukses (`drift_elements.json` berisi seluruh tabel) namun tahap penulisan output `.part`/`.g.dart` tidak pernah terjadi — bug lingkungan build. Raw `sqlite3` menghapus seluruh kebutuhan codegen; skema, indeks, cascade, dan budget performa SRS tetap terpenuhi 1:1. Tercatat di SRS §7 (v1.2.0) & Development Plan §0.
  - Timestamp disimpan sebagai INTEGER epoch-millis (jam lokal), dikonversi balik saat baca.
  - Stream home memakai re-query terjadwal 250 ms (bukan SQL watch) — cukup untuk budget 500 ms dan skala data MVP; naikkan ke reactive stream bila perlu.
  - Dep dihapus: drift, drift_dev, build_runner. Dep baru: sqlite3, path.
- **Verifikasi:** `flutter analyze` (0 issues) · `flutter test` (23 pass / 0 fail) · `dart format` bersih

## [2026-09-09] — Docs: README.md ditulis ulang untuk repo GitHub
- **Status:** Done
- **Perubahan:**
  - `README.md` scaffold default diganti dokumentasi lengkap: deskripsi produk, tabel fitur vs status fase, tech stack (drift + Riverpod + rencana paket), arsitektur folder, getting started, perintah wajib, ringkasan design rules, dan aturan kontribusi
  - Repo GitHub terhubung: `KrisAdw/kapan-terakhir-kali-apps` (branch `main`)
- **Keputusan:**
  - Tabel status fitur di README sengaja menunjuk status fase (bukan tanggal) agar tidak duplikasi sumber kebenaran — status detail tetap di PROGRESS.md & Development Plan
  - Lisensi dinyatakan proprietary sampai file LICENSE dibuat
- **Verifikasi:** — (docs only)

## [2026-09-09] — Fase 0: Foundation & App Shell
- **Status:** Done
- **Perubahan:**
  - Bundle font lokal `assets/fonts/`: Caveat 400–700 + DM Sans 400–700 (8 TTF, ~1.2 MB) — tanpa fetch runtime
  - `pubspec.yaml`: description resmi KTK, dependensi `flutter_riverpod ^3.0.3` (resolved 3.4.3), registrasi fonts & assets
  - Struktur folder target dibuat: `lib/app/`, `lib/core/design/`, `lib/core/widgets/`, `lib/features/splash/`
  - `lib/core/design/app_tokens.dart`: token desain mirror design.md §2–§8 (`AppT` + `daysSinceColor`)
  - `lib/app/theme/app_theme.dart`: ThemeData global (cream canvas, Caveat/DM Sans, input border ink 2.5px)
  - `lib/core/widgets/clock_mascot.dart`: mascot jam bingung via CustomPaint (design.md §13)
  - `lib/features/splash/splash_screen.dart`: splash 2.3s, fade mulai 1.8s, brand KTK + dot pulse (0.2s offset/dot)
  - `lib/app/app_shell.dart`: bottom nav 4 tab (Beranda · Insight · Profil · Pengaturan) + indikator aktif kuning, routing state-based
  - `lib/main.dart`: ProviderScope + AppTheme + state machine fase `splash → main` (onboarding menyusul Fase 6)
  - `test/widget_test.dart`: test counter bawaan diganti (tokens, mascot, splash timing, navigasi 4 tab)
- **Keputusan:**
  - Font di-*bundle* lokal alih-alih package `google_fonts` → offline penuh sejak first launch, selaras hard rule zero-network (AGENT.md §6.1)
  - Dot pulse splash memakai `AnimationController` repeat (durasi 1.2s) sesuai spek dotPulse design.md §8
  - Ikon bottom nav sementara memakai Material rounded (visual mirip Phosphor); ganti ke Phosphor-style saat diputuskan (asset/package) di fase UI berikutnya
- **Verifikasi:** `flutter analyze` (0 issues) · `flutter test` (5 pass / 0 fail) · `dart format` bersih

## [2026-09-09] — Setup: Log progres dibuat
- **Status:** Done
- **Perubahan:**
  - Membuat `ktk/docs/PROGRESS.md` sebagai log tunggal perubahan repo `ktk/`
  - Kondisi awal repo: scaffold Flutter default (counter app), versi `1.0.0+1`, dependensi hanya `cupertino_icons`
- **Keputusan:** Stack terkunci via `docs/KTK - Development Plan.md` — drift (DB) + Riverpod (state MVVM), ditambah `flutter_local_notifications`, `in_app_purchase`, `google_fonts`, `uuid` saat Fase 0 dimulai
- **Verifikasi:** — (belum ada perubahan kode)
