# Product Requirement Document (PRD)
## Project: Anak Kost Financial Tracker ("KostSaver")
**Status:** Draft / Active MVP  
**Target Release:** v1.0.0-MVP  
**Author / Tech Lead:** Mentor Flutter & Muridnya  

---

## 1. Executive Summary & Problem Statement
Sebagian besar aplikasi pencatat keuangan di pasar terlalu rumit: kebanyakan input form, kategori berbelit-belit, dan tidak memahami psikologi anak kos yang cuma butuh tahu dua hal:
1. Berapa duit yang **bener-bener aman** dibelanjain hari ini sampai tanggal gajian/kiriman berikutnya?
2. Tagihan wajib (kosan, WiFi, galon, cicilan) udah aman atau bakal bikin diusir bapak kos?

**KostSaver** dirancang sebagai aplikasi pelacak keuangan ultra-ringan dengan fokus pada kalkulasi otomatis **"Survival Budget"** pasca alokasi pengeluaran wajib, eksekusi pencatatan secepat kilat (<3 detik per transaksi), dan tampilan visual yang menenangkan (Oat & Sage Green).

---

## 2. Target Persona
* **Nama Persona:** Farhan (21 tahun, Mahasiswa Rantau / Junior Worker)
* **Karakteristik:**
  * Pemasukan bulanan fixed (kiriman ortu tiap tanggal 1 atau gaji UMR tiap tanggal 25).
  * Sering kalap di minggu pertama, menderita makan mie instan di minggu terakhir.
  * Malas mencatat pengeluaran jika harus mengisi form lebih dari 3 input.
  * Menggunakan smartphone kelas menengah (*mid-to-low tier*), benci aplikasi yang lag dan boros baterai.

---

## 3. Scope & Core Features (MVP)

### 3.1 Feature 1: Setup Alokasi Bulanan (Budget Allocation)
* **Deskripsi:** Form konfigurasi awal di awal siklus bulan untuk mengunci uang dingin.
* **Komponen Input:**
  * **Pemasukan Utama:** Nominal gaji / kiriman ortu (Single positive numeric).
  * **Kebutuhan Wajib (Harga Mati):** Dynamic list pengeluaran tidak bisa diganggu gugat (Sewa Kos, Listrik, WiFi, Galon, Kasbon). User bisa menambah/menghapus baris item.
  * **Target Tabungan (Opsional):** Nominal dana yang disisihkan sebelum sisa budget dibagi.
* **Output / Business Logic:**
  $$\text{Survival Budget} = \text{Pemasukan} - (\sum \text{Kebutuhan Wajib} + \text{Target Tabungan})$$
  $$\text{Jatah Harian} = \frac{\text{Survival Budget}}{\text{Sisa Hari dalam Bulan Ini}}$$
* **Validasi:** Tombol simpan terkunci jika total kewajiban melebihi pemasukan (kondisi defisit / minus).

### 3.2 Feature 2: Dashboard Saldo & Status Keuangan
* **Container Saldo Utama:** Menampilkan sisa Survival Budget dengan chip status kesehatan finansial (e.g., *"Aman sampai tgl 28"*, *"Mode Darurat: Makan Warteg Only"*).
* **Dual Summary Container:**
  * Container Kiri: Total Pemasukan tercatat.
  * Container Kanan: Total Pengeluaran akumulatif.
* **Live History Feed:** Menampilkan 10 transaksi pengeluaran terakhir secara lazy-loaded.

### 3.3 Feature 3: Quick Expense Logging (FAB Action)
* **Deskripsi:** Bottom sheet modal cepat saat tombol FAB pojok kanan bawah ditekan.
* **Input Minimal:**
  * Input nominal (auto-focus ke numeric keypad).
  * Quick-select kategori (Makan, Jajan, Transport, Darurat).
  * Note singkat opsional.
* **Behavior:** Transaksi tersimpan < 3 detik, saldo dashboard langsung ter-update secara reaktif.

---

## 4. Non-Functional Requirements (Performance & UX)
| Metrik | Target Standar |
| :--- | :--- |
| **Cold Startup Time** | $< 1.2$ detik pada perangkat Android entry-level |
| **Frame Rate** | Stabil 60 FPS (Zero jank pada scroll list transaksi) |
| **App Size** | $< 15$ MB (Release APK) |
| **Offline Capability** | 100% fungsional offline tanpa koneksi internet (Local-First DB) |

---

## 5. Success Metrics (KPI)
1. **Time-to-Log:** Rata-rata waktu pencatatan pengeluaran di bawah 4 detik dari aplikasi dibuka.
2. **Retention Day-7:** $> 45\%$ user aktif mencatat pengeluaran rutin harian.
3. **Crash Rate:** $0.00\%$ crash-free sessions.