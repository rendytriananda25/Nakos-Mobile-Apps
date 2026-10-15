# Technical Architecture Specification: KostSaver Mobile

**Architectural Paradigm:** Feature-First Clean Architecture  
**State Management:** BLoC / Cubit (flutter_bloc 9.x / Event-Driven State Pattern)  
**Persistence Pattern:** Local-First Storage with Asynchronous Google Drive Sync (`appDataFolder`)  
**Target Platform:** Flutter 3.x+ (Zero-Cost Serverless, 60–120 FPS Target)  

---

## 1. Architectural Principles & Tenets

Dokumen ini adalah acuan mutlak bagi AI Agent (Antigravity) dan Human Developer. Setiap baris kode yang dibuat wajib mematuhi 4 prinsip fundamental ini:

1. **Strict Dependency Hierarchy (Top-Down Only):**
   * `core/design_system` adalah kasta terbawah. Tidak boleh mengimpor layer domain atau model bisnis dari `features/`.
   * Layer `domain` berdiri independen (Pure Dart). Tidak boleh mengimpor Flutter UI (`material.dart`) ataupun layer `data`.
   * Layer `presentation` mengonsumsi data via BLoC / Cubit, tidak boleh memanggil database atau HTTP service secara langsung.

2. **Offline-First & Zero Latency:**
   * Seluruh pembacaan dan penulisan transaksi harus selesai dalam waktu $0\text{ ms}$ di local cache (disk lokal perangkat).
   * Sinkronisasi ke Google Drive `appDataFolder` dieksekusi secara asinkron di background thread tanpa memblokir UI thread.

3. **Rebuild Isolation (Anti-Jank 120 FPS):**
   * Dilarang melakukan komputasi berulang atau *string formatting* berat di dalam method `build()`.
   * Gunakan `BlocSelector`, `context.select`, atau parameter `buildWhen` pada `BlocBuilder` agar widget hanya me-rebuild properti yang benar-benar berubah.

4. **Zero-Server Infrastructure (Rp 0 Cost):**
   * Dilarang menambahkan dependency Firebase Firestore, Supabase, AWS RDS, atau database cloud berbayar.
   * Penyimpanan permanen memanfaatkan akun Google pribadi pengguna via Google Drive API.

---

## 2. Definitive Directory Structure

Struktur folder mengusung pola **Feature-First Clean Architecture** dengan isolasi modul Design System yang terstandarisasi:

