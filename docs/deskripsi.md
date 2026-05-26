# Deskripsi Sistem

Dokumen ini memberikan uraian fungsional dan struktural mengenai arsitektur sistem AlpenQuiz.

## Gambaran Umum

**AlpenQuiz** merupakan platform aplikasi seluler lintas serambi (_cross-platform_) yang dirancang untuk memfasilitasi pelaksanaan evaluasi interaktif (kuis) pada kondisi infrastruktur jaringan yang minim atau tidak stabil. Sistem ini memprioritaskan ketahanan jaringan (_network resilience_) dengan menggeser mayoritas beban pemrosesan dan penyimpanan data dari peladen pusat ke perangkat klien.

Sistem AlpenQuiz mengklasifikasikan penggunanya ke dalam dua peran utama:
1. **Penyelenggara (Host)**: Pengguna dengan otorisasi administratif untuk merancang paket kuis, menyunting pertanyaan, dan mendistribusikan kuis ke audiens.
2. **Peserta (Participant)**: Pengguna yang berpartisipasi dalam sesi kuis, mengirimkan jawaban, dan menerima kalkulasi evaluasi.

## Modul Fungsional Utama

Infrastruktur sistem AlpenQuiz ditopang oleh empat modul fungsional inti:

### 1. Modul Autentikasi & Keamanan Kredensial
Modul ini mengelola siklus autentikasi masuk dan registrasi akun. Sistem menerapkan protokol validasi format masukan secara ketat di sisi klien (_client-side real-time validation_) sebelum transmisi HTTP dilakukan, guna meminimalisasi beban lalu-lintas jaringan akibat galat pengguna. Seluruh kredensial kata sandi diamankan menggunakan fungsi _hash_ kriptografi standar industri.

### 2. Modul Penyimpanan Data Luring (_Local Persistence_)
Modul ini merupakan inti dari arsitektur _Offline-First_. Alih-alih melakukan pemanggilan API secara berulang untuk memuat pertanyaan kuis, sistem mengunduh seluruh profil dan paket soal ke dalam basis data NoSQL lokal yang terenkripsi di memori internal perangkat. Strategi ini mengeliminasi latensi jaringan pada setiap transisi antarhalaman kuis.

### 3. Modul Manajemen Siklus Sinkronisasi
Modul ini bertanggung jawab atas integritas data saat perangkat mengalami fluktuasi konektivitas. Saat perangkat tidak memiliki akses internet, seluruh rekaman aktivitas pengguna ditempatkan pada antrean data struktural lokal (_queueing_). Ketika modul pemantauan mendeteksi pemulihan koneksi yang stabil, mesin sinkronisasi secara asinkron mendistribusikan antrean tersebut ke peladen _backend_.

### 4. Modul Penyiaran Jaringan Lokal (_LAN Broadcasting_)
Sebagai fitur mitigasi tingkat lanjut untuk lingkungan terisolasi secara digital (_blank spot_), sistem menyediakan protokol komunikasi Web Socket nirkabel lokal. Fitur ini memungkinkan perangkat penyelenggara (_Host_) bertindak secara independen sebagai peladen lokal bagi perangkat lain yang terhubung dalam satu _intranet_ Wi-Fi yang sama tanpa melibatkan transmisi internet eksternal.
