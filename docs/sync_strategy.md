# Strategi Sinkronisasi Offline-Online

## Gambaran Umum

AlpenQuiz menyimpan data kuis secara **lokal di perangkat** (Hive). Ketika tersambung internet, data dikirim dan diambil dari **cloud** (MongoDB). Setiap kuis dan soal memiliki flag `isSynced` untuk melacak apakah data lokal sudah cocok dengan cloud.

```
                ┌──────────┐
                │  MongoDB │  (cloud)
                └────┬─────┘
                     │
            ┌────────┴────────┐
            │    INTERNET     │
            └────────┬────────┘
                     │
                ┌────┴─────┐
                │   Hive   │  (lokal)
                └──────────┘
```

---

## Strategi Pull (Cloud → Lokal)

**Kapan**: Saat aplikasi pertama kali dibuka, atau saat koneksi internet pulih setelah offline.

**Cara kerja**:

1. Ambil **semua** kuis dan soal dari MongoDB.
2. Untuk setiap dokumen dari cloud:
   - Jika data **belum ada** di lokal → simpan.
   - Jika data **sudah ada** di lokal dan `isSynced = true` → timpa dengan data cloud.
   - Jika data **sudah ada** di lokal dan `isSynced = false` → **jangan timpa** (abaikan data cloud).

**Logika**: "Jangan rusak perubahan lokal yang belum dikirim ke cloud."

---

## Strategi Push (Lokal → Cloud)

**Kapan**: Setelah Pull selesai (dalam siklus sync yang sama), atau saat pengguna mengetuk tombol sync manual.

**Cara kerja**:

1. Cari semua kuis dan soal lokal yang `isSynced = false`.
2. Untuk setiap data:
   - Jika soal memiliki gambar lokal → upload ke Cloudinary dulu.
   - Kirim data ke MongoDB (insert jika belum ada, update jika sudah ada).
   - Setelah berhasil → tandai `isSynced = true` di Hive.

**Logika**: "Semua yang dibuat/diubah offline harus sampai ke cloud."

---

## Konflik dan Penanganannya

Konflik terjadi ketika **dua sumber mengubah data yang sama** tanpa tahu perubahan satu sama lain.

### Situasi 1: Edit offline lalu Pull

```
Keadaan: Kuis X di-cloud sudah diubah orang lain.
         Kuis X di-lokal kamu juga sudah diubah (isSynced = false).
```

| Langkah | Aksi |
|---|---|
| Pull | Cloud mengirim Kuis X versi terbaru |
| Cek | Lokal punya Kuis X dengan `isSynced = false` |
| **Hasil** | **Cloud diabaikan.** Lokal kamu tidak disentuh. |

Akibat: kamu **tidak pernah melihat** perubahan dari cloud.
Ketika Push berikutnya, versi lokal kamu akan menimpa cloud, menghapus perubahan orang lain.

### Situasi 2: Dua perangkat, satu akun

```
Keadaan: Kamu edit Kuis X di HP-A.
         Kamu juga edit Kuis X di HP-B.
         Keduanya offline, lalu online bergantian.
```

| Urutan | Perangkat | Aksi | Hasil |
|---|---|---|---|
| 1 | HP-A online | Push Kuis X versi A | Cloud = versi A |
| 2 | HP-B online | Push Kuis X versi B | Cloud = versi B (A hilang) |

**Yang terakhir sync menang.** Tidak ada peringatan, tidak ada penggabungan.

### Situasi 3: Gambar gagal upload

```
Keadaan: Soal dengan gambar lokal mau di-push.
         Upload ke Cloudinary gagal (timeout, quota habis, dsb).
```

| Langkah | Aksi |
|---|---|
| Push soal | Gambar gagal upload |
| **Hasil** | Soal **dilewati**, `isSynced` tetap `false` |
| | Pesan error: "Some images failed to sync" |
| | Soal akan dicoba lagi di sync berikutnya |

---

## Kelemahan Saat Ini

| Masalah | Dampak |
|---|---|
| Tidak ada versi (_rev, updatedAt) | Tidak tahu mana data yang lebih baru |
| Tidak ada penggabungan (merge) | Perubahan bentrok → salah satu hilang |
| Tidak ada notifikasi konflik | Pengguna tidak tahu datanya ditimpa |
| Last-writer-wins sederhana | Editing kolaboratif rawan kehilangan data |

Strategi saat ini cukup aman untuk **satu pengguna, satu perangkat**. Untuk multi-perangkat atau kolaborasi, diperlukan mekanisme resolusi konflik yang lebih baik.
