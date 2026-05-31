import 'dart:io';

import 'package:AlpenQuiz/features/quiz/controllers/quiz_controller.dart';
import 'package:AlpenQuiz/models/db_models.dart';
import 'package:AlpenQuiz/services/auth_service.dart';
import 'package:AlpenQuiz/services/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  Future<void> seedSession({
    required String userId,
    required String displayName,
    bool isGuest = false,
    String role = 'account',
  }) async {
    SharedPreferences.setMockInitialValues({
      'current_user_id': userId,
      'current_user_name': displayName,
      'current_user_is_guest': isGuest,
      'current_user_role': role,
    });

    AuthService.init(await SharedPreferences.getInstance());
  }

  Quiz buildQuiz({
    required String id,
    required String judul,
    required String deskripsi,
    required String pembuat,
    bool isSynced = true,
  }) {
    return Quiz(
      id: id,
      judul: judul,
      deskripsi: deskripsi,
      pembuat: pembuat,
      isSynced: isSynced,
    );
  }

  Soal buildSoal({
    required String id,
    required String idQuiz,
    required String teksSoal,
    List<String> idPilihan = const ['a', 'b', 'c'],
    String idJawabanBenar = 'a',
    bool isSynced = true,
  }) {
    return Soal(
      id: id,
      idQuiz: idQuiz,
      teksSoal: teksSoal,
      idPilihan: idPilihan,
      idJawabanBenar: idJawabanBenar,
      isSynced: isSynced,
    );
  }

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('quiz_controller_test_');
    Hive.init(tempDir.path);

    Hive.registerAdapter(QuizAdapter());
    Hive.registerAdapter(SoalAdapter());

    await Hive.openBox<Quiz>('quizBox');
    await Hive.openBox<Soal>('soalBox');
  });

  setUp(() async {
    await HiveService.quizBox.clear();
    await HiveService.soalBox.clear();
    await seedSession(userId: 'user-1', displayName: 'Nama Owner');
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('QuizController', () {
    test('mengidentifikasi kepemilikan berdasarkan userId dan displayName', () async {
      final controller = QuizController();
      final ownedById = buildQuiz(
        id: 'quiz-1',
        judul: 'Owned by id',
        deskripsi: 'desc',
        pembuat: 'user-1',
      );
      final ownedByName = buildQuiz(
        id: 'quiz-2',
        judul: 'Owned by name',
        deskripsi: 'desc',
        pembuat: 'Nama Owner',
      );
      final otherQuiz = buildQuiz(
        id: 'quiz-3',
        judul: 'Other',
        deskripsi: 'desc',
        pembuat: 'user-9',
      );

      expect(controller.isOwnedByCurrentUser(ownedById), isTrue);
      expect(controller.isOwnedByCurrentUser(ownedByName), isTrue);
      expect(controller.isOwnedByCurrentUser(otherQuiz), isFalse);
    });

    test('guest tidak dianggap pemilik konten apa pun', () async {
      await seedSession(userId: 'guest-1', displayName: 'Tamu', isGuest: true, role: 'guest');

      final controller = QuizController();
      final quiz = buildQuiz(
        id: 'quiz-guest',
        judul: 'Guest Quiz',
        deskripsi: 'desc',
        pembuat: 'guest-1',
      );

      expect(controller.isOwnedByCurrentUser(quiz), isFalse);
      expect(controller.quizzes, isEmpty);
      expect(controller.getOwnedQuiz('quiz-guest'), isNull);
      expect(controller.getQuestionsForQuiz('quiz-guest'), isEmpty);
    });

    test('quizzes hanya menampilkan kuis milik sesi aktif', () async {
      final controller = QuizController();
      final ownedById = buildQuiz(
        id: 'quiz-1',
        judul: 'Owned by id',
        deskripsi: 'desc',
        pembuat: 'user-1',
      );
      final ownedByName = buildQuiz(
        id: 'quiz-2',
        judul: 'Owned by name',
        deskripsi: 'desc',
        pembuat: 'Nama Owner',
      );
      final otherQuiz = buildQuiz(
        id: 'quiz-3',
        judul: 'Other',
        deskripsi: 'desc',
        pembuat: 'user-9',
      );

      await HiveService.quizBox.put(ownedById.id, ownedById);
      await HiveService.quizBox.put(ownedByName.id, ownedByName);
      await HiveService.quizBox.put(otherQuiz.id, otherQuiz);

      expect(
        controller.quizzes.map((quiz) => quiz.id),
        unorderedEquals(['quiz-1', 'quiz-2']),
      );
    });

    test('getOwnedQuiz dan getQuestionsForQuiz aman untuk data tidak ada atau bukan milik sendiri', () async {
      final controller = QuizController();
      final ownedQuiz = buildQuiz(
        id: 'quiz-owned',
        judul: 'Owned',
        deskripsi: 'desc',
        pembuat: 'user-1',
      );
      final foreignQuiz = buildQuiz(
        id: 'quiz-foreign',
        judul: 'Foreign',
        deskripsi: 'desc',
        pembuat: 'user-9',
      );
      final ownedQuestion = buildSoal(
        id: 'soal-1',
        idQuiz: ownedQuiz.id,
        teksSoal: 'Pertanyaan 1',
      );
      final foreignQuestion = buildSoal(
        id: 'soal-2',
        idQuiz: foreignQuiz.id,
        teksSoal: 'Pertanyaan 2',
      );

      await HiveService.quizBox.put(ownedQuiz.id, ownedQuiz);
      await HiveService.quizBox.put(foreignQuiz.id, foreignQuiz);
      await HiveService.soalBox.put(ownedQuestion.id, ownedQuestion);
      await HiveService.soalBox.put(foreignQuestion.id, foreignQuestion);

      expect(controller.getOwnedQuiz(ownedQuiz.id), isNotNull);
      expect(controller.getOwnedQuiz(foreignQuiz.id), isNull);
      expect(controller.getOwnedQuiz('missing-quiz'), isNull);
      expect(controller.getQuestionsForQuiz(ownedQuiz.id).map((soal) => soal.id), contains('soal-1'));
      expect(controller.getQuestionsForQuiz(foreignQuiz.id), isEmpty);
      expect(controller.getQuestionsForQuiz('missing-quiz'), isEmpty);
    });

    test('createQuizWithQuestions menyimpan kuis dan soal baru lalu memicu notifyListeners', () async {
      final controller = QuizController();
      var notified = 0;
      controller.addListener(() => notified++);

      final questions = [
        buildSoal(id: '', idQuiz: '', teksSoal: 'Pertanyaan A', isSynced: false),
        buildSoal(id: '', idQuiz: '', teksSoal: 'Pertanyaan B', isSynced: false),
      ];

      await controller.createQuizWithQuestions(
        'Quiz Baru',
        'Deskripsi baru',
        questions,
      );

      expect(notified, 1);
      expect(HiveService.quizBox.values, hasLength(1));

      final createdQuiz = HiveService.quizBox.values.single;
      expect(createdQuiz.judul, 'Quiz Baru');
      expect(createdQuiz.deskripsi, 'Deskripsi baru');
      expect(createdQuiz.pembuat, 'user-1');
      expect(createdQuiz.isSynced, isFalse);

      final createdQuestions = HiveService.soalBox.values.toList();
      expect(createdQuestions, hasLength(2));
      expect(createdQuestions.map((soal) => soal.idQuiz).toSet(), {createdQuiz.id});
      expect(createdQuestions.every((soal) => soal.isSynced == false), isTrue);
    });

    test('createQuizWithQuestions tetap membuat kuis saat daftar soal kosong', () async {
      final controller = QuizController();

      await controller.createQuizWithQuestions(
        'Quiz Kosong',
        'Tidak ada soal',
        const [],
      );

      expect(HiveService.quizBox.values, hasLength(1));
      expect(HiveService.soalBox.values, isEmpty);
      expect(controller.getQuestionsForQuiz(HiveService.quizBox.values.single.id), isEmpty);
    });

    test('updateQuizWithQuestions mengubah metadata, mengganti soal lama, dan mendukung pemilik via displayName', () async {
      final controller = QuizController();
      var notified = 0;
      controller.addListener(() => notified++);

      final existingQuiz = buildQuiz(
        id: 'quiz-update',
        judul: 'Lama',
        deskripsi: 'Deskripsi lama',
        pembuat: 'Nama Owner',
      );
      final oldQuestion = buildSoal(
        id: 'soal-old',
        idQuiz: existingQuiz.id,
        teksSoal: 'Soal lama',
      );
      final replacementQuestions = [
        buildSoal(id: '', idQuiz: '', teksSoal: 'Soal baru 1', isSynced: false),
        buildSoal(id: 'soal-manual', idQuiz: '', teksSoal: 'Soal baru 2', isSynced: false),
      ];

      await HiveService.quizBox.put(existingQuiz.id, existingQuiz);
      await HiveService.soalBox.put(oldQuestion.id, oldQuestion);

      await controller.updateQuizWithQuestions(
        existingQuiz.id,
        'Baru',
        'Deskripsi baru',
        replacementQuestions,
      );

      expect(notified, 1);

      final updatedQuiz = HiveService.quizBox.get(existingQuiz.id);
      expect(updatedQuiz, isNotNull);
      expect(updatedQuiz?.judul, 'Baru');
      expect(updatedQuiz?.deskripsi, 'Deskripsi baru');
      expect(updatedQuiz?.pembuat, 'user-1');
      expect(updatedQuiz?.isSynced, isFalse);

      expect(HiveService.soalBox.containsKey(oldQuestion.id), isFalse);
      final updatedQuestions = HiveService.soalBox.values.where((soal) => soal.idQuiz == existingQuiz.id).toList();
      expect(updatedQuestions, hasLength(2));
      expect(updatedQuestions.any((soal) => soal.id == 'soal-manual'), isTrue);
      expect(updatedQuestions.every((soal) => soal.isSynced == false), isTrue);
    });

    test('updateQuizWithQuestions menghapus semua soal lama ketika pengganti kosong', () async {
      final controller = QuizController();
      final existingQuiz = buildQuiz(
        id: 'quiz-clear',
        judul: 'Lama',
        deskripsi: 'Deskripsi lama',
        pembuat: 'user-1',
      );
      final oldQuestion = buildSoal(
        id: 'soal-old-1',
        idQuiz: existingQuiz.id,
        teksSoal: 'Soal lama 1',
      );

      await HiveService.quizBox.put(existingQuiz.id, existingQuiz);
      await HiveService.soalBox.put(oldQuestion.id, oldQuestion);

      await controller.updateQuizWithQuestions(
        existingQuiz.id,
        'Lama tetap',
        'Deskripsi tetap',
        const [],
      );

      expect(HiveService.soalBox.values.where((soal) => soal.idQuiz == existingQuiz.id), isEmpty);
    });

    test('updateQuizWithQuestions menolak kuis yang tidak dimiliki', () async {
      final controller = QuizController();
      final foreignQuiz = buildQuiz(
        id: 'quiz-foreign',
        judul: 'Lama',
        deskripsi: 'Deskripsi lama',
        pembuat: 'user-9',
      );

      await HiveService.quizBox.put(foreignQuiz.id, foreignQuiz);

      expect(
        () => controller.updateQuizWithQuestions(
          foreignQuiz.id,
          'Baru',
          'Deskripsi baru',
          const [],
        ),
        throwsStateError,
      );

      expect(
        () => controller.updateQuizWithQuestions(
          'missing-quiz',
          'Baru',
          'Deskripsi baru',
          const [],
        ),
        throwsStateError,
      );
    });

    test('deleteQuiz menghapus kuis beserta seluruh soalnya', () async {
      final controller = QuizController();
      var notified = 0;
      controller.addListener(() => notified++);

      final quiz = buildQuiz(
        id: 'quiz-delete',
        judul: 'Hapus',
        deskripsi: 'Deskripsi hapus',
        pembuat: 'user-1',
      );
      final question1 = buildSoal(
        id: 'soal-del-1',
        idQuiz: quiz.id,
        teksSoal: 'Soal hapus 1',
      );
      final question2 = buildSoal(
        id: 'soal-del-2',
        idQuiz: quiz.id,
        teksSoal: 'Soal hapus 2',
      );

      await HiveService.quizBox.put(quiz.id, quiz);
      await HiveService.soalBox.put(question1.id, question1);
      await HiveService.soalBox.put(question2.id, question2);

      await controller.deleteQuiz(quiz.id);

      expect(notified, 1);
      expect(HiveService.quizBox.containsKey(quiz.id), isFalse);
      expect(HiveService.soalBox.containsKey(question1.id), isFalse);
      expect(HiveService.soalBox.containsKey(question2.id), isFalse);
    });

    test('deleteQuiz menolak kuis yang tidak dimiliki atau tidak ada', () async {
      final controller = QuizController();
      final foreignQuiz = buildQuiz(
        id: 'quiz-foreign',
        judul: 'Hapus',
        deskripsi: 'Deskripsi hapus',
        pembuat: 'user-9',
      );

      await HiveService.quizBox.put(foreignQuiz.id, foreignQuiz);

      expect(() => controller.deleteQuiz(foreignQuiz.id), throwsStateError);
      expect(() => controller.deleteQuiz('missing-quiz'), throwsStateError);
    });
  });
}