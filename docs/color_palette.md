# Color Palette Specification: KostSaver (Obsidian & Soft Iris)

**Palette Mood:** Minimalist Dark Fintech, Natural Tones, Non-Aggressive Contrast  
**Design Target:** Dark Theme First (OLED Friendly without Harsh Pixel Smear)  
**Font Pairing:** Plus Jakarta Sans  

---

## 1. Filosofi Palet & Anti-AI-Slop Rules

1. **Bukan Pure Black `#000000`:** Latar belakang menggunakan **Obsidian Tint** (`#0D0E12`) agar tidak menyebabkan *black smearing* saat scrolling di layar AMOLED dan tidak membuat mata cepat lelah.
2. **Ungu Bukan Neon Norak:** Menghindari ungu neon jenuh. Digunakan gradasi **Soft Iris / Muted Amethyst** (`#8B5CF6` dan `#6D5DD3`) yang elegan, tenang, dan berbobot.
3. **Hijau & Merah Organik:** 
   * Pemasukan menggunakan **Eucalyptus Mint** (`#34D399`), bukan hijau stabilo.
   * Pengeluaran menggunakan **Terracotta Coral** (`#F87171`), bukan merah darah menyengat.
4. **Abu-abu Bertingkat (Hierarki Teks & Placeholder):** Memisahkan teks aktif, label sekunder, dan teks contoh (placeholder) secara presisi.

---

## 2. Master Color Tokens

| Token Name | Hex Code | Opacity / Role | Deskripsi Penggunaan |
| :--- | :--- | :--- | :--- |
| `bgCanvas` | `#0D0E12` | 100% | Latar dasar seluruh aplikasi (Deep Obsidian) |
| `surfaceCard` | `#16181F` | 100% | Container kartu utama Bento Grid |
| `surfaceCardElevated`| `#1F222B` | 100% | Floating dock bar, modal bottom sheet |
| `surfaceInteractive` | `#2A2E3A` | 100% | Input field background, pill tidak aktif |
| `borderHairline` | `#262A36` | 100% (or 40% white) | Garis tepi kartu 1px anti-flat |
| `brandPrimary` | `#8B5CF6` | 100% | Aksen utama, icon highlight, active state (Soft Iris) |
| `brandPrimaryMuted`| `#6D5DD3` | 100% | Tombol sekunder, border highlight halus |
| `brandPrimarySurface`| `rgba(139, 92, 246, 0.12)` | 12% | Background badge / chip ungu transparan |
| `textHighContrast` | `#F8F9FA` | 100% | Judul layar, nominal saldo hero (Crisp Off-White) |
| `textSecondary` | `#94A3B8` | 100% | Subjudul, metadata transaksi, label kategori |
| `textPlaceholder` | `#64748B` | 100% | Hint text input, contoh teks dummy ("cth: Nasi Padang") |
| `incomeGreen` | `#34D399` | 100% | Indikator pemasukan, nominal positif, status aman |
| `incomeSurface` | `rgba(52, 211, 153, 0.12)` | 12% | Container badge pemasukan |
| `expenseRed` | `#F87171` | 100% | Indikator pengeluaran, peringatan defisit |
| `expenseSurface` | `rgba(248, 113, 113, 0.12)` | 12% | Container badge pengeluaran |

---

## 3. Penerapan Komponen UI (Bento Architecture)

### 3.1 Hero Balance Card (Bento Saldo Utama)
* **Background:** Linear Gradient halus:
  * Dari: `#1A1A2E` (Deep Midnight Iris)
  * Ke: `#16181F` (Charcoal Slate)
* **Border:** 1px solid `borderHairline` (`#262A36`) dengan aksen sudut atas subtle glow `brandPrimarySurface`.
* **Nominal Saldo:** `textHighContrast` (`#F8F9FA`) font size 30px, Bold 800.
* **Badge Status Hemat:** Background `incomeSurface` dengan teks `incomeGreen` (`#34D399`).

### 3.2 Dual Metric Bento (Pemasukan vs Pengeluaran)
* **Card Pemasukan:**
  * Background: `surfaceCard` (`#16181F`)
  * Label: "Pemasukan" (`textSecondary`)
  * Nominal: `incomeGreen` (`#34D399`)
* **Card Pengeluaran:**
  * Background: `surfaceCard` (`#16181F`)
  * Label: "Pengeluaran" (`textSecondary`)
  * Nominal: `expenseRed` (`#F87171`)

### 3.3 Form Input & Placeholder (Teks Contoh)
* **Container Field:** Background `surfaceInteractive` (`#2A2E3A`).
* **Input Text (Aktif):** `textHighContrast` (`#F8F9FA`).
* **Placeholder / Contoh Teks:** `textPlaceholder` (`#64748B`) — tidak boleh terlalu redup (tetap terbaca) dan tidak boleh terlalu terang (tidak menipu user).
* **Focused Border:** `brandPrimary` (`#8B5CF6`).

---

## 4. Flutter Production Ready Implementation (`app_colors.dart`)

Salin class ini langsung ke `lib/core/design_system/tokens/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Canvases & Surfaces
  static const Color bgCanvas = Color(0xFF0D0E12);
  static const Color surfaceCard = Color(0xFF16181F);
  static const Color surfaceCardElevated = Color(0xFF1F222B);
  static const Color surfaceInteractive = Color(0xFF2A2E3A);
  static const Color borderHairline = Color(0xFF262A36);

  // Brand Iris Purple
  static const Color brandPrimary = Color(0xFF8B5CF6);
  static const Color brandPrimaryMuted = Color(0xFF6D5DD3);
  static const Color brandPrimarySurface = Color(0x1F8B5CF6); // 12% Opacity

  // Text Hierarchies
  static const Color textHighContrast = Color(0xFFF8F9FA);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textPlaceholder = Color(0xFF64748B);

  // Financial Status (Natural Semantic)
  static const Color incomeGreen = Color(0xFF34D399);
  static const Color incomeSurface = Color(0x1F34D399); // 12% Opacity
  static const Color expenseRed = Color(0xFFF87171);
  static const Color expenseSurface = Color(0x1FF87171); // 12% Opacity
}
```