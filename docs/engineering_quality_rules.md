# Engineering, Performance & Coding Rules
**Enforcement Level:** Strict (Semua PR yang melanggar langsung ditolak)  
**Standard:** Flutter Performance-First & Zero-Jank Policy  

---

## 1. Zero-Jank Rendering Rules (HP Kentang Protection)

1. **`const` Constructor is Non-Negotiable:**
   Semua widget statis WAJIB menggunakan `const`. Jika analyzer mendeteksi widget tanpa `const` yang seharusnya bisa di-const, build CI/CD otomatis gagal.
2. **Haram Menggunakan Raw `SingleChildScrollView` + `Column` Dinamis:**
   Jika menampilkan data transaksi yang jumlahnya dinamis/bisa bertambah, WAJIB menggunakan `ListView.builder` atau `SliverList` dengan view recycling.
3. **No Expensive Logic in `build()` Method:**
   Method `build()` dilarang melakukan komputasi berat, formatting tanggal yang berulang, atau filter list. Saring dan format data di layer Notifier/Domain sebelum masuk ke widget tree.
4. **Isolated Input Fields:**
   Form input teks dengan dynamic kalkulator tidak boleh memanggil `setState()` di root view. Gunakan `ValueNotifier` terisolasi atau text controller listener scoped lokal.

---

## 2. Memory & Resource Management Rules

1. **Strict Controller Disposal:**
   Semua `TextEditingController`, `AnimationController`, `ScrollController`, dan `StreamSubscription` WAJIB di-dispose di dalam method `dispose()`.
2. **No Image Asset Bloat:**
   Aset vektor harus dalam format SVG terkompresi atau font icons. Gambar bitmap wajib di-resize sesuai display scale (hindari menaruh gambar 4K untuk icon 32x32px).

---

## 3. Clean Code & Architectural Constraints

1. **No Logic in UI:**
   Method `onTap`, `onPressed`, dan event handler tidak boleh memuat kalkulasi matematika atau manipulasi data langsung. Panggil method dari notifier/controller.
2. **Immutable Domain Entities:**
   Semua data class di Domain layer harus *immutable* menggunakan modifier `final` pada semua properties.
3. **Single Responsibility Files:**
   * 1 file widget maksimal 200-250 baris.
   * Jika ada sub-widget private (`_buildCustomItem`) yang panjangnya lebih dari 30 baris, pecah ke dalam file widget terpisah di subfolder `widgets/`.

---

## 4. Git & Commit Guidelines

* **Format Commit:** `[type]: [short imperative explanation]`
  * `feat:` Fitur baru (misal: `feat: implement budget allocation notifier`)
  * `fix:` Perbaikan bug (misal: `fix: negative balance edge case calculation`)
  * `perf:` Optimasi performa render/query
  * `refactor:` Restrukturisasi kode tanpa mengubah fungsionalitas
  * `ui:` Perubahan kosmetik visual sesuai `designsystem.md`
* **Rule:** 1 Branch = 1 Feature. Jangan mencampur logic budget allocation dengan dashboard di satu branch commit.