import 'package:hive_flutter/hive_flutter.dart';
import '../models/db_models.dart';

class HiveService {
  static const String _usersBox = 'usersBox';
  static const String _sessionBox = 'sessionBox';
  static const String _quizBox = 'quizBox';
  static const String _soalBox = 'soalBox';
  static const String _pilihanJawabanBox = 'pilihanJawabanBox';
  static const String _sesiKuisBox = 'sesiKuisBox';
  static const String _pesertaSesiBox = 'pesertaSesiBox';
  static const String _jawabanPesertaBox = 'jawabanPesertaBox';
  static const String _hasilAkhirBox = 'hasilAkhirBox';

  static Future<void> init() async {
    // Inisialisasi storage lokal HP untuk Hive
    await Hive.initFlutter();

    // Mendaftarkan Adapter yang telah digenerate (Hive membutuhkan id tipe untuk menyusun binary objects)
    Hive.registerAdapter(AppUserAdapter());
    Hive.registerAdapter(QuizAdapter());
    Hive.registerAdapter(SoalAdapter());
    Hive.registerAdapter(PilihanJawabanAdapter());
    Hive.registerAdapter(SesiKuisAdapter());
    Hive.registerAdapter(PesertaSesiAdapter());
    Hive.registerAdapter(JawabanPesertaAdapter());
    Hive.registerAdapter(HasilAkhirAdapter());

    // Membuka semua kotak (boxes) yang diperlukan aplikasi
    await Future.wait([
      Hive.openBox<AppUser>(_usersBox),
      Hive.openBox(_sessionBox),
      Hive.openBox<Quiz>(_quizBox),
      Hive.openBox<Soal>(_soalBox),
      Hive.openBox<PilihanJawaban>(_pilihanJawabanBox),
      Hive.openBox<SesiKuis>(_sesiKuisBox),
      Hive.openBox<PesertaSesi>(_pesertaSesiBox),
      Hive.openBox<JawabanPeserta>(_jawabanPesertaBox),
      Hive.openBox<HasilAkhir>(_hasilAkhirBox),
    ]);
    
    print('Hive Local Database Berhasil Diinisialisasi');
  }

  // --- Akses Boxes ---
  static Box<AppUser> get usersBox => Hive.box<AppUser>(_usersBox);
  static Box get sessionBox => Hive.box(_sessionBox);
  static Box<Quiz> get quizBox => Hive.box<Quiz>(_quizBox);
  static Box<Soal> get soalBox => Hive.box<Soal>(_soalBox);
  static Box<PilihanJawaban> get pilihanJawabanBox => Hive.box<PilihanJawaban>(_pilihanJawabanBox);
  static Box<SesiKuis> get sesiKuisBox => Hive.box<SesiKuis>(_sesiKuisBox);
  static Box<PesertaSesi> get pesertaSesiBox => Hive.box<PesertaSesi>(_pesertaSesiBox);
  static Box<JawabanPeserta> get jawabanPesertaBox => Hive.box<JawabanPeserta>(_jawabanPesertaBox);
  static Box<HasilAkhir> get hasilAkhirBox => Hive.box<HasilAkhir>(_hasilAkhirBox);

  /// Menutup seluruh koneksi Hive (biasanya dipakai sebelum aplikasi dimatikan / dispose)
  static Future<void> close() async {
    await Hive.close();
    print('Koneksi Hive ditutup');
  }

  /// Membersihkan penyimpanan lokal dari memori (Clear Cache).
  static Future<void> clearAllData() async {
    await usersBox.clear();
    await sessionBox.clear();
    await quizBox.clear();
    await soalBox.clear();
    await pilihanJawabanBox.clear();
    await sesiKuisBox.clear();
    await pesertaSesiBox.clear();
    await jawabanPesertaBox.clear();
    await hasilAkhirBox.clear();
    print('Semua data di dalam Hive telah dibersihkan');
  }
}
