import 'dart:io';

import 'package:AlpenQuiz/models/client_payload.dart';
import 'package:AlpenQuiz/models/db_models.dart';
import 'package:AlpenQuiz/models/reverse_qr_submission.dart';
import 'package:AlpenQuiz/services/reverse_qr_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  final testPath = '${Directory.current.path}/test_reverse_qr_hive';

  setUpAll(() async {
    Hive.init(testPath);
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SoalAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SesiKuisAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(PesertaSesiAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(JawabanPesertaAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(HasilAkhirAdapter());
    }

    await Hive.openBox<Soal>('soalBox');
    await Hive.openBox<SesiKuis>('sesiKuisBox');
    await Hive.openBox<PesertaSesi>('pesertaSesiBox');
    await Hive.openBox<JawabanPeserta>('jawabanPesertaBox');
    await Hive.openBox<HasilAkhir>('hasilAkhirBox');
  });

  setUp(() async {
    await Hive.box<Soal>('soalBox').clear();
    await Hive.box<SesiKuis>('sesiKuisBox').clear();
    await Hive.box<PesertaSesi>('pesertaSesiBox').clear();
    await Hive.box<JawabanPeserta>('jawabanPesertaBox').clear();
    await Hive.box<HasilAkhir>('hasilAkhirBox').clear();
  });

  test('encodes and decodes reverse QR submission', () {
    final submission = ReverseQrSubmission.fromClientAnswers(
      participantUserId: 'user_1',
      participantName: 'Mahasiswa 1',
      gameId: 123456,
      clientId: 77,
      answers: const [
        ClientAnswer(answer: 0, answerMsOffset: 5200),
        ClientAnswer(answer: -1, answerMsOffset: 0),
      ],
      createdAtMs: 1000,
    );

    final payload = ReverseQrSyncService.encodeSubmission(submission);
    final decoded = ReverseQrSyncService.decodeSubmission(payload);

    expect(payload, isNotEmpty);
    expect(decoded.participantUserId, equals('user_1'));
    expect(decoded.participantName, equals('Mahasiswa 1'));
    expect(decoded.gameId, equals(123456));
    expect(decoded.clientId, equals(77));
    expect(decoded.answers.length, equals(2));
    expect(decoded.submittedAnswerCount, equals(1));
  });

  test('imports scanned submission into hive and computes score', () async {
    final soalBox = Hive.box<Soal>('soalBox');
    await soalBox.put(
      'soal_1',
      Soal(
        id: 'soal_1',
        idQuiz: 'quiz_1',
        teksSoal: 'Q1',
        idPilihan: const ['opsi_a', 'opsi_b'],
        idJawabanBenar: '0',
      ),
    );
    await soalBox.put(
      'soal_2',
      Soal(
        id: 'soal_2',
        idQuiz: 'quiz_1',
        teksSoal: 'Q2',
        idPilihan: const ['opsi_c', 'opsi_d'],
        idJawabanBenar: '1',
      ),
    );

    final submission = ReverseQrSubmission.fromClientAnswers(
      participantUserId: 'user_2',
      participantName: 'Mahasiswa 2',
      gameId: 123456,
      clientId: 88,
      answers: const [
        ClientAnswer(answer: 0, answerMsOffset: 6000),
        ClientAnswer(answer: 1, answerMsOffset: 17000),
      ],
      createdAtMs: 1000,
    );

    final result = await ReverseQrSyncService.importSubmission(
      submission: submission,
      quizId: 'quiz_1',
      sessionId: 'sesi_123456',
      sessionStartedAt: DateTime(2026, 5, 18),
      sessionFinishedAt: DateTime(2026, 5, 18, 0, 10),
      questionStartOffsets: const [5000, 15000],
      questionDurations: const [10000, 10000],
      existingScores: const {99: 500},
    );

    final jawabanBox = Hive.box<JawabanPeserta>('jawabanPesertaBox');
    final hasilBox = Hive.box<HasilAkhir>('hasilAkhirBox');

    expect(result.importedAnswerCount, equals(2));
    expect(result.totalScore, greaterThan(0));
    expect(result.rank, equals(1));
    expect(jawabanBox.length, equals(2));
    expect(hasilBox.length, equals(1));
    expect(hasilBox.values.first.totalSkor, equals(result.totalScore));
  });

  tearDownAll(() async {
    await Hive.close();
    final dir = Directory(testPath);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });
}
