# KTK — Design System

**Kapan Terakhir Kali...?** · Neo-Brutalism + Handwritten Typography · Indonesian casual personality

---

## 1. Prinsip Desain

| Prinsip | Penjelasan |
|---|---|
| **Bold & Tactile** | Tepi tebal, bayangan keras, elemen terasa "nyata" bisa dipencet |
| **Playful tapi readable** | Typography Caveat memberi karakter, DM Sans menjaga keterbacaan |
| **Warna bicara** | Aksen warna hanya dipakai untuk menyampaikan state, bukan dekorasi |
| **Low friction** | Quick log bisa dilakukan satu tap dari home |
| **Offline-first personality** | Tidak ada akun, tidak ada cloud — terasa seperti buku catatan pribadi |

---

## 2. Warna

### Background & Surface

| Token | Hex | Kegunaan |
|---|---|---|
| `cream` | `#FDF6E3` | Background utama seluruh app |
| `surface` | `#FFFEF7` | Card, sheet, elemen yang "mengambang" di atas cream |
| `#F5EFD4` | — | Panel expand card (lebih gelap dari cream) |
| `#F0EAD0` | — | Bubble notifikasi preview / quote |
| `#EDE8D0` | — | Border divider halus |
| `#E0D5BE` | — | Background wrapper luar phone container |

### Teks

| Token | Hex | Kegunaan |
|---|---|---|
| `ink` | `#1A1A1A` | Teks utama, border, shadow |
| `inkSoft` | `#555555` | Teks sekunder, isi paragraf |
| `#888888` | — | Placeholder, label kecil, metadata |

### Aksen

| Token | Hex | Kegunaan |
|---|---|---|
| `yellow` | `#FFB703` | Primary action, FAB, highlight aktif, CTA utama |
| `green` | `#2DC653` | Sukses, just-logged, "hari ini" |
| `red` | `#E63946` | Danger, delete, aktivitas terlama (neglected) |
| `orange` | `#F2994A` | Warning, bell aktif, aktivitas agak lama (15–30 hari) |
| `blue` | `#2D9CDB` | Info, aktivitas baru (1–7 hari), stat count |

### Warna State pada Days Counter

```
days === 0     → green  (#2DC653)  "Hari ini"
days 1–7       → blue   (#2D9CDB)  "Baru-baru"
days 8–30      → orange (#F2994A)  "Mulai lupa"
days > 30      → red    (#E63946)  "Sudah lama"
```

### Warna Kategori

| Kategori | Emoji | Hex |
|---|---|---|
| Maintenance | 🔧 | `#FB6F3D` |
| Rumah | 🏠 | `#C49A00` |
| Perawatan | 💆 | `#E63946` |
| Kesehatan | 💊 | `#2DC653` |
| Keuangan | 💰 | `#2D6CDB` |
| Digital | 💻 | `#7B61FF` |
| Sosial | 👥 | `#FF6B6B` |
| Admin | 📋 | `#4A4A4A` |
| Kendaraan | 🚗 | `#27AE60` |
| Lainnya | 📌 | `#888888` |

---

## 3. Tipografi

### Font Pair

| Peran | Font | Source |
|---|---|---|
| **Display / Heading** | Caveat | Google Fonts · wght 400–700 |
| **Body / UI** | DM Sans | Google Fonts · opsz 9–40, wght 300–700 |

```css
/* src/index.css */
@import url('https://fonts.googleapis.com/css2?family=Caveat:wght@400;500;600;700&display=swap');
@import url('https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;0,9..40,700;1,9..40,400&display=swap');
```

### Skala Teks

| Nama | Font | Size | Weight | Kegunaan |
|---|---|---|---|---|
| **Hero Number** | Caveat | 96px | 700 | Days-since di DetailScreen |
| **Card Number** | Caveat | 64px | 700 | Days-since di ActivityCard |
| **Display** | Caveat | 42–72px | 700 | Brand "KTK", splash, judul onboarding |
| **Heading** | Caveat | 26–36px | 700 | Header screen, section title |
| **Subheading** | Caveat | 18–22px | 700 | Card name, sheet title |
| **Body** | DM Sans | 13–15px | 400–600 | Deskripsi, label, metadata |
| **Caption** | DM Sans | 10–12px | 600–700 | Label uppercase, badge, timestamp |

