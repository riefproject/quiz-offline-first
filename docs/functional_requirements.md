# Spesifikasi Kebutuhan Sistem: AlpenQuiz

---

## 2. Functional Requirements (FR)

Bagian ini menguraikan spesifikasi kebutuhan fungsional (_Functional Requirements_) sistem sebagai penerjemahan teknis operasional dari _User Requirements_. Penjabaran ini bertindak sebagai landasan rekayasa perangkat lunak.

| Referensi UR | Kode FR | Deskripsi |
| :----------- | :------ | :-------- |
| UR-02 | **FR-01** | Sistem harus mengelola otentikasi registrasi pengguna yang mencakup entitas Nama Lengkap, Alamat Surel, Nomor Telepon (termasuk standardisasi kode negara), dan Kata Sandi. |
| UR-02 | **FR-02** | Sistem harus melakukan validasi format masukan secara seketika (_real-time_) di sisi klien (_client-side_) sebelum proses transmisi data (HTTP Request) dilakukan. |
| UR-02 | **FR-03** | Sistem harus menerapkan dan mengevaluasi kebijakan kata sandi tingkat lanjut (minimal 8 karakter, mencakup huruf kapital, huruf kecil, dan angka) dengan umpan balik indikator validasi yang terukur. |
| UR-04 | **FR-04** | Sistem harus menyediakan antarmuka terotentikasi bagi entitas _Host_ untuk melakukan operasi CRUD (_Create, Read, Update, Delete_) pada entitas paket kuis dan kumpulan soal pilihan ganda. |
| UR-06 | **FR-05** | Sistem harus memfasilitasi pendistribusian komunikasi jaringan _Local Area Network_ (LAN) berbasis protokol Web Socket/HTTP untuk menyiarkan kuis lokal. |
| UR-01 | **FR-06** | Sistem harus memisahkan penyimpanan _state_ pengerjaan kuis peserta secara luring penuh pada memori internal perangkat klien (_local storage/Hive_). |
| UR-03 | **FR-07** | Sistem harus mengakumulasi dan mempublikasikan kalkulasi skor akhir peserta secara otomatis begitu status pengerjaan kuis diakhiri/dikumpulkan. |
| UR-05 | **FR-08** | Sistem harus menjalankan pemantauan konektivitas laten (_Connectivity Service_) yang bertugas memicu injeksi data secara otomatis (_background synchronization_) ke peladen pusat setelah mendeteksi ketersediaan jaringan internet yang stabil. |
| UR-05 | **FR-09** | Sistem harus mengakomodasi antarmuka eksekusi Sinkronisasi Manual (_force sync_) bagi pengguna untuk menginisiasi pembaruan basis data pusat secara proaktif. |