```text
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart          # Nilai statis global (App name, version, default keys)
│   │   └── asset_paths.dart            # Path string SVG, icon, dan asset lokal
│   ├── design_system/
│   │   ├── tokens/
│   │   │   ├── app_colors.dart         # Palet warna primer Oat (#F8F6F0) & Sage Green (#587E60)
│   │   │   ├── app_typography.dart     # Plus Jakarta Sans styling & dynamic font scales
│   │   │   ├── app_spacing.dart        # 8-point grid scale tokens (xs: 4, sm: 8, md: 16, lg: 24...)
│   │   │   └── app_radii.dart          # Corner radius tokens (8, 12, 16, 24, full)
│   │   ├── components/
│   │   │   ├── buttons/                # BaseButton, SecondaryGhostButton, PrimaryFAB
│   │   │   ├── inputs/                 # CurrencyInputFormatter, CleanTextField
│   │   │   ├── cards/                  # OatSurfaceCard, HighlightContainer
│   │   │   └── indicators/             # StatusChip, NegativeWarningBanner
│   │   └── theme/
│   │       ├── app_theme.dart          # ThemeData configurator (Light mode focus)
│   │       └── app_color_scheme.dart   # ThemeExtension untuk integrasi warna custom
│   ├── services/
│   │   ├── google_drive/
│   │   │   ├── google_drive_auth.dart  # Google Sign-In instance & credential scopes
│   │   │   └── google_drive_sync.dart  # AppDataFolder read/write/backup engine
│   │   └── local_storage/
│   │       └── local_storage_service.dart # I/O handler file JSON terisolasi di disk lokal
│   ├── utils/
│   │   ├── currency_formatter.dart     # Formatter IDR (Rupiah) tanpa string allocation berlebih
│   │   ├── date_time_helpers.dart      # Sisa hari dalam bulan, timestamp parsers
│   │   └── ui_helpers.dart             # Keyboard dismissal, context extension shortcuts
│   └── errors/
│       ├── failures.dart               # Failure object contract (SyncFailure, ValidationFailure)
│       └── exceptions.dart             # Local exceptions mapping
│
├── features/
│   ├── budget_allocation/              # Modul alokasi gaji bulanan & pengeluaran wajib
│   │   ├── data/
│   │   │   ├── models/                 # BudgetConfigDto, MandatoryExpenseDto (JSON serializable)
│   │   │   └── repositories/           # BudgetRepositoryImpl (baca/tulis disk lokal)
│   │   ├── domain/
│   │   │   ├── entities/               # BudgetEntity, MandatoryExpenseItem (Immutable Dart)
│   │   │   ├── repositories/           # IBudgetRepository (Abstract interface)
│   │   │   └── usecases/               # CalculateSurvivalBudgetUseCase, ValidateAllocationUseCase
│   │   └── presentation/
│   │       ├── screens/                # BudgetSetupScreen
│   │       ├── widgets/                # MandatoryItemRow, RealtimeSurvivalSummaryBar
│   │       └── bloc/                   # BudgetAllocationBloc, Event, State
│   │
│   ├── dashboard/                      # Modul tampilan utama (ringkasan & status saldo)
│   │   ├── domain/
│   │   │   └── entities/               # DashboardSummaryEntity
│   │   └── presentation/
│   │       ├── screens/                # DashboardHomeScreen
│   │       ├── widgets/                # HeroBalanceCard, DualSummaryRow, QuickActionArea
│   │       └── bloc/                   # DashboardBloc, Event, State (selectors isolated)
│   │
│   ├── expense_logging/                # Modul pencatatan transaksi pengeluaran kilat
│   │   ├── data/
│   │   │   ├── models/                 # TransactionDto
│   │   │   └── repositories/           # ExpenseRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/               # TransactionEntity, ExpenseCategory enum
│   │   │   └── repositories/           # IExpenseRepository
│   │   └── presentation/
│   │       ├── screens/                # QuickExpenseModalBottomSheet
│   │       ├── widgets/                # CategorySelectorPill, LiveHistorySliverList, HistoryTile
│   │       └── bloc/                   # ExpenseBloc, Event, State
│   │
│   └── cloud_sync/                     # Modul orkestrasi backup & conflict resolution
│       ├── data/
│       │   └── repositories/           # SyncRepositoryImpl
│       ├── domain/
│       │   ├── entities/               # SyncStatusEntity, SyncConflictPolicy
│       │   └── usecases/               # SyncWithDriveUseCase, ResolveConflictUseCase
│       └── presentation/
│           ├── widgets/                # CloudStatusBadge (Syncing, Synced, Offline)
│           └── bloc/                   # SyncBloc, Event, State
│
└── main.dart                           # Entry point: initialize local storage, MultiRepositoryProvider, MultiBlocProvider
```

---

## 3. Data Flow & Zero-Cost Cloud Pipeline

Operasi data mengikuti alur **Unidirectional Data Flow** dengan garansi ketiadaan latency di layar UI:

```
+---------------------------------------------------------------------------------+
|                               PRESENTATION LAYER                                |
|  User Input (Nominal Warteg) ----> ExpenseBloc (AddExpenseEvent) ----> UI State |
+---------------------------------------+-----------------------------------------+
                                        | (Invoke Command via UseCase)
                                        v
+---------------------------------------------------------------------------------+
|                                  DOMAIN LAYER                                   |
|                  RecordExpenseUseCase (Validasi Nominal & Saldo)                |
+---------------------------------------+-----------------------------------------+
                                        | (Call Interface)
                                        v
+---------------------------------------------------------------------------------+
|                                   DATA LAYER                                    |
|  1. Simpan payload ke Local Storage: `kost_finance_local.json` (Latency: <5ms)  |
|  2. Dispatch trigger event asinkron ke SyncBloc                                 |
+---------------------------------------+-----------------------------------------+
                                        | (Background Job non-blocking)
                                        v
+---------------------------------------------------------------------------------+
|                             GOOGLE DRIVE APPDATA                                |
|  - Cek konektivitas internet                                                    |
|  - Compare `lastModifiedTimestamp`                                              |
|  - Update file `kost_finance_backup.json` di cloud partition pribadi user       |
+---------------------------------------------------------------------------------+
```

