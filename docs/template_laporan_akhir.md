Laporan Akhir Proyek 4
Pengembangan Aplikasi Quiz Offline First

DAFTAR ISI
DAFTAR ISI	2
BAB I - IDENTITAS & WORKFLOW SISTEM	3
BAB II - ARSITEKTUR KODE & PEMODELAN DATA	4
BAB III -  IMPLEMENTASI NETWORK RESILIENCE	5
BAB IV - LAPORAN PENGUJIAN SISTEM	6
BAB V - MANAJEMEN REPOSITORI & INTEGRASI AI	7


BAB I - IDENTITAS & WORKFLOW SISTEM 
• 1.1 Identitas Tim & Topik: Nama aplikasi, deskripsi singkat masalah nyata yang diselesaikan di kampus/lingkungan sekitar, dan PIC masing-masing fitur. 
• 1.2 Analisis Pengguna (Multi-Role): Penjelasan minimal 2 role pengguna di dalam aplikasi (misal: Admin vs User) beserta hak aksesnya. 
• 1.3 Alur Kerja Sistem (Business Workflow): Diagram aktivitas (Activity Diagram) atau tata urutan proses bisnis utama dari awal hingga akhir, termasuk perubahan status data (misal: Pending -> Approved -> Rejected).

BAB II - ARSITEKTUR KODE & PEMODELAN DATA
2.1 Penerapan Clean Architecture: Penjelasan mengenai struktur folder aplikasi
Flutter kelompok. Tunjukkan bukti pemisahan yang tegas antara layer UI (View) dan
layer Logika (Controller/Service) sesuai prinsip SRP.
• 2.2 Pemodelan Data (Data Modeling): Diagram kelas (Class Diagram) atau
representasi objek Model di Flutter.
• 2.3 Skema Koleksi Cloud (MongoDB Schema): Struktur dokumen JSON yang
digunakan pada MongoDB Atlas beserta relasi antar-entitas datanya.

BAB III -  IMPLEMENTASI NETWORK RESILIENCE
• 3.1 Mekanisme Penyimpanan Lokal (Hive): Penjelasan mengenai data apa saja
yang disimpan di dalam Hive Box saat aplikasi berjalan dalam kondisi Offline (tanpa
internet).
• 3.2 Strategi Sinkronisasi Cloud (Sync Manager): Penjelasan algoritma atau logika
yang digunakan oleh Controller untuk mendeteksi jaringan dan mengunggah data
lokal ke MongoDB Atlas secara otomatis tanpa duplikasi data (conflict resolution).

BAB IV - LAPORAN PENGUJIAN SISTEM
• 4.1 Skenario Unit Testing: Tabel daftar Test Case yang telah dirancang (memuat ID
Test, Nama Fungsi yang Diuji, Jenis Uji: Positive/Negative/Edge Case, dan
Prekondisi).
• 4.2 Dokumentasi Hasil Eksekusi (Test Result): Tangkapan layar (screenshot)
konsol terminal saat perintah flutter test dijalankan yang membuktikan status All
Tests Passed.
• 4.3 Penanganan Bug (Evidence Log): Catatan jika sempat ada skenario uji yang
gagal (Fail) dan bagaimana tindakan perbaikan source code yang dilakukan
kelompok untuk menyelesaikannya

BAB V - MANAJEMEN REPOSITORI & INTEGRASI AI
• 5.1 Git Analytics & Workflow: Tautan repositori GitHub kelompok dan grafik
kontribusi (Commit History) yang menunjukkan distribusi kerja antar-anggota tim.
• 5.2 Log LLM (Transparansi AI): Lampiran daftar prompt krusial yang digunakan
kelompok saat meminta bantuan ChatGPT/Claude, lengkap dengan dokumentasi
Fact Check (analisis koreksi mandiri terhadap saran AI yang keliru) dan Twist
(modifikasi kode hasil AI agar sesuai arsitektur kelompok).

