import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:py_4/models/db_models.dart';

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