### 3.1 Skema Payload JSON Terpadu (`kost_finance_backup.json`)

Data lokal dan file backup Google Drive menggunakan skema terpusat berikut:

```json
{
  "schemaVersion": 1,
  "lastModifiedTimestamp": "2026-10-03T09:10:00.000Z",
  "budgetConfig": {
    "monthlyIncome": 3000000.0,
    "savingsTarget": 300000.0,
    "cycleStartDay": 1,
    "mandatoryExpenses": [
      {
        "id": "mand_01",
        "title": "Kosan Bulanan",
        "amount": 900000.0,
        "isPaid": true
      },
      {
        "id": "mand_02",
        "title": "Token Listrik & Air",
        "amount": 150000.0,
        "isPaid": false
      }
    ]
  },
  "transactions": [
    {
      "id": "tx_101",
      "amount": 18000.0,
      "category": "food",
      "title": "Nasi Padang Bungkus",
      "timestamp": "2026-10-03T06:30:00.000Z"
    }
  ]
}
```

---

## 4. Mathematical Logic & Financial Formulas

AI Agent wajib menggunakan rumus matematis ini di dalam Domain UseCases tanpa deviasi:

### 4.1 Survival Budget (Uang Dingin Bulanan)
$$\text{Survival Budget} = \text{Monthly Income} - \left( \sum_{i=1}^{n} \text{Mandatory Expense}_i + \text{Savings Target} \right)$$

### 4.2 Jatah Uang Harian (Daily Safe Allowance)
$$\text{Daily Allowance} = \frac{\text{Remaining Survival Budget}}{\text{Remaining Days In Cycle}}$$
*Jika $\text{Remaining Days In Cycle} \le 0$, maka $\text{Remaining Days} = 1$ untuk mencegah operasi division by zero.*

### 4.3 Evaluasi Kondisi Defisit
$$\text{IsDeficit} = \text{Survival Budget} < 0$$
Jika kondisi `IsDeficit == true`:
* Tombol aksi simpan di layar `BudgetSetupScreen` dinonaktifkan (`disabled`).
* Tampilkan indikator visual `AppColors.expense` dan notifikasi peringatan.

---

## 5. Performance Directives for AI Agent Code Generation

Patuhi seluruh checklist ini secara ketat saat meng-generate kode Dart/Flutter:

1. **Pure Presentation Components:**
   * File di dalam `core/design_system/components/` dilarang mengimpor BLoC/Cubit ataupun model bisnis dari `features/`.
   * Komponen hanya boleh menerima parameter primitif (`String`, `double`, `VoidCallback`, `Widget`).

2. **Rebuild Boundary Enforcement:**
   * Jangan me-rebuild seluruh layar/Scaffold jika hanya satu sub-komponen yang membutuhkan data reaktif.
   * Gunakan `BlocSelector` lokal yang membungkus komponen terkecil:
   ```dart
   // REKOMENDASI: Hanya kartu saldo yang re-render saat nilai saldo berubah
   BlocSelector<DashboardBloc, DashboardState, double>(
     selector: (state) => state.currentBalance,
     builder: (context, balance) {
       return HeroBalanceCard(amount: balance);
     },
   )
   ```

3. **Memory Management Lifecycle:**
   * Setiap controller (`TextEditingController`, `ScrollController`) yang diinisialisasi dalam `StatefulWidget` WAJIB dipasangkan dengan method `dispose()` yang melepaskan controller tersebut dari memori.

4. **Scroll Optimization:**
   * Dilarang menggunakan kombinasi `SingleChildScrollView` + `Column` untuk daftar data yang dinamis.
   * Wajib menggunakan `ListView.builder` atau `SliverList` dengan implementasi view recycling.