# Master Instructions & Project Context for Antigravity AI Agent

**Project Identity:** KostSaver — Aplikasi Pengatur Keuangan Anak Kost  
**Tech Stack:** Flutter (Dart 3.x+), BLoC / Cubit (flutter_bloc 9.x), Google Drive API (`appDataFolder`)  
**Deployment Target:** Mobile (Android & iOS)  
**Cost Constraint:** Rp 0 (Strict Zero-Server Infrastructure)  

---

## 1. System Personality & Role for Antigravity

Saat mengimplementasikan kode atau mengusulkan fitur untuk KostSaver, kamu adalah **Senior Flutter Performance Engineer**. 
* **Zero Hallucination:** Jangan pernah menyarankan Firebase, Supabase, AWS RDS, atau backend berbayar lainnya. Pengguna tidak memiliki anggaran untuk server.
* **Performance First:** Selalu prioritaskan rendering 60–120 FPS di perangkat *low-end* (HP kentang).
* **Strict Adherence:** Ikuti spesifikasi desain, token warna, struktur folder, dan business logic yang ada di dokumen ini tanpa deviasi.

---

## 2. Business Logic & Mathematical Formulas

KostSaver bertujuan menghitung uang dingin (*Survival Budget*) pasca alokasi pengeluaran wajib bulanan:

### 2.1 Alokasi Budget Bulanan
$$\text{Survival Budget} = \text{Pemasukan} - \left( \sum \text{Kebutuhan Wajib} + \text{Target Tabungan} \right)$$

$$\text{Jatah Harian} = \frac{\text{Survival Budget}}{\text{Sisa Hari dalam Bulan Ini}}$$

* **Pemasukan:** Gaji bulanan atau uang saku kiriman orang tua.
* **Kebutuhan Wajib (Harga Mati):** Dynamic list pengeluaran tidak bisa ditawar (sewa kos, WiFi, token listrik, galon, cicilan).
* **Target Tabungan (Opsional):** Nominal simpanan awal bulan. Jika kosong, default $= 0$.
* **Edge Case:** Jika $\text{Survival Budget} < 0$, sistem harus mengunci tombol aksi dan menampilkan alert defisit.

---

## 3. Zero-Cost Serverless Architecture (Google Drive AppData)

Aplikasi tidak menggunakan server atau database cloud terpusat.

```
+-----------------------------------------------------------+
|                        FLUTTER UI                         |
|   (Screen, Widgets, Bottom Sheets, Immediate Response)    |
+-----------------------------+-----------------------------+
                              | Read / Write (0ms Latency)
                              v
+-----------------------------------------------------------+
|                     LOCAL CACHE LAYER                     |
|  - In-Memory State via BLoC / Cubit State               |
|  - Persistent Local File: kost_finance_local.json        |
+-----------------------------+-----------------------------+
                              | Background Async Sync
                              v
+-----------------------------------------------------------+
|             GOOGLE DRIVE APPDATA (HIDDEN CLOUD)           |
|  - Scope: drive.DriveApi.driveAppdataScope                |
|  - Target File: kost_finance_backup.json                  |
|  - Zero User Quota Impact / Completely Hidden from UI     |
+-----------------------------------------------------------+
```

### 3.1 Aturan Sinkronisasi Cloud
1. **Offline-First:** Semua operasi CRUD (Create, Read, Update, Delete) diselesaikan di local cache terlebih dahulu. UI tidak boleh menunggu respons HTTP dari Google Drive.
2. **Conflict Resolution Policy (Last-Write-Wins):**
   * Setiap payload menyertakan metadata `lastModifiedTimestamp` (ISO 8601).
   * Saat memulihkan (*restore*), bandingkan timestamp cloud dengan timestamp file lokal. Pilih snapshot paling mutakhir.

---

## 4. Design System & Theme Specs

