<div align="center">
  <img src="assets/icon/app_icon.png" width="150" alt="AlpenQuiz Logo">
  
  # AlpenQuiz 🏔️
  **The Ultimate Offline-First Quiz Experience**
  
  <i>Bebaskan pengalaman kuis Anda dari hambatan koneksi internet yang lambat.</i>
</div>

---

## 🚀 Apa itu AlpenQuiz?

**AlpenQuiz** adalah platform kuis interaktif modern yang dirancang khusus untuk menghadapi lingkungan dengan konektivitas jaringan yang tidak stabil. 

Sering mengalami jeda saat menjawab soal atau kehilangan data saat sinyal terputus? **AlpenQuiz menyelesaikan masalah tersebut.** Dengan arsitektur berbasis *Offline-First*, seluruh data kuis Anda diproses langsung secara lokal di dalam perangkat. Hasilnya: navigasi yang serba instan, transisi soal tanpa jeda pemuatan (*loading*), dan ketenangan pikiran bahwa tidak ada satu pun progres Anda yang akan hilang.

---

## ✨ Fitur Unggulan

### 📡 Luring Sepenuhnya (True Offline-First)
Tidak ada lagi insiden kegagalan pengiriman jawaban. Seluruh pengerjaan kuis dapat diselesaikan dari awal hingga akhir murni tanpa membutuhkan ketersediaan kuota internet eksternal sama sekali.

### 🔄 Sinkronisasi Cerdas
Sistem akan memantau stabilitas jaringan secara mandiri di latar belakang. Saat perangkat mendeteksi koneksi internet yang memadai, seluruh skor dan jawaban kuis yang tersimpan akan langsung dikirimkan ke peladen pusat secara otomatis.

### 🔐 Autentikasi Cepat & Aman
Layar pendaftaran dirancang dengan sistem validasi instan yang memandu pengguna secara interaktif. Pengalaman mendaftar akun menjadi sangat cepat, lancar, dan terlindungi oleh standar keamanan kriptografi modern.

### 📶 Penyiaran Kuis Lokal (Mode LAN)
Cocok untuk lingkungan ruang kelas atau aula. Seorang penyelenggara (*Host*) dapat memancarkan dan menjalankan kuis secara *real-time* ke puluhan peserta cukup melalui jaringan *Local Area Network* (Wi-Fi lokal) tanpa lalu lintas internet sama sekali.

---

## 👥 Peran Pengguna

Aplikasi ini menyajikan antarmuka khusus yang disesuaikan untuk dua kelompok pengguna:

1. **Host (Penyelenggara):**
   - Memiliki kendali penuh untuk membuat, menyunting, dan menghapus paket soal kuis.
   - Meluncurkan kuis ke peserta dan memantau penerimaan data.

2. **Participant (Peserta):**
   - Berpartisipasi dalam kuis yang tersedia.
   - Menikmati interaksi pengerjaan soal yang super cepat.
   - Melihat kalkulasi skor akhir seketika setelah penyelesaian.

---

## 🛠️ Stack Teknologi Terapan

Bagi pengembang yang tertarik melihat di balik layar, AlpenQuiz mengusung pondasi teknologi berikut:
- **Frontend / Mobile UI:** Flutter
- **Local Database:** Hive
- **Remote Database:** MongoDB
- **Arsitektur:** Pemisahan fungsionalitas berbasis fitur (_Feature-Driven_)

---

## 🏁 Menjalankan Aplikasi

Panduan singkat untuk menjalankan AlpenQuiz di mesin pengembangan Anda:

1. **Kloning Repositori:**
   ```bash
   git clone https://github.com/riefproject/quiz-offline-first.git
   cd quiz-offline-first
   ```

2. **Unduh Dependensi:**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Lingkungan:**
   - Salin dan ubah nama berkas `.env.example` menjadi `.env`.
   - Isi kredensial URL basis data pada berkas tersebut.

4. **Kompilasi & Jalankan:**
   ```bash
   flutter run
   ```
