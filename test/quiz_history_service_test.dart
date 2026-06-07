import 'dart:io';

import 'package:AlpenQuiz/models/db_models.dart';
import 'package:AlpenQuiz/services/quiz_history_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  final testPath = '${Directory.current.path}/test_quiz_history_hive';

  setUpAll(() async {
    Hive.init(testPath);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AppUserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(QuizAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SoalAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SesiKuisAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(PesertaSesiAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(HasilAkhirAdapter());
    }

    await Hive.openBox<AppUser>('usersBox');
    await Hive.openBox<Quiz>('quizBox');
    await Hive.openBox<Soal>('soalBox');
    await Hive.openBox<SesiKuis>('sesiKuisBox');
    await Hive.openBox<PesertaSesi>('pesertaSesiBox');
    await Hive.openBox<HasilAkhir>('hasilAkhirBox');
  });

  setUp(() async {
    await Hive.box<AppUser>('usersBox').clear();
    await Hive.box<Quiz>('quizBox').clear();
    await Hive.box<Soal>('soalBox').clear();
    await Hive.box<SesiKuis>('sesiKuisBox').clear();
    await Hive.box<PesertaSesi>('pesertaSesiBox').clear();
    await Hive.box<HasilAkhir>('hasilAkhirBox').clear();
  });

  test('loads newest organizer history with leaderboard', () async {
    await Hive.box<Quiz>('quizBox').put(
      'quiz_1',
      Quiz(
        id: 'quiz_1',
        judul: 'Paket Geografi',
        deskripsi: 'Deskripsi',
        pembuat: 'creator_1',
      ),
    );
    await Hive.box<Soal>('soalBox').put(
      'soal_1',
      Soal(
        id: 'soal_1',
        idQuiz: 'quiz_1',
        teksSoal: 'Q1',
        idPilihan: const ['a', 'b'],
        idJawabanBenar: '0',
      ),
    );

    await QuizHistoryService.saveHostedSession(
      quizId: 'quiz_1',
      sessionId: 'sesi_baru',
      startedAt: DateTime(2026, 5, 18, 10, 0),
      finishedAt: DateTime(2026, 5, 18, 10, 15),
      participants: const {1: 'Budi', 2: 'Sinta'},
      scores: const {1: 1200, 2: 900},
    );

    await QuizHistoryService.saveHostedSession(
      quizId: 'quiz_1',
      sessionId: 'sesi_lama',
      startedAt: DateTime(2026, 5, 17, 9, 0),
      finishedAt: DateTime(2026, 5, 17, 9, 12),
      participants: const {3: 'Raka'},
      scores: const {3: 700},
    );

    final history = QuizHistoryService.loadHistoryForCreator('creator_1');

    expect(history.length, equals(2));
    expect(history.first.session.id, equals('sesi_baru'));
    expect(history.first.quiz.judul, equals('Paket Geografi'));
    expect(history.first.questionCount, equals(1));
    expect(history.first.participantCount, equals(2));
    expect(history.first.leaderboard.first.participantName, equals('Budi'));
    expect(history.first.leaderboard.first.rank, equals(1));
    expect(history.first.leaderboard.first.score, equals(1200));
  });

  test('loadHistoryForCreator returns empty list when no history exists', () {
    final history = QuizHistoryService.loadHistoryForCreator('creator_kosong');
    expect(history, isEmpty);
  });

  test('deleteSession removes session and associated data', () async {
    // Save a session first
    await QuizHistoryService.saveHostedSession(
      quizId: 'quiz_hapus',
      sessionId: 'sesi_dihapus',
      startedAt: DateTime.now(),
      finishedAt: DateTime.now(),
      participants: const {1: 'A'},
      scores: const {1: 100},
    );

    // Verify it exists in the box
    expect(Hive.box<SesiKuis>('sesiKuisBox').containsKey('sesi_dihapus'), isTrue);

    // Delete it
    await QuizHistoryService.deleteSession('sesi_dihapus');

    // Verify it is gone
    expect(Hive.box<SesiKuis>('sesiKuisBox').containsKey('sesi_dihapus'), isFalse);
  });

  test('clearAllHistory removes everything from boxes', () async {
    await QuizHistoryService.saveHostedSession(
      quizId: 'quiz_1',
      sessionId: 'sesi_1',
      startedAt: DateTime.now(),
      finishedAt: DateTime.now(),
      participants: const {1: 'A'},
      scores: const {1: 100},
    );
    await QuizHistoryService.saveHostedSession(
      quizId: 'quiz_2',
      sessionId: 'sesi_2',
      startedAt: DateTime.now(),
      finishedAt: DateTime.now(),
      participants: const {2: 'B'},
      scores: const {2: 200},
    );

    expect(Hive.box<SesiKuis>('sesiKuisBox').isNotEmpty, isTrue);
    expect(Hive.box<PesertaSesi>('pesertaSesiBox').isNotEmpty, isTrue);

    await QuizHistoryService.clearAllHistory();

    expect(Hive.box<SesiKuis>('sesiKuisBox').isEmpty, isTrue);
    expect(Hive.box<PesertaSesi>('pesertaSesiBox').isEmpty, isTrue);
    expect(Hive.box<HasilAkhir>('hasilAkhirBox').isEmpty, isTrue);
  });

  tearDownAll(() async {
    await Hive.close();
    final dir = Directory(testPath);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });
}