### Aturan Typography

- `fontFamily: "'Caveat', cursive"` untuk semua angka besar, nama aktivitas, judul
- `fontFamily: "'DM Sans', sans-serif"` untuk body copy, label form, metadata
- Label kategori dan uppercase label menggunakan `letterSpacing: "0.06–0.14em"` + `textTransform: "uppercase"`
- Nama aktivitas di card: UPPERCASE untuk emphasis cepat saat scanning

---

## 4. Borders, Shadow, Radius

### Border

```
border: "2.5px solid #1A1A1A"   → semua card, button, input utama
border: "2px solid #FDF6E3"     → elemen di atas background gelap (header)
border: "1.5px solid ..."       → elemen sekunder, divider halus
border: "1px solid #C8BC94"     → elemen tersier, inner detail
```

### Shadow (Hard Offset — Neo-Brutalist)

| Token | Value | Kegunaan |
|---|---|---|
| `shadow` | `5px 5px 0px #1A1A1A` | Card utama, CTA button, FAB |
| `shadowSm` | `3px 3px 0px #1A1A1A` | Card kecil, input aktif, secondary button |
| `shadowGreen` | `5px 5px 0px #2DC653` | Card dalam state just-logged |
| `shadowYellow` | `4px 4px 0px #FFB703` | Premium card, KTK Score tile |

> Shadow **tidak pernah** blur (`blur = 0`). Ini aturan keras Neo-Brutalism di app ini.

### Border Radius

| Token | Value | Kegunaan |
|---|---|---|
| `radius` | `12px` | Card utama, button besar, sheet container |
| `radiusSm` | `8px` | Button kecil, input, badge |
| `14px` | — | FAB |
| `20px+` | — | Avatar tile, onboarding step 3 avatar |
| `50%` | — | Timeline dot, toggle pill knob |

---

## 5. Ikonografi

Seluruh UI chrome menggunakan **Phosphor Icons** (`@phosphor-icons/react` v2).

### Ikon UI Chrome

| Fungsi | Ikon Phosphor | Weight |
|---|---|---|
| Navigasi: Beranda | `House` | fill (aktif) / regular |
| Navigasi: Insight | `ChartBar` | fill / regular |
| Navigasi: Profil | `User` | fill / regular |
| Navigasi: Pengaturan | `Gear` | fill / regular |
| Tombol back | `ArrowLeft` | regular |
| Chevron expand card | `CaretDown` | bold |
| Chevron menu row | `CaretRight` | regular |
| FAB tambah aktivitas | `Plus` | bold |
| Cari | `MagnifyingGlass` | regular |
| Clear search | `X` | regular |
| Quick log (idle) | `PushPin` | fill |
| Quick log (logged) | `CheckCircle` | fill |
| Days counter logged | `Check` | bold |
| Pengingat aktif (badge) | `Bell` | fill, warna orange |
| Pengingat mati | `BellSlash` | fill |
| Hapus aktivitas | `Trash` | regular |
| Edit / pensil | `PencilSimple` | regular |
| Lock / premium | `Lock` | regular |
| Premium star | `Star` | fill, warna yellow |
| KTK Score trophy | `Trophy` | fill, warna yellow |
| Log manual | `NotePencil` | regular |
| Tanggal | `CalendarBlank` | regular |
| Ekspor backup | `FloppyDisk` | regular |
| Restore backup | `DownloadSimple` | regular |
| Peringatan restore | `Warning` | fill, warna red |

### Ikon Konten (Emoji)

Emoji dipakai untuk **konten yang dipilih pengguna** — bukan UI chrome:

- **Ikon aktivitas** — dipilih saat Add Activity (🛵 🔧 🏠 💊 dst.)
- **Emoji kategori** — representasi visual tiap kategori
- **Avatar pengguna** — dipilih saat onboarding (🦊 🤖 🌟 dst.)
- **Ekspresi emosional** — 🎉 dalam onboarding done state, tetap sebagai emoji

