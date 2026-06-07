## Summary

| Keterangan | Nilai |
|---|---|
| Nama File | `hive_test.dart` |
| Total Test Case | 4 |
| Total Test Pass | 4 |
| Total Test Fail | 0 |

| Modul Uji | Jumlah Test Case | # TC Pass | # TC Fail |
|---|---|---|---|
| Hive Box (User & Quiz) | 1 | 1 | 0 |
| Hive Box (SesiKuis) | 1 | 1 | 0 |
| Hive.box() | 1 | 1 | 0 |
| Box.clear() | 1 | 1 | 0 |

## Testcase

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|---|---|---|---|---|---|---|---|
| TC01 | Hive Box (User & Quiz) | Positif | Simpan dan Ambil Data Box (Users & Quiz) | Hive dan Adapter diinisialisasi | setup (arrange, build): 1. Buka Box test_user_box dan test_quiz_box 2. Buat objek data dummy AppUser dan Quiz  exercise (act, operate): 3. Simpan data dummy ke Box 4. Ambil data dari Box dan simpan sebagai nilai aktual pertama 5. Update data Quiz di Box 6. Ambil data Quiz yang diupdate sebagai nilai aktual kedua 7. Hapus data User dari Box  verify (assert, check): 8. Verifikasi aktual pertama tidak null dan sesuai ekspektasi 9. Verifikasi aktual kedua sesuai ekspektasi perubahan 10. Verifikasi status data user di box sudah terhapus | User: ID='user_xyz', nama='Tester Hive' Quiz: ID='kuis_456', judul='Kuis Geografi' Updated Quiz: judul='Kuis Geografi (Updated)' | Data tersimpan, di-update, dan terhapus dengan benar di Hive |
| TC02 | Hive Box (SesiKuis) | Positif | Menangani custom adapter SesiKuis dan HasilAkhir | Hive dan Adapter diinisialisasi | setup (arrange, build): 1. Buka Box test_sesi_box 2. Buat objek data dummy SesiKuis  exercise (act, operate): 3. Simpan data dummy ke Box 4. Ambil data dari Box sebagai aktual 5. Bersihkan seluruh data Box dengan clear()  verify (assert, check): 6. Verifikasi nilai aktual sesuai dengan ekspektasi (status aktif) 7. Verifikasi Box telah menjadi kosong | SesiKuis: ID='sesi_123', status='aktif' | Custom adapter SesiKuis bekerja dengan benar, data tersimpan dan terbaca sesuai |
| TC03 | Hive.box() | Negatif | Mengakses Box yang belum dibuka akan melempar error | Hive dan Adapter diinisialisasi | setup (arrange, build): 1. Pastikan box belum dibuka (box_belum_dibuka)  exercise (act, operate): 2. Akses Box yang belum dibuka tersebut  verify (assert, check): 3. Verifikasi apakah akses menghasilkan error HiveError | Box name: 'box_belum_dibuka' | Terlempar error HiveError |
| TC04 | Box.clear() | Positif | Menghapus seluruh isi Box menggunakan clear() | Hive dan Adapter diinisialisasi | setup (arrange, build): 1. Buka Box test_clear_quiz_box 2. Tambahkan dua objek Quiz ke dalam Box  exercise (act, operate): 3. Dapatkan jumlah isi dari Box sebagai nilai aktual pertama 4. Kosongkan box menggunakan clear() 5. Cek apakah box tersebut kosong sebagai nilai aktual kedua  verify (assert, check): 6. Verifikasi nilai aktual pertama = 2 7. Verifikasi nilai aktual kedua bernilai True (kosong) | Quiz 1: ID='1' Quiz 2: ID='2' | Semua data dari dalam Box terhapus seutuhnya |

## Testcase Result

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi | Aktual | Hasil |
|---|---|---|---|---|---|---|---|---|---|
| TC01 | Hive Box (User & Quiz) | Positif | Simpan dan Ambil Data Box (Users & Quiz) | Hive dan Adapter diinisialisasi | setup (arrange, build): 1. Buka Box test_user_box dan test_quiz_box 2. Buat objek data dummy AppUser dan Quiz  exercise (act, operate): 3. Simpan data dummy ke Box 4. Ambil data dari Box dan simpan sebagai nilai aktual pertama 5. Update data Quiz di Box 6. Ambil data Quiz yang diupdate sebagai nilai aktual kedua 7. Hapus data User dari Box  verify (assert, check): 8. Verifikasi aktual pertama tidak null dan sesuai ekspektasi 9. Verifikasi aktual kedua sesuai ekspektasi perubahan 10. Verifikasi status data user di box sudah terhapus | User: ID='user_xyz', nama='Tester Hive' Quiz: ID='kuis_456', judul='Kuis Geografi' Updated Quiz: judul='Kuis Geografi (Updated)' | Data tersimpan, di-update, dan terhapus dengan benar di Hive | Data tersimpan, di-update, dan terhapus dengan benar di Hive | Pass |
| TC02 | Hive Box (SesiKuis) | Positif | Menangani custom adapter SesiKuis dan HasilAkhir | Hive dan Adapter diinisialisasi | setup (arrange, build): 1. Buka Box test_sesi_box 2. Buat objek data dummy SesiKuis  exercise (act, operate): 3. Simpan data dummy ke Box 4. Ambil data dari Box sebagai aktual 5. Bersihkan seluruh data Box dengan clear()  verify (assert, check): 6. Verifikasi nilai aktual sesuai dengan ekspektasi (status aktif) 7. Verifikasi Box telah menjadi kosong | SesiKuis: ID='sesi_123', status='aktif' | Custom adapter SesiKuis bekerja dengan benar, data tersimpan dan terbaca sesuai | Custom adapter SesiKuis bekerja dengan benar, data tersimpan dan terbaca sesuai | Pass |
| TC03 | Hive.box() | Negatif | Mengakses Box yang belum dibuka akan melempar error | Hive dan Adapter diinisialisasi | setup (arrange, build): 1. Pastikan box belum dibuka (box_belum_dibuka)  exercise (act, operate): 2. Akses Box yang belum dibuka tersebut  verify (assert, check): 3. Verifikasi apakah akses menghasilkan error HiveError | Box name: 'box_belum_dibuka' | Terlempar error HiveError | Terlempar error HiveError | Pass |
| TC04 | Box.clear() | Positif | Menghapus seluruh isi Box menggunakan clear() | Hive dan Adapter diinisialisasi | setup (arrange, build): 1. Buka Box test_clear_quiz_box 2. Tambahkan dua objek Quiz ke dalam Box  exercise (act, operate): 3. Dapatkan jumlah isi dari Box sebagai nilai aktual pertama 4. Kosongkan box menggunakan clear() 5. Cek apakah box tersebut kosong sebagai nilai aktual kedua  verify (assert, check): 6. Verifikasi nilai aktual pertama = 2 7. Verifikasi nilai aktual kedua bernilai True (kosong) | Quiz 1: ID='1' Quiz 2: ID='2' | Semua data dari dalam Box terhapus seutuhnya | Semua data dari dalam Box terhapus seutuhnya | Pass |

## Evidence

| ID | Modul Uji | Test Case ID | Deskripsi Bug | Langkah Reproduksi | Ekspektasi | Realita | Screen Shoot Run Test |
|---|---|---|---|---|---|---|---|
