# Design System Specification ("Oat & Sage Minimal")
**Version:** 1.0.0  
**Design Target:** Flutter Native UI  
**Visual Style:** Japanese Warm Minimalist, High Contrast Legibility, Calming Palette  

---

## 1. Color Palette Tokens

Tema dibangun dengan dominasi warna **Oat** hangat untuk mengurangi kelelahan visual (eye strain) dan aksen **Sage Green** lembut untuk memberikan rasa aman psikologis terhadap saldo uang.

### 1.1 Core Tokens
```dart
abstract final class AppColors {
  // Canvas & Background
  static const Color background = Color(0xFFF8F6F0);      // Warm Oat Canvas
  static const Color surface = Color(0xFFFFFFFF);         // Pure White Card Surface
  static const Color surfaceMuted = Color(0xFFF0EDE4);    // Muted Oat Container

  // Brand / Action Accents
  static const Color primary = Color(0xFF587E60);         // Deep Sage Green (Actionable)
  static const Color primaryDark = Color(0xFF3B5641);     // Forest Sage Pressed
  static const Color primaryLight = Color(0xFFA8D08D);    // Soft Matcha Highlight
  static const Color primaryContainer = Color(0xFFE8F2EA);// Tinted Sage Badge Background

  // Text Hierarchies
  static const Color textPrimary = Color(0xFF1E2320);     // Near Black Slate (Headings)
  static const Color textSecondary = Color(0xFF6E736B);   // Olive Grey (Captions, Subtitles)
  static const Color textDisabled = Color(0xFFA5AAA2);    // Muted Hint Text

  // Semantic & Financial Feedback
  static const Color income = Color(0xFF3B7A57);          // Positive Green
  static const Color expense = Color(0xFFC65D47);         // Terracotta Red (Warning / Minus)
  static const Color border = Color(0xFFE5E0D5);          // Subtle Card Border
}
```

---

## 2. Typography Rules (Plus Jakarta Sans)

Semua teks menggunakan font family `Plus Jakarta Sans`. Menggunakan tracking/letter-spacing proporsional agar angka nominal mudah dipindai secara vertikal.

| Token | Weight | Size | Letter Spacing | Context Usage |
| :--- | :--- | :--- | :--- | :--- |
| `displayBalance` | Bold (700) | 32px | -0.5px | Hero Saldo Terkini di Dashboard |
| `headlineMedium` | SemiBold (600)| 18px | -0.2px | Title Section, Header Layar |
| `titleSmall` | SemiBold (600)| 16px | 0px | Nama Item Transaksi, Sub-judul |
| `bodyMedium` | Medium (500) | 14px | 0px | Form Input Field, Button Text |
| `bodySmall` | Regular (400) | 12px | +0.2px | Subteks Tanggal, Microcopy |
| `labelSmall` | SemiBold (600)| 11px | +0.5px | Chip Status, All-caps category |

---

## 3. Spacing & Shape Tokens

### 3.1 Spacing Scale (8-Point Grid Based)
```dart
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}
```

### 3.2 Border Radii
* **Large Containers (Hero Card):** `24.0` (Super smooth curves)
* **Medium Containers (Secondary Cards, Modal Sheets):** `16.0`
* **Small Elements (Input Fields, Transaction Tiles):** `12.0`
* **Action Buttons (FAB):** `18.0` (Squircle form)

### 3.3 Elevation & Shadows
* **No Harsh Black Shadows!** Selalu gunakan opacity 4% - 6% dengan blur lebar:
```dart
static const BoxShadow subtleElevation = BoxShadow(
  color: Color(0x0F000000), // 6% black
  blurRadius: 16.0,
  offset: Offset(0, 4),
);
```

---

## 4. Core Component Specs

### 4.1 Hero Balance Card
* Padding: `24px` sekeliling.
* Background: `AppColors.surface` dengan border `1px` `AppColors.border`.
* Konten: Label kecil, nominal besar, dan badge status penghematan.

### 4.2 Dual Summary Container
* Tata letak: `Row` dengan `Expanded` rasio 1:1, jarak gap `12px`.
* Background: `AppColors.surfaceMuted`.
* Ikon: Bulat `32x32px` dengan ikon panah diagonal (Hijau untuk Pemasukan, Terracotta untuk Pengeluaran).

### 4.3 Quick Action Floating Action Button (FAB)
* Posisi: `FloatingActionButtonLocation.endFloat`.
* Ukuran: `56x56px` rounded container (`18px` radius).
* Warna: `AppColors.primary` dengan ikon plus putih `24px`.