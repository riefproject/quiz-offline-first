## Summary

| Keterangan | Nilai |
|---|---|
| Nama File | `lan_payload_test.dart` |
| Total Test Case | 4 |
| Total Test Pass | 4 |
| Total Test Fail | 0 |

| Modul Uji | Jumlah Test Case | # TC Pass | # TC Fail |
|---|---|---|---|
| ClientPayload.toBytes(), ClientPayload.fromBytes() | 1 | 1 | 0 |
| ClientPayload.fromBytes() | 2 | 2 | 0 |
| LanClientListener.stream | 1 | 1 | 0 |

## Testcase

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|---|---|---|---|---|---|---|---|
| TC01 | ClientPayload.toBytes(), ClientPayload.fromBytes() | Positif | ClientPayload can serialize to bytes and deserialize back | - | setup (arrange, build): 1. Buat objek ClientPayload  exercise (act, operate): 2. Panggil toBytes pada payload 3. Panggil fromBytes pada hasil bytes sebagai decoded  verify (assert, check): 4. Bandingkan properti hasil decoded dengan ekspektasi | name = 'Player 1' gameID = 999 clientId = 10 answers = [{1, 1200}, {2, 3400}] | bytes tidak kosong dan properti pada objek decoded sama dengan properti objek awal |
| TC02 | ClientPayload.fromBytes() | Negatif | ClientPayload fromBytes throws FormatException for invalid bytes | - | setup (arrange, build): 1. Siapkan invalid byte array  exercise (act, operate) & verify (assert, check): 2. Panggil fromBytes dengan byte array tersebut dan pastikan Exception dilempar | invalidBytes = [0, 1, 2, 3] | Exception dilempar saat memanggil fromBytes |
| TC03 | ClientPayload.fromBytes() | Negatif | ClientPayload handles missing or malformed fields gracefully or throws FormatException | - | setup (arrange, build): 1. Siapkan byte array dari malformed JSON 2. Siapkan byte array dari valid JSON yang kehilangan field wajib  exercise (act, operate) & verify (assert, check): 3. Panggil fromBytes dengan malformed byte array dan pastikan FormatException dilempar 4. Panggil fromBytes dengan missing field byte array dan pastikan FormatException dilempar | malformedJson = '{ "name": "Budi", "gameID": }' missingFieldJson = '{"clientId":5,"gameId":"invalid"}' | FormatException dilempar pada kedua skenario pemanggilan fromBytes |
| TC04 | LanClientListener.stream | Positif | LanClientListener drops mismatched gameId and duplicate payloads | Config.mockSessionOverride = true, mock hostService & clientService berjalan | setup (arrange, build): 1. Inisialisasi mock hostService dan clientService dengan gameId=999 2. Buat LanClientListener dan listen pada stream untuk menampung receivedPayloads  exercise (act, operate) & verify (assert, check): 3. Kirim payload valid pertama. Pastikan receivedPayloads bertambah jadi 1. 4. Kirim duplikat dari payload pertama. Pastikan receivedPayloads tetap 1. 5. Kirim payload dengan gameId salah (111). Pastikan receivedPayloads tetap 1. 6. Kirim payload terupdate (jumlah answers lebih banyak). Pastikan receivedPayloads bertambah jadi 2. | payload1: gameId=999, 1 answer payloadWrongGame: gameId=111, 1 answer payload2: gameId=999, 2 answers | receivedPayloads hanya menyimpan payload valid pertama dan payload terupdate. Duplikat dan salah gameId diabaikan. |

## Testcase Result

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi | Aktual | Hasil |
|---|---|---|---|---|---|---|---|---|---|
| TC01 | ClientPayload.toBytes(), ClientPayload.fromBytes() | Positif | ClientPayload can serialize to bytes and deserialize back | - | setup (arrange, build): 1. Buat objek ClientPayload  exercise (act, operate): 2. Panggil toBytes pada payload 3. Panggil fromBytes pada hasil bytes sebagai decoded  verify (assert, check): 4. Bandingkan properti hasil decoded dengan ekspektasi | name = 'Player 1' gameID = 999 clientId = 10 answers = [{1, 1200}, {2, 3400}] | bytes tidak kosong dan properti pada objek decoded sama dengan properti objek awal | bytes tidak kosong dan properti pada objek decoded sama dengan properti objek awal | Pass |
| TC02 | ClientPayload.fromBytes() | Negatif | ClientPayload fromBytes throws FormatException for invalid bytes | - | setup (arrange, build): 1. Siapkan invalid byte array  exercise (act, operate) & verify (assert, check): 2. Panggil fromBytes dengan byte array tersebut dan pastikan Exception dilempar | invalidBytes = [0, 1, 2, 3] | Exception dilempar saat memanggil fromBytes | Exception dilempar saat memanggil fromBytes | Pass |
| TC03 | ClientPayload.fromBytes() | Negatif | ClientPayload handles missing or malformed fields gracefully or throws FormatException | - | setup (arrange, build): 1. Siapkan byte array dari malformed JSON 2. Siapkan byte array dari valid JSON yang kehilangan field wajib  exercise (act, operate) & verify (assert, check): 3. Panggil fromBytes dengan malformed byte array dan pastikan FormatException dilempar 4. Panggil fromBytes dengan missing field byte array dan pastikan FormatException dilempar | malformedJson = '{ "name": "Budi", "gameID": }' missingFieldJson = '{"clientId":5,"gameId":"invalid"}' | FormatException dilempar pada kedua skenario pemanggilan fromBytes | FormatException dilempar pada kedua skenario pemanggilan fromBytes | Pass |
| TC04 | LanClientListener.stream | Positif | LanClientListener drops mismatched gameId and duplicate payloads | Config.mockSessionOverride = true, mock hostService & clientService berjalan | setup (arrange, build): 1. Inisialisasi mock hostService dan clientService dengan gameId=999 2. Buat LanClientListener dan listen pada stream untuk menampung receivedPayloads  exercise (act, operate) & verify (assert, check): 3. Kirim payload valid pertama. Pastikan receivedPayloads bertambah jadi 1. 4. Kirim duplikat dari payload pertama. Pastikan receivedPayloads tetap 1. 5. Kirim payload dengan gameId salah (111). Pastikan receivedPayloads tetap 1. 6. Kirim payload terupdate (jumlah answers lebih banyak). Pastikan receivedPayloads bertambah jadi 2. | payload1: gameId=999, 1 answer payloadWrongGame: gameId=111, 1 answer payload2: gameId=999, 2 answers | receivedPayloads hanya menyimpan payload valid pertama dan payload terupdate. Duplikat dan salah gameId diabaikan. | receivedPayloads hanya menyimpan payload valid pertama dan payload terupdate. Duplikat dan salah gameId diabaikan. | Pass |

## Evidence

| ID | Modul Uji | Test Case ID | Deskripsi Bug | Langkah Reproduksi | Ekspektasi | Realita | Screen Shoot Run Test |
|---|---|---|---|---|---|---|---|
