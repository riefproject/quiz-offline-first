## Summary

| Keterangan | Nilai |
|---|---|
| Nama File | lan_service_test.dart |
| Total Test Case | 5 |
| Total Test Pass | 5 |
| Total Test Fail | 0 |

| Modul Uji | Jumlah Test Case | # TC Pass | # TC Fail |
|---|---|---|---|
| LanService.host() & LanService.discovery() | 1 | 1 | 0 |
| LanService.host() & LanService.client() | 2 | 2 | 0 |
| LanService.client() | 1 | 1 | 0 |
| LanService.discovery() & LanService.host() | 1 | 1 | 0 |

## Testcase

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|---|---|---|---|---|---|---|---|
| TC01 | LanService.host() & LanService.discovery() | Positif | Host mode initializes correctly and broadcasts discovery | Mock network diaktifkan (Config.mockSessionOverride = true) | setup (arrange, build): 1. Buka channel discovery (`LanService.discovery()`) 2. Listen event `onGameDiscovered`  exercise (act, operate): 3. Buka host mode (`LanService.host()`) 4. Tunggu delay 50ms  verify (assert, check): 5. Verifikasi host service berjalan dan game ditemukan dengan data sesuai | gameId = 101 questionCount = 15 hostName = 'Test Host' | host berjalan dan data game pada discovery sesuai dengan test data |
| TC02 | LanService.host() & LanService.client() | Positif | Host to Client data transfer | Mock network diaktifkan (Config.mockSessionOverride = true) | setup (arrange, build): 1. Inisialisasi mock Host dan mock Client 2. Client listen event `onHostData`  exercise (act, operate): 3. Panggil mock broadcast data dari host ke client 4. Tunggu delay 50ms  verify (assert, check): 5. Bandingkan data yang diterima client dengan test data | gameId = 202 testData = [1, 2, 3, 4, 5] | Data diterima di client tidak null dan sesuai test data |
| TC03 | LanService.host() & LanService.client() | Positif | Client to Host data transfer | Mock network diaktifkan (Config.mockSessionOverride = true) | setup (arrange, build): 1. Inisialisasi mock Host dan mock Client 2. Host listen event `onClientData`  exercise (act, operate): 3. Panggil mock kirim data dari client ke host 4. Tunggu delay 50ms  verify (assert, check): 5. Bandingkan data yang diterima host dengan test data | gameId = 303 testData = [9, 8, 7] | Data yang diterima di host tidak null, clientId sesuai, dan isinya sama dengan test data |
| TC04 | LanService.client() | Positif | Client handles host disconnection gracefully | Real network diaktifkan (Config.mockSessionOverride = null) | setup (arrange, build): 1. Inisialisasi Host dan Client real network  exercise (act, operate): 2. Disconnect host (`host.dispose()`) secara tiba-tiba 3. Tunggu delay 100ms  verify (assert, check): 4. Cek status klien berjalan atau tidak (`client.isRunning`) | gameId = 505 wsPort = 12345 | Klien tertangani dengan baik dan status berjalan (isRunning) menjadi false |
| TC05 | LanService.discovery() & LanService.host() | Positif | Discovery receives broadcast from real host | Real network diaktifkan (Config.mockSessionOverride = null) | setup (arrange, build): 1. Buka channel discovery dan listen ke `onGameDiscovered` untuk test data gameId  exercise (act, operate): 2. Buka Host service real network dengan broadcast aktif 3. Tunggu delay 2 detik (estimasi waktu broadcast)  verify (assert, check): 4. Verifikasi game ditemukan dan data hostname sesuai dengan test data | gameId = 606 hostName = 'Real Host' wsPort = 12346 | Discovery berhasil menangkap game, status game tidak null, dan hostName sesuai test data |

## Testcase Result

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi | Aktual | Hasil |
|---|---|---|---|---|---|---|---|---|---|
| TC01 | LanService.host() & LanService.discovery() | Positif | Host mode initializes correctly and broadcasts discovery | Mock network diaktifkan (Config.mockSessionOverride = true) | setup (arrange, build): 1. Buka channel discovery (`LanService.discovery()`) 2. Listen event `onGameDiscovered`  exercise (act, operate): 3. Buka host mode (`LanService.host()`) 4. Tunggu delay 50ms  verify (assert, check): 5. Verifikasi host service berjalan dan game ditemukan dengan data sesuai | gameId = 101 questionCount = 15 hostName = 'Test Host' | host berjalan dan data game pada discovery sesuai dengan test data | host berjalan dan data game pada discovery sesuai dengan test data | Pass |
| TC02 | LanService.host() & LanService.client() | Positif | Host to Client data transfer | Mock network diaktifkan (Config.mockSessionOverride = true) | setup (arrange, build): 1. Inisialisasi mock Host dan mock Client 2. Client listen event `onHostData`  exercise (act, operate): 3. Panggil mock broadcast data dari host ke client 4. Tunggu delay 50ms  verify (assert, check): 5. Bandingkan data yang diterima client dengan test data | gameId = 202 testData = [1, 2, 3, 4, 5] | Data diterima di client tidak null dan sesuai test data | Data diterima di client tidak null dan sesuai test data | Pass |
| TC03 | LanService.host() & LanService.client() | Positif | Client to Host data transfer | Mock network diaktifkan (Config.mockSessionOverride = true) | setup (arrange, build): 1. Inisialisasi mock Host dan mock Client 2. Host listen event `onClientData`  exercise (act, operate): 3. Panggil mock kirim data dari client ke host 4. Tunggu delay 50ms  verify (assert, check): 5. Bandingkan data yang diterima host dengan test data | gameId = 303 testData = [9, 8, 7] | Data yang diterima di host tidak null, clientId sesuai, dan isinya sama dengan test data | Data yang diterima di host tidak null, clientId sesuai, dan isinya sama dengan test data | Pass |
| TC04 | LanService.client() | Positif | Client handles host disconnection gracefully | Real network diaktifkan (Config.mockSessionOverride = null) | setup (arrange, build): 1. Inisialisasi Host dan Client real network  exercise (act, operate): 2. Disconnect host (`host.dispose()`) secara tiba-tiba 3. Tunggu delay 100ms  verify (assert, check): 4. Cek status klien berjalan atau tidak (`client.isRunning`) | gameId = 505 wsPort = 12345 | Klien tertangani dengan baik dan status berjalan (isRunning) menjadi false | Klien tertangani dengan baik dan status berjalan (isRunning) menjadi false | Pass |
| TC05 | LanService.discovery() & LanService.host() | Positif | Discovery receives broadcast from real host | Real network diaktifkan (Config.mockSessionOverride = null) | setup (arrange, build): 1. Buka channel discovery dan listen ke `onGameDiscovered` untuk test data gameId  exercise (act, operate): 2. Buka Host service real network dengan broadcast aktif 3. Tunggu delay 2 detik (estimasi waktu broadcast)  verify (assert, check): 4. Verifikasi game ditemukan dan data hostname sesuai dengan test data | gameId = 606 hostName = 'Real Host' wsPort = 12346 | Discovery berhasil menangkap game, status game tidak null, dan hostName sesuai test data | Discovery berhasil menangkap game, status game tidak null, dan hostName sesuai test data | Pass |

## Evidence

| ID | Modul Uji | Test Case ID | Deskripsi Bug | Langkah Reproduksi | Ekspektasi | Realita | Screen Shoot Run Test |
|---|---|---|---|---|---|---|---|
