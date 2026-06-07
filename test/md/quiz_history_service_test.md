## Summary

| Keterangan | Nilai |
|---|---|
| Nama File | `test/quiz_history_service_test.dart` |
| Total Test Case | 4 |
| Total Test Pass | 4 |
| Total Test Fail | 0 |

| Modul Uji | Jumlah Test Case | # TC Pass | # TC Fail |
|---|---|---|---|
| loadHistoryForCreator(String creatorId) | 2 | 2 | 0 |
| deleteSession(String sessionId) | 1 | 1 | 0 |
| clearAllHistory() | 1 | 1 | 0 |

## Testcase

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|---|---|---|---|---|---|---|---|
| TC01 | loadHistoryForCreator(String creatorId) | Positif | loads newest organizer history with leaderboard | Program siap dijalankan, mock storage kosong | setup (arrange, build): 1. Inisialisasi mock storage 2. Simpan data Quiz ('quiz_1') dan Soal ('soal_1') 3. Simpan sesi kuis baru (sesi_baru) beserta peserta dan skornya 4. Simpan sesi kuis lama (sesi_lama) beserta peserta dan skornya  exercise (act, operate): 5. Panggil fungsi loadHistoryForCreator('creator_1') sebagai nilai aktual  verify (assert, check): 6. Bandingkan nilai aktual dan ekspektasi | creatorId = 'creator_1' Sesi baru: 'sesi_baru' Sesi lama: 'sesi_lama' | panjang history = 2, elemen pertama adalah 'sesi_baru' dengan rank 1 bernama Budi dan score 1200 |
| TC02 | loadHistoryForCreator(String creatorId) | Positif | loadHistoryForCreator returns empty list when no history exists | Program siap dijalankan, mock storage kosong | setup (arrange, build): 1. Inisialisasi mock storage  exercise (act, operate): 2. Panggil fungsi loadHistoryForCreator('creator_kosong') sebagai nilai aktual  verify (assert, check): 3. Bandingkan nilai aktual dan ekspektasi | creatorId = 'creator_kosong' | history bernilai empty (kosong) |
| TC03 | deleteSession(String sessionId) | Positif | deleteSession removes session and associated data | Program siap dijalankan, mock storage kosong | setup (arrange, build): 1. Inisialisasi mock storage 2. Simpan sesi kuis ('sesi_dihapus') 3. Verifikasi sesi 'sesi_dihapus' ada di box  exercise (act, operate): 4. Panggil fungsi deleteSession('sesi_dihapus')  verify (assert, check): 5. Cek apakah sesi 'sesi_dihapus' terhapus dari box | sessionId = 'sesi_dihapus' | sesi 'sesi_dihapus' tidak ada di dalam box |
| TC04 | clearAllHistory() | Positif | clearAllHistory removes everything from boxes | Program siap dijalankan, mock storage kosong | setup (arrange, build): 1. Inisialisasi mock storage 2. Simpan 2 sesi kuis ('sesi_1' dan 'sesi_2') 3. Verifikasi box tidak kosong  exercise (act, operate): 4. Panggil fungsi clearAllHistory()  verify (assert, check): 5. Cek apakah box terkait history kosong | Sesi 1: 'sesi_1' Sesi 2: 'sesi_2' | box sesiKuisBox, pesertaSesiBox, dan hasilAkhirBox menjadi kosong |

## Testcase Result

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi | Aktual | Hasil |
|---|---|---|---|---|---|---|---|---|---|
| TC01 | loadHistoryForCreator(String creatorId) | Positif | loads newest organizer history with leaderboard | Program siap dijalankan, mock storage kosong | setup (arrange, build): 1. Inisialisasi mock storage 2. Simpan data Quiz ('quiz_1') dan Soal ('soal_1') 3. Simpan sesi kuis baru (sesi_baru) beserta peserta dan skornya 4. Simpan sesi kuis lama (sesi_lama) beserta peserta dan skornya  exercise (act, operate): 5. Panggil fungsi loadHistoryForCreator('creator_1') sebagai nilai aktual  verify (assert, check): 6. Bandingkan nilai aktual dan ekspektasi | creatorId = 'creator_1' Sesi baru: 'sesi_baru' Sesi lama: 'sesi_lama' | panjang history = 2, elemen pertama adalah 'sesi_baru' dengan rank 1 bernama Budi dan score 1200 | panjang history = 2, elemen pertama adalah 'sesi_baru' dengan rank 1 bernama Budi dan score 1200 | Pass |
| TC02 | loadHistoryForCreator(String creatorId) | Positif | loadHistoryForCreator returns empty list when no history exists | Program siap dijalankan, mock storage kosong | setup (arrange, build): 1. Inisialisasi mock storage  exercise (act, operate): 2. Panggil fungsi loadHistoryForCreator('creator_kosong') sebagai nilai aktual  verify (assert, check): 3. Bandingkan nilai aktual dan ekspektasi | creatorId = 'creator_kosong' | history bernilai empty (kosong) | history bernilai empty (kosong) | Pass |
| TC03 | deleteSession(String sessionId) | Positif | deleteSession removes session and associated data | Program siap dijalankan, mock storage kosong | setup (arrange, build): 1. Inisialisasi mock storage 2. Simpan sesi kuis ('sesi_dihapus') 3. Verifikasi sesi 'sesi_dihapus' ada di box  exercise (act, operate): 4. Panggil fungsi deleteSession('sesi_dihapus')  verify (assert, check): 5. Cek apakah sesi 'sesi_dihapus' terhapus dari box | sessionId = 'sesi_dihapus' | sesi 'sesi_dihapus' tidak ada di dalam box | sesi 'sesi_dihapus' tidak ada di dalam box | Pass |
| TC04 | clearAllHistory() | Positif | clearAllHistory removes everything from boxes | Program siap dijalankan, mock storage kosong | setup (arrange, build): 1. Inisialisasi mock storage 2. Simpan 2 sesi kuis ('sesi_1' dan 'sesi_2') 3. Verifikasi box tidak kosong  exercise (act, operate): 4. Panggil fungsi clearAllHistory()  verify (assert, check): 5. Cek apakah box terkait history kosong | Sesi 1: 'sesi_1' Sesi 2: 'sesi_2' | box sesiKuisBox, pesertaSesiBox, dan hasilAkhirBox menjadi kosong | box sesiKuisBox, pesertaSesiBox, dan hasilAkhirBox menjadi kosong | Pass |

## Evidence

| ID | Modul Uji | Test Case ID | Deskripsi Bug | Langkah Reproduksi | Ekspektasi | Realita | Screen Shoot Run Test |
|---|---|---|---|---|---|---|---|
