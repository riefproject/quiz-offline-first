## Summary

| Keterangan | Nilai |
|---|---|
| Nama File | `test/mongodb_test.dart` |
| Total Test Case | 2 |
| Total Test Pass | 2 |
| Total Test Fail | 0 |

| Modul Uji | Jumlah Test Case | # TC Pass | # TC Fail |
|---|---|---|---|
| `MongoDatabase.db` | 1 | 1 | 0 |
| `MongoDatabase.usersCollection` | 1 | 1 | 0 |

## Testcase

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|---|---|---|---|---|---|---|---|
| TC01 | `MongoDatabase.db` | Positif | Database harus terkoneksi dan merespon | Database connection telah di-setup menggunakan URI test | setup (arrange, build): 1. Baca test URI dari file `.env` 2. Eksekusi `MongoDatabase.connect()`  exercise (act, operate): 3. Get nilai state dari `MongoDatabase.db` hasil eksekusi program sebagai nilai aktual  verify (assert, check): 4. Bandingkan nilai aktual dan ekspektasi | - | nilai state database sekarang adalah `State.open` |
| TC02 | `MongoDatabase.usersCollection` | Positif | Operasi CRUD Collection Users | Database testing siap digunakan | setup (arrange, build): 1. Ambil collection `users` 2. Buat objek `AppUser` dummy 3. Hapus data dengan id dummy jika sudah ada sebelumnya  exercise (act, operate): 4. Lakukan operasi Create (insertOne) 5. Lakukan operasi Read (findOne) 6. Lakukan operasi Update (updateOne) 7. Lakukan operasi Delete (deleteOne)  verify (assert, check): 8. Bandingkan nilai aktual dan ekspektasi pada setiap tahap (Insert sukses, hasil Read sesuai dengan test data, hasil Update sesuai nama baru, Delete sukses dan Read ulang menjadi null) | id = 'test_unit_id_123' nama_lengkap (awal) = 'Tester via Unit Test' nama_lengkap (baru) = 'Tester via Unit Test Updated' | Proses Create, Read, Update, dan Delete berhasil dieksekusi, nilai field tervalidasi sesuai dengan operasi modifikasi |

## Testcase Result

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi | Aktual | Hasil |
|---|---|---|---|---|---|---|---|---|---|
| TC01 | `MongoDatabase.db` | Positif | Database harus terkoneksi dan merespon | Database connection telah di-setup menggunakan URI test | setup (arrange, build): 1. Baca test URI dari file `.env` 2. Eksekusi `MongoDatabase.connect()`  exercise (act, operate): 3. Get nilai state dari `MongoDatabase.db` hasil eksekusi program sebagai nilai aktual  verify (assert, check): 4. Bandingkan nilai aktual dan ekspektasi | - | nilai state database sekarang adalah `State.open` | nilai state database sekarang adalah `State.open` | Pass |
| TC02 | `MongoDatabase.usersCollection` | Positif | Operasi CRUD Collection Users | Database testing siap digunakan | setup (arrange, build): 1. Ambil collection `users` 2. Buat objek `AppUser` dummy 3. Hapus data dengan id dummy jika sudah ada sebelumnya  exercise (act, operate): 4. Lakukan operasi Create (insertOne) 5. Lakukan operasi Read (findOne) 6. Lakukan operasi Update (updateOne) 7. Lakukan operasi Delete (deleteOne)  verify (assert, check): 8. Bandingkan nilai aktual dan ekspektasi pada setiap tahap (Insert sukses, hasil Read sesuai dengan test data, hasil Update sesuai nama baru, Delete sukses dan Read ulang menjadi null) | id = 'test_unit_id_123' nama_lengkap (awal) = 'Tester via Unit Test' nama_lengkap (baru) = 'Tester via Unit Test Updated' | Proses Create, Read, Update, dan Delete berhasil dieksekusi, nilai field tervalidasi sesuai dengan operasi modifikasi | Proses Create, Read, Update, dan Delete berhasil dieksekusi, nilai field tervalidasi sesuai dengan operasi modifikasi | Pass |

## Evidence

| ID | Modul Uji | Test Case ID | Deskripsi Bug | Langkah Reproduksi | Ekspektasi | Realita | Screen Shoot Run Test |
|---|---|---|---|---|---|---|---|