---

## 6. Spacing & Layout

### Viewport

App disimulasikan sebagai layar HP di dalam container:

```
max-width: 430px
max-height: 932px
overflow: hidden
background: #E0D5BE (wrapper)
```

### Padding Standar

| Konteks | Nilai |
|---|---|
| Header screen | `padding: "16–20px 20px"` |
| Content area | `padding: "16–20px 16px 80–100px"` (80–100px bawah untuk nav) |
| Card | `padding: "14–16px"` |
| Bottom sheet | `padding: "20px 20px 40px"` |
| Filter strip | `padding: "10px 16px"` |

### Grid & Gap

- Activity card list: `display: flex, flexDirection: column, gap: 10–12px`
- Stat row (3 kolom): `display: flex, gap: 10`
- Avatar grid (4 kolom): `display: grid, gridTemplateColumns: repeat(4, 1fr), gap: 8px`
- Icon options (5 kolom): `display: grid, gridTemplateColumns: repeat(5, 1fr), gap: 8px`

---

## 7. Komponen

### ActivityCard

States: normal · expanded · just-logged · reminder-active

```
Normal (collapsed):
  - Nama aktivitas (Caveat 19px UPPERCASE)
  - Kategori label + emoji (11px, warna kategori)
  - Days number (Caveat 64px, warna state)
  - Label "HARI LALU / HARI INI / KEMARIN"
  - Quick log button (54×54px, yellow/green)

Expanded:
  - Tanggal terakhir + rata-rata interval
  - Tombol "Log Manual" (cream) + "Detail →" (ink)
  - Panel background: #F5EFD4
```

Just-logged animation:
- Background card: cream → `#F0FFF4`
- Shadow: ink → green
- Days number: angka → `<Check />` (Phosphor bold)
- Quick log button: yellow → green, `PushPin` → `CheckCircle`
- Label: "HARI LALU" → "Dicatat. Aman."
- Transisi: `transition: "all 0.25s ease"`

### Bottom Sheet

```
Overlay: rgba(0,0,0,0.55)
Container:
  - position: absolute, bottom: 0
  - border-radius: 22px 22px 0 0
  - border: 2.5px solid #1A1A1A, borderBottom: none
  - background: cream
  - animation: sheet-enter (slideUp 0.28s cubic-bezier)
  - zIndex: 21

Handle:
  width: 44px, height: 5px, background: #1A1A1A, opacity: 0.3, border-radius: 3px
```

### Bottom Navigation

```
height: 64px
border-top: 2.5px solid #1A1A1A
background: cream
4 tab: Beranda · Insight · Profil · Pengaturan

Active indicator:
  position: absolute, top: -2px
  width: 24px, height: 3px
  background: yellow
  border: 1px solid ink (kecuali atas)
  border-radius: 0 0 3px 3px

Icon weight: fill (aktif) · regular (non-aktif)
Label: 10px DM Sans uppercase, bold jika aktif
```

### FAB (Floating Action Button)

```
width: 56px, height: 56px
border-radius: 14px
background: yellow
border: 2.5px solid ink
box-shadow: 5px 5px 0px ink
icon: Plus (Phosphor, bold, size 28)
position: absolute, right: 20px, bottom: 74px
z-index: 10
```

### Form Input

```
border: 2.5px solid #1A1A1A
border-radius: 10px
background: surface (#FFFEF7)
padding: 13–14px 16px
font: Caveat 20–26px (input teks panjang) / DM Sans 14–15px (input pendek)
box-shadow: shadowSm saat aktif
outline: none
```

### Chip / Category Filter

```
Normal:   background cream, border 1.5px ink, opacity rendah
Active:   background ink, border ink, color cream
Padding:  6–8px 12–16px
Border-radius: 20px (pill shape untuk filter)
Font: DM Sans 12–13px, weight 600
```

### Toggle Switch (Notifikasi)

