import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:AlpenQuiz/models/db_models.dart';

void main() {
  // Setup berjalan sebelum semua test dimulai
  setUpAll(() async {
    // Di Unit Test CLI, kita tidak punya Context Android/iOS,
    // jadi kita inisialisasi folder khusus untuk test secara manual.
    final testPath = '${Directory.current.path}/test_hive';
    Hive.init(testPath);
    
    // Register semua Adapter yang sudah tergenerate
    Hive.registerAdapter(AppUserAdapter());
    Hive.registerAdapter(QuizAdapter());
    Hive.registerAdapter(SesiKuisAdapter());
    Hive.registerAdapter(HasilAkhirAdapter());
    Hive.registerAdapter(PesertaSesiAdapter());
    Hive.registerAdapter(SoalAdapter());
    Hive.registerAdapter(PilihanJawabanAdapter());
    Hive.registerAdapter(JawabanPesertaAdapter());
  });

  group('Hive Local Database Unit Tests', () {
    test('Simpan dan Ambil Data Box (Users & Quiz)', () async {
      // 1. Buka Box sementara untuk Test
      final userBox = await Hive.openBox<AppUser>('test_user_box');
      final quizBox = await Hive.openBox<Quiz>('test_quiz_box');

      // 2. Buat Objek Data Dummy
      final userDummy = AppUser(id: 'user_xyz', namaLengkap: 'Tester Hive');
      final quizDummy = Quiz(
        id: 'kuis_456',
        judul: 'Kuis Geografi',
        deskripsi: 'Deskripsi Kuis Test Hive',
        pembuat: userDummy.id,
      );

      // 3. Simpan Data ke Hive (Create / Update)
      await userBox.put(userDummy.id, userDummy);
      await quizBox.put(quizDummy.id, quizDummy);

      // 4. Ambil dan Verifikasi Data dari Hive (Read)
      final fetchedUser = userBox.get('user_xyz');
      expect(fetchedUser, isNotNull, reason: 'Data User dari Hive kosong');
      expect(fetchedUser?.namaLengkap, equals('Tester Hive'), reason: 'Nama lengkap User dari Hive tidak sesuai');

      final fetchedQuiz = quizBox.get('kuis_456');
      expect(fetchedQuiz, isNotNull, reason: 'Data Kuis dari Hive kosong');
      expect(fetchedQuiz?.judul, equals('Kuis Geografi'), reason: 'Nama Kuis dari Hive tidak sesuai');

      // 5. Ubah Data dan Pastikan Keupdate
      // *Catatan: Karena property judul final, kita buat instans baru untuk update
      final updatedQuiz = Quiz(
        id: quizDummy.id,
        judul: 'Kuis Geografi (Updated)',
        deskripsi: quizDummy.deskripsi,
        pembuat: quizDummy.pembuat,
      );
      await quizBox.put(updatedQuiz.id, updatedQuiz);
      expect(quizBox.get('kuis_456')?.judul, equals('Kuis Geografi (Updated)'));

      // 6. Hapus / Bersihkan Data
      await userBox.delete('user_xyz');
      expect(userBox.containsKey('user_xyz'), isFalse);
    });

    test('Menangani custom adapter SesiKuis dan HasilAkhir', () async {
      final sesiBox = await Hive.openBox<SesiKuis>('test_sesi_box');
      
      final sesi = SesiKuis(
        id: 'sesi_123',
        idQuiz: 'quiz_123',
        waktuMulai: DateTime.now(),
        status: 'aktif',
      );
      
      await sesiBox.put(sesi.id, sesi);
      final fetched = sesiBox.get('sesi_123');
      
      expect(fetched, isNotNull);
      expect(fetched?.status, 'aktif');
      
      await sesiBox.clear();
      expect(sesiBox.isEmpty, isTrue);
    });

    test('Mengakses Box yang belum dibuka akan melempar error', () {
      expect(
        () => Hive.box<AppUser>('box_belum_dibuka'),
        throwsA(isA<HiveError>()),
      );
    });

    test('Menghapus seluruh isi Box menggunakan clear()', () async {
      final quizBox = await Hive.openBox<Quiz>('test_clear_quiz_box');
      await quizBox.put('1', Quiz(id: '1', judul: 'A', pembuat: 'B', deskripsi: 'A'));
      await quizBox.put('2', Quiz(id: '2', judul: 'C', pembuat: 'B', deskripsi: 'C'));
      
      expect(quizBox.length, 2);
      
      await quizBox.clear();
      expect(quizBox.isEmpty, isTrue);
    });
  });

  tearDownAll(() async {
    // Menutup koneksi hive
    await Hive.close();
    
    // Cleanup - Menghapus file lokal yang tercipta saat unit testing
    final dir = Directory('${Directory.current.path}/test_hive');
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });
}
