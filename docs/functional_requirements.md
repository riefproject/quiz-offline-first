# Spesifikasi Kebutuhan Sistem: AlpenQuiz

---

## 2. Functional Requirements (FR)

Bagian ini menguraikan spesifikasi kebutuhan fungsional (_Functional Requirements_) sistem sebagai penerjemahan teknis operasional dari _User Requirements_. Penjabaran ini bertindak sebagai landasan rekayasa perangkat lunak.

| Referensi UR | Kode FR | Modul/Fitur | Deskripsi |
| :----------- | :------ | :---------- | :-------- |
| UR-02 | **FR-01** | Autentikasi | Sistem harus mengelola autentikasi registrasi eksklusif bagi calon _Host_ yang mencakup entitas Nama Lengkap, Alamat Surel, Nomor Telepon, dan Kata Sandi. |
| UR-02 | **FR-02** | Autentikasi | Sistem harus melakukan validasi format masukan secara seketika (_real-time_) di sisi klien (_client-side_) sebelum proses transmisi data (HTTP Request) dilakukan. |
| UR-02 | **FR-03** | Autentikasi | Sistem harus menerapkan dan mengevaluasi kebijakan kata sandi tingkat lanjut (minimal 8 karakter, mencakup huruf kapital, huruf kecil, dan angka) dengan umpan balik indikator validasi yang terukur. |
| UR-04 | **FR-04** | Manajemen Kuis | Sistem harus membatasi akses antarmuka manajemen kuis (operasi CRUD) secara ketat hanya kepada entitas pengguna terautentikasi (_registered Host_). |
| UR-04 | **FR-05** | Manajemen Kuis | Sistem harus mengizinkan entitas _Host_ untuk menyertakan komponen multimedia (gambar atau ilustrasi visual) pada setiap butir pertanyaan kuis. |
| UR-04 | **FR-06** | Manajemen Kuis | Sistem harus memfasilitasi pembuatan soal berbasis pilihan ganda (_multiple-choice_) dengan batas penyesuaian dinamis antara 2 (dua) hingga 4 (empat) alternatif jawaban per soal. |
| UR-06 | **FR-07** | Penyiaran (LAN) | Sistem harus memfasilitasi pendistribusian komunikasi jaringan _Local Area Network_ (LAN) berbasis protokol Web Socket/HTTP untuk menyiarkan kuis lokal. |
| UR-01 | **FR-08** | Pengerjaan Kuis | Sistem harus memisahkan penyimpanan _state_ pengerjaan kuis peserta secara luring penuh pada memori internal perangkat klien (_local storage/Hive_). |
| UR-03 | **FR-09** | Pengerjaan Kuis | Sistem harus mengakumulasi dan mempublikasikan kalkulasi skor akhir peserta secara otomatis begitu status pengerjaan kuis diakhiri/dikumpulkan. |
| UR-05 | **FR-10** | Sinkronisasi Luring | Sistem harus menjalankan pemantauan konektivitas laten (_Connectivity Service_) yang bertugas memicu injeksi data secara otomatis (_background synchronization_) ke peladen pusat setelah mendeteksi ketersediaan jaringan internet yang stabil. |
| UR-05 | **FR-11** | Sinkronisasi Luring | Sistem harus mengakomodasi antarmuka eksekusi Sinkronisasi Manual (_force sync_) bagi pengguna untuk menginisiasi pembaruan basis data pusat secara proaktif. |
| UR-05 | **FR-12** | Sinkronisasi Luring | Sistem harus mengkompilasi rekapitulasi data jawaban kuis peserta menjadi format bit biner dan merendernya sebagai representasi visual _QR Code_. |
| UR-05 | **FR-13** | Sinkronisasi Luring | Sistem antarmuka _Host_ harus menyediakan modul pemindai kamera terintegrasi untuk membaca _QR Code_ dari perangkat peserta sebagai jalur transmisi sinkronisasi data sekunder (_air-gapped sync_). |
| UR-07 | **FR-14** | Autentikasi | Sistem harus menyediakan mode akses tamu (_guest mode_) yang memungkinkan pengguna berpartisipasi dalam kuis menggunakan identitas sementara tanpa wajib melewati validasi pendaftaran/masuk (_login_). |
