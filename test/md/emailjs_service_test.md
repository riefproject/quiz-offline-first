## Summary

| Keterangan | Nilai |
|---|---|
| Nama File | emailjs_service_test.dart |
| Total Test Case | 5 |
| Total Test Pass | 5 |
| Total Test Fail | 0 |

| Modul Uji | Jumlah Test Case | # TC Pass | # TC Fail |
|---|---|---|---|
| sendOtp | 5 | 5 | 0 |

## Testcase

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|---|---|---|---|---|---|---|---|
| TC01 | sendOtp | Positif | sendOtp sukses mengirim payload yang benar (HTTP 200) | Dotenv diload dengan config lengkap | setup (arrange, build): 1. Inisialisasi Mock Client untuk response HTTP 200  exercise (act, operate): 2. Panggil fungsi EmailJsService.sendOtp  verify (assert, check): 3. Verifikasi payload JSON yang dikirim memuat parameter yang benar | toEmail = 'budi@test.com' otpCode = '123456' expiryTime = '15:00' | Payload JSON yang dikirimkan sesuai standar EmailJS |
| TC02 | sendOtp | Positif | sendOtp tidak mengirim accessToken jika EMAILJS_PRIVATE_KEY kosong | Dotenv diload dengan konfigurasi PRIVATE_KEY kosong | setup (arrange, build): 1. Set env PRIVATE_KEY menjadi kosong 2. Inisialisasi Mock Client  exercise (act, operate): 3. Panggil fungsi EmailJsService.sendOtp  verify (assert, check): 4. Verifikasi accessToken tidak ada di dalam payload | EMAILJS_PRIVATE_KEY = '' | accessToken tidak dikirim di dalam payload |
| TC03 | sendOtp | Negatif | sendOtp melemparkan EmailJsException jika HTTP 403 (Strict Mode) | Dotenv diload dengan config lengkap | setup (arrange, build): 1. Inisialisasi Mock Client untuk me-return status HTTP 403  exercise (act, operate): 2. Panggil fungsi EmailJsService.sendOtp  verify (assert, check): 3. Pastikan memunculkan exception dengan pesan HTTP 403 | HTTP status = 403 | Fungsi melemparkan EmailJsException berisi pesan 'HTTP 403' |
| TC04 | sendOtp | Negatif | sendOtp melemparkan EmailJsException jika koneksi terputus | Dotenv diload dengan config lengkap | setup (arrange, build): 1. Inisialisasi Mock Client yang melemparkan Exception 'No internet connection'  exercise (act, operate): 2. Panggil fungsi EmailJsService.sendOtp  verify (assert, check): 3. Pastikan memunculkan exception tentang koneksi | Exception 'No internet connection' | Fungsi melemparkan EmailJsException berisi pesan 'Periksa koneksi internet' |
| TC05 | sendOtp | Negatif | sendOtp melemparkan EmailJsException jika dotenv kosong | Dotenv diload dengan konfigurasi kosong | setup (arrange, build): 1. Set semua env variables menjadi kosong  exercise (act, operate): 2. Panggil fungsi EmailJsService.sendOtp  verify (assert, check): 3. Pastikan memunculkan exception tentang konfigurasi | ENV variables kosong | Fungsi melemparkan EmailJsException berisi pesan 'EmailJS belum dikonfigurasi' |

## Testcase Result

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi | Aktual | Hasil |
|---|---|---|---|---|---|---|---|---|---|
| TC01 | sendOtp | Positif | sendOtp sukses mengirim payload yang benar (HTTP 200) | Dotenv diload dengan config lengkap | setup (arrange, build): 1. Inisialisasi Mock Client untuk response HTTP 200  exercise (act, operate): 2. Panggil fungsi EmailJsService.sendOtp  verify (assert, check): 3. Verifikasi payload JSON yang dikirim memuat parameter yang benar | toEmail = 'budi@test.com' otpCode = '123456' expiryTime = '15:00' | Payload JSON yang dikirimkan sesuai standar EmailJS | Payload JSON yang dikirimkan sesuai standar EmailJS | Pass |
| TC02 | sendOtp | Positif | sendOtp tidak mengirim accessToken jika EMAILJS_PRIVATE_KEY kosong | Dotenv diload dengan konfigurasi PRIVATE_KEY kosong | setup (arrange, build): 1. Set env PRIVATE_KEY menjadi kosong 2. Inisialisasi Mock Client  exercise (act, operate): 3. Panggil fungsi EmailJsService.sendOtp  verify (assert, check): 4. Verifikasi accessToken tidak ada di dalam payload | EMAILJS_PRIVATE_KEY = '' | accessToken tidak dikirim di dalam payload | accessToken tidak dikirim di dalam payload | Pass |
| TC03 | sendOtp | Negatif | sendOtp melemparkan EmailJsException jika HTTP 403 (Strict Mode) | Dotenv diload dengan config lengkap | setup (arrange, build): 1. Inisialisasi Mock Client untuk me-return status HTTP 403  exercise (act, operate): 2. Panggil fungsi EmailJsService.sendOtp  verify (assert, check): 3. Pastikan memunculkan exception dengan pesan HTTP 403 | HTTP status = 403 | Fungsi melemparkan EmailJsException berisi pesan 'HTTP 403' | Fungsi melemparkan EmailJsException berisi pesan 'HTTP 403' | Pass |
| TC04 | sendOtp | Negatif | sendOtp melemparkan EmailJsException jika koneksi terputus | Dotenv diload dengan config lengkap | setup (arrange, build): 1. Inisialisasi Mock Client yang melemparkan Exception 'No internet connection'  exercise (act, operate): 2. Panggil fungsi EmailJsService.sendOtp  verify (assert, check): 3. Pastikan memunculkan exception tentang koneksi | Exception 'No internet connection' | Fungsi melemparkan EmailJsException berisi pesan 'Periksa koneksi internet' | Fungsi melemparkan EmailJsException berisi pesan 'Periksa koneksi internet' | Pass |
| TC05 | sendOtp | Negatif | sendOtp melemparkan EmailJsException jika dotenv kosong | Dotenv diload dengan konfigurasi kosong | setup (arrange, build): 1. Set semua env variables menjadi kosong  exercise (act, operate): 2. Panggil fungsi EmailJsService.sendOtp  verify (assert, check): 3. Pastikan memunculkan exception tentang konfigurasi | ENV variables kosong | Fungsi melemparkan EmailJsException berisi pesan 'EmailJS belum dikonfigurasi' | Fungsi melemparkan EmailJsException berisi pesan 'EmailJS belum dikonfigurasi' | Pass |

## Evidence

| ID | Modul Uji | Test Case ID | Deskripsi Bug | Langkah Reproduksi | Ekspektasi | Realita | Screen Shoot Run Test |
|---|---|---|---|---|---|---|---|