```
width: 52px, height: 28px
border-radius: 14px (pill)
border: 2.5px solid ink
Active:   background green
Inactive: background #C8C0A0
Knob: 20×20px, border-radius 50%, background cream, border 2px ink
Transition: left 0.2s ease (knob position)
```

---

## 8. Animasi & Transisi

Semua keyframe didefinisikan di `src/index.css`.

```css
@keyframes slideUp    /* bottom sheet entrance */
  from: translateY(100%) opacity(0)
  to:   translateY(0)    opacity(1)
  duration: 0.28s, cubic-bezier(0.25, 0.46, 0.45, 0.94)

@keyframes slideDown  /* expanded card panel */
  from: translateY(-8px) opacity(0)
  to:   translateY(0)    opacity(1)
  duration: 0.2s, ease

@keyframes fadeIn     /* screen/step transition */
  from: translateY(4px) opacity(0)
  to:   translateY(0)   opacity(1)
  duration: 0.3s, ease

@keyframes dotPulse   /* splash loading dots */
  0%,100%: scale(0.8) opacity(0.3)
  50%:     scale(1.2) opacity(1)
  duration: 1.2s, ease-in-out, infinite (offset per dot: 0s / 0.2s / 0.4s)

@keyframes spin       /* backup generating spinner */
  from: rotate(0deg)
  to:   rotate(360deg)
```

### CSS Classes

```css
.sheet-enter  → animasi slideUp untuk semua bottom sheet
.card-expand  → animasi slideDown untuk panel expanded activity card
.fade-in      → animasi fadeIn untuk screen/step onboarding
```

### Aturan Animasi

- **Tidak ada** animasi dekoratif yang memakan waktu > 300ms
- State change (just-logged) menggunakan `transition: "all 0.2–0.3s ease"` inline
- Shadow compress saat tombol aktif: `transform: translate(2–3px, 2–3px)` + shadow lebih kecil
- Chevron expand: `transform: rotate(180deg)` via CSS transition

---

## 9. Screens & Navigasi

### App Lifecycle

```
AppPhase: "splash" → "onboarding" → "main"

Splash:     2.3 detik, fade out mulai 1.8s
            → Jika ada profile di localStorage: langsung "main"
            → Jika belum: "onboarding"
```

### Navigasi Utama (Bottom Nav)

```
home → HomeScreen
insight → InsightScreen
profile → ProfileScreen
settings → SettingsScreen
```

### Stack Screen (tanpa Bottom Nav)

```
detail → DetailScreen (dari ActivityCard)
notifikasi → NotifikasiScreen (dari Settings)
```

### Bottom Sheets (overlay)

```
AddActivitySheet     → FAB di HomeScreen
QuickUpdateSheet     → "Log Manual" di expanded card
PremiumSheet         → berbagai titik di app
EksporBackupSheet    → Settings
RestoreBackupSheet   → Settings
EditProfileSheet     → ProfileScreen
```

### Routing

State-based routing (tidak menggunakan react-router). Semua state dikelola di komponen `App`:

```tsx
type Screen = "home" | "detail" | "settings" | "insight" | "notifikasi" | "profile"
type AppPhase = "splash" | "onboarding" | "main"
```

---

## 10. Data Model

```typescript
interface Activity {
  id: string
  name: string
  category: CategoryId       // 10 kategori standar
  icon: string               // emoji yang dipilih user
  is_reminder_active: boolean
  reminder_interval?: number // hari
  reminder_tone?: ReminderTone // "SANTAI" | "SARCASTIC" | "SUPORTIF"
  created_at: Date
  logs: Log[]                // diurutkan desc (terbaru dulu)
}

interface Log {
  id: string
  activity_id: string
  logged_at: Date
  notes?: string             // Premium only
}

interface UserProfile {
  name: string
  avatar: string             // emoji
  joinedAt: string           // ISO string
}

type ReminderTone = "SANTAI" | "SARCASTIC" | "SUPORTIF"
```

**Persistensi:** Profile disimpan di `localStorage` dengan key `ktk_profile`. Activities saat ini hanya di React state (belum persisten).