### 4.1 Color Tokens
```dart
abstract final class AppColors {
  // Canvas & Surfaces
  static const Color background = Color(0xFFF8F6F0);      // Warm Oat Light
  static const Color surface = Color(0xFFFFFFFF);         // Clean Card Surface
  static const Color surfaceMuted = Color(0xFFF0EDE4);    // Muted Oat Container

  // Accents
  static const Color primary = Color(0xFF587E60);         // Deep Sage Green
  static const Color primaryLight = Color(0xFFA8D08D);    // Soft Matcha Green
  static const Color primaryContainer = Color(0xFFE8F2EA);// Tinted Sage Background

  // Typography Colors
  static const Color textPrimary = Color(0xFF1E2320);     // Deep Slate
  static const Color textSecondary = Color(0xFF6E736B);   // Olive Grey
  static const Color textDisabled = Color(0xFFA5AAA2);    // Disabled / Placeholders

  // Semantic
  static const Color income = Color(0xFF3B7A57);          // Green Amount
  static const Color expense = Color(0xFFC65D47);         // Terracotta Red Amount
  static const Color border = Color(0xFFE5E0D5);          // Subtle Outline
}
```

### 4.2 Typography & Sizing
* **Font Family:** `Plus Jakarta Sans` via Google Fonts.
* **Corner Radius:**
  * Hero Balance Card: `24px`
  * Dual Summary Card: `16px`
  * Transaction Tile & Input Field: `12px`
  * Floating Action Button (FAB): `18px`
* **Elevation:** Maksimal blur `16px`, opacity `0.04 - 0.06`. Dilarang menggunakan shadow hitam pekat default Material 2.

---

## 5. Clean Architecture Directory Structure

Wajib mengikuti struktur **Feature-First**:

```
lib/
├── core/
│   ├── constants/             # AppColors, AppSpacing, Asset paths
│   ├── services/
│   │   └── google_drive_service.dart # Auth & AppData sync implementation
│   ├── theme/                 # ThemeData with Plus Jakarta Sans
│   └── utils/                 # Currency formatters, Date helpers
├── features/
│   ├── budget_allocation/     # Form alokasi gaji & kebutuhan wajib
│   │   ├── domain/            # BudgetModel, ExpenseItem entity
│   │   ├── presentation/      # BudgetSetupScreen, live survival calculator
│   │   └── bloc/              # BudgetAllocationBloc for allocation logic
│   ├── dashboard/             # Screen saldo utama & visual ringkasan
│   │   ├── presentation/      # HomeScreen, HeroBalanceCard, DualSummaryCard
│   │   └── bloc/              # DashboardBloc (isolated selectors)
│   └── expense_logging/       # Pencatatan transaksi kilat
│       ├── domain/            # TransactionModel, Category enum
│       ├── presentation/      # QuickExpenseBottomSheet, TransactionTile
│       └── bloc/              # ExpenseBloc
│   └── cloud_sync/            # Backup & sync orchestrator
│       └── bloc/              # SyncBloc
└── main.dart                  # MultiRepositoryProvider & MultiBlocProvider
```

---

## 6. Strict Performance & Engineering Directives

Saat Antigravity meng-generate kode, patuhi checklist berikut:

1. **`const` Constructor:** Gunakan `const` di semua widget immutable tanpa terkecuali.
2. **Rebuild Isolation:**
   * Jangan membungkus seluruh `Scaffold` dengan listener reaktif.
   * Gunakan `BlocSelector<Bloc, State, Property>` atau parameter `buildWhen` untuk mencegah render yang tidak diperlukan.
   * Untuk input kalkulasi realtime (seperti form alokasi), gunakan `ValueNotifier` atau local listener, BUKAN `setState()` di root widget.
3. **Clean Controller Lifecycle:**
   * Setiap `TextEditingController` atau listener WAJIB di-dispose di dalam method `dispose()`.
4. **List Rendering:**
   * Dilarang menggunakan `Column` di dalam `SingleChildScrollView` untuk menampilkan riwayat transaksi yang dinamis. Gunakan `SliverList` atau `ListView.builder`.
5. **No Logic in UI Widgets:**
   * Parsing nominal, pemformatan string IDR, atau validasi matematika harus berada di dalam domain models atau utility helpers, bukan di callback `onPressed`.