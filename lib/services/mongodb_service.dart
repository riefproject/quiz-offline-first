import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static Db? _db;
  
  // Variabel untuk menyuntikkan URI dari unit test secara manual
  static String? testUri;

  static String get _connectionString {
    if (testUri != null) return testUri!;
    
    final uri = dotenv.env['MONGO_URI'];
    if (uri == null || uri.isEmpty) {
      throw Exception('MONGO_URI tidak ditemukan di dalam file .env');
    }
    return uri;
  }

  /// Membuka koneksi ke database MongoDB
  static Future<void> connect() async {
    if (_db != null && _db!.state == State.open) return;

    try {
      _db = await Db.create(_connectionString);
      await _db!.open();
      print('Berhasil terhubung ke database MongoDB');
    } catch (e) {
      print('Gagal terhubung ke database MongoDB: $e');
      rethrow;
    }
  }

  /// Mendapatkan instance database
  static Db get db {
    if (_db == null || _db!.state != State.open) {
      throw Exception('Database belum terkoneksi. Panggil MongoDatabase.connect() terlebih dahulu.');
    }
    return _db!;
  }

  // --- Daftar Collections ---
  static DbCollection get usersCollection => db.collection('users');
  static DbCollection get quizCollection => db.collection('kuis');
  static DbCollection get soalCollection => db.collection('soal');
  static DbCollection get pilihanJawabanCollection => db.collection('pilihan_jawaban');
  static DbCollection get sesiKuisCollection => db.collection('sesi_kuis');
  static DbCollection get pesertaSesiCollection => db.collection('peserta_sesi');
  static DbCollection get jawabanPesertaCollection => db.collection('jawaban_peserta');
  static DbCollection get hasilAkhirCollection => db.collection('hasil_akhir');

  /// Menutup koneksi database
  static Future<void> close() async {
    if (_db != null && _db!.state == State.open) {
      await _db!.close();
      print('Koneksi MongoDB ditutup');
    }
  }
}