**Days-since logic:**
```typescript
// Kalkulasi berdasarkan pergantian hari kalender, bukan milidetik mentah
function daysSince(date: Date): number {
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  const logDate = new Date(date.getFullYear(), date.getMonth(), date.getDate())
  return Math.max(0, Math.floor((today - logDate) / 86400000))
}
```

---

## 11. Freemium Gating

| Fitur | Basic | Premium |
|---|---|---|
| Tracking aktivitas | ✓ | ✓ |
| Quick log | ✓ | ✓ |
| Riwayat log terakhir | 5 entri | Tak terbatas |
| Log manual dengan catatan | ✗ | ✓ |
| Pengingat lokal | ✗ | ✓ |
| Export backup | ✓ | ✓ |
| Restore backup | ✓ | ✓ |

**Pricing:** Rp 15.000/bulan · Rp 119.000 lifetime

Paywall ditampilkan sebagai **bottom sheet gelap** (`background: #1A1A1A`), bukan interrupsi modal penuh. Tidak memblokir alur utama.

---

## 12. Personality & Microcopy

Nada bicara: **teman dekat yang sedikit usil tapi helpful.**

| Situasi | Contoh copy |
|---|---|
| Log berhasil | "Dicatat. Aman." |
| Empty state | "Belum ada yang bisa dilupain." |
| Aktivitas lama | "Udah lama juga..." |
| Aktivitas baru dicatat | "Baru aja." |
| Reminder santai | "Halo! Udah N hari nih, waktunya [aktivitas] lagi!" |
| Reminder sarkas | "Woi! Udah N hari [aktivitas] lu belum dilakuin. Emang ga malu?" |
| Reminder suportif | "Yuk semangat! Sudah N hari — kamu bisa lakukan [aktivitas] hari ini!" |
| Time manipulation | "Waduh! Kamu punya mesin waktu ya?" |

**Aturan penting:** Kategori **Kesehatan** wajib menggunakan tone `SUPORTIF`. Pilihan `SARCASTIC` dinonaktifkan untuk aktivitas kesehatan.

---

## 13. KTK Mascot

Jam tangan antropomorfik yang tampak bingung dan mencoba mengingat sesuatu.

- SVG inline di komponen `ClockMascot`
- Ekspresi: alis terangkat, tanda tanya di speech bubble, tetes keringat
- Digunakan di: splash screen, onboarding step 0, empty state
- Tidak mendominasi UI — dipakai hanya di momen illustratif/emosional
- Bukan karakter childish; lebih ke "teman yang lucu dan relatable"

---

## 14. Stack Teknis

| Kategori | Pilihan |
|---|---|
| Framework | React 19 |
| Build tool | Vite 8 |
| Language | TypeScript 5.7 |
| Styling | Inline styles + Tailwind CSS v4 (minimal) |
| Icons | Phosphor Icons (`@phosphor-icons/react` v2) |
| Fonts | Google Fonts (Caveat + DM Sans) |
| Storage | `localStorage` (profile) · React state (activities) |
| Routing | State-based (tidak ada react-router) |
| Backend | Tidak ada — 100% offline |

### Konvensi Styling

Semua desain menggunakan **inline styles** langsung di JSX. Tailwind hanya dipakai untuk layout container global. Token desain terpusat di objek `T`:

```typescript
const T = {
  cream: "#FDF6E3",
  surface: "#FFFEF7",
  ink: "#1A1A1A",
  inkSoft: "#555555",
  yellow: "#FFB703",
  red: "#E63946",
  green: "#2DC653",
  orange: "#F2994A",
  blue: "#2D9CDB",
  border: "2.5px solid #1A1A1A",
  shadow: "5px 5px 0px #1A1A1A",
  shadowSm: "3px 3px 0px #1A1A1A",
  shadowGreen: "5px 5px 0px #2DC653",
  shadowYellow: "4px 4px 0px #FFB703",
  radius: 12,
  radiusSm: 8,
  fontDisplay: "'Caveat', cursive",
  fontBody: "'DM Sans', sans-serif",
}
```

Semua komponen mengacu `T` — tidak ada nilai warna atau shadow hardcoded di luar token ini.
