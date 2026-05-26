# Pendahuluan

Dokumen ini menguraikan landasan konseptual dari perancangan arsitektur sistem AlpenQuiz.

## 1. Latar Belakang

Dalam era digitalisasi pendidikan, penggunaan aplikasi kuis berbasis seluler telah menjadi standar utama untuk mengevaluasi partisipan secara waktu nyata (_real-time_). Namun, sebagian besar solusi perangkat lunak yang beredar dirancang dengan pendekatan komputasi awan absolut (_cloud-first_), yang mengasumsikan ketersediaan koneksi jaringan yang stabil secara terus-menerus.

Ketergantungan ini memunculkan anomali sistem yang kritis ketika aplikasi dioperasikan di lokasi dengan infrastruktur jaringan yang tidak merata, atau pada acara padat massa yang memicu kelebihan muatan (_congestion_) pada jaringan seluler. Penurunan kualitas konektivitas sering kali berujung pada interupsi sesi evaluasi, hilangnya _state_ jawaban yang telah dimasukkan, dan kegagalan transmisi data akhir. Kondisi ini merusak integritas pelaporan data dan mengurangi produktivitas teknis penyelenggara.

## 2. Rumusan Masalah

Berdasarkan tinjauan di atas, pengembangan perangkat lunak AlpenQuiz berfokus pada penyelesaian kendala struktural berikut:
1. Bagaimana mengamankan _state_ aplikasi dan data masukan pengguna dari kehilangan (_data loss_) saat terjadi fluktuasi atau pemutusan jaringan secara sepihak?
2. Bagaimana memfasilitasi interaksi distribusi kuis secara massal di lokasi yang terisolasi dari jaringan internet global?
3. Bagaimana merancang mekanisme sinkronisasi asinkron yang menjamin rekonsiliasi data lokal dengan basis data terpusat secara akurat begitu konektivitas pulih?

## 3. Solusi yang Ditawarkan

Untuk menjawab rumusan masalah tersebut, sistem perangkat lunak **AlpenQuiz** direkayasa menggunakan paradigma arsitektur luring penuh (**_Offline-First_**). 

Arsitektur ini mengalihkan pusat persistensi data dari antarmuka pemograman aplikasi (API) jarak jauh ke memori perangkat internal klien menggunakan basis data NoSQL lokal. Pendekatan ini memastikan keberlangsungan transaksi data (pengerjaan kuis) tanpa ketergantungan pada status jaringan eksternal.

Sistem ini dioperasikan dengan dukungan dua kapabilitas teknis tambahan:
1. **Mesin Sinkronisasi Latar Belakang (_Background Sync Engine_)**: Mekanisme yang memantau perubahan status konektivitas perangkat lunak. Sistem secara otomatis menyelaraskan dan mengunggah muatan data (_payload_) lokal ke peladen pusat ketika kriteria jaringan stabil telah terpenuhi, tanpa intervensi pengguna.
2. **Konektivitas Jaringan Area Lokal (LAN)**: Protokol yang memampukan fungsionalitas komputasi terdistribusi secara tertutup, mengizinkan transmisi paket soal langsung dari perangkat penyelenggara ke perangkat peserta dalam satu rute jaringan (_intranet_) yang sama.
