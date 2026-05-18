import 'dart:convert';
import 'dart:io';

import '../models/db_models.dart';
import '../models/reverse_qr_submission.dart';
import 'hive_service.dart';

class ReverseQrSyncService {
  const ReverseQrSyncService._();

  static String encodeSubmission(ReverseQrSubmission submission) {
    final jsonPayload = jsonEncode(submission.toJson());
    final compressedBytes = GZipCodec(
      level: ZLibOption.maxLevel,
    ).encode(utf8.encode(jsonPayload));

    return base64Url.encode(compressedBytes).replaceAll('=', '');
  }

  static ReverseQrSubmission decodeSubmission(String payload) {
    try {
      final normalizedPayload = _normalizeBase64Payload(payload.trim());
      final compressedBytes = base64Url.decode(normalizedPayload);
      final jsonBytes = gzip.decode(compressedBytes);
      final decodedJson = jsonDecode(utf8.decode(jsonBytes));

      if (decodedJson is Map<String, dynamic>) {
        return ReverseQrSubmission.fromJson(decodedJson);
      }
      if (decodedJson is Map) {
        return ReverseQrSubmission.fromJson(
          Map<String, dynamic>.from(decodedJson),
        );
      }

      throw const FormatException('Reverse QR payload is not a JSON object');
    } on FormatException catch (error, stackTrace) {
      throw ReverseQrSyncException(
        'QR tidak valid atau datanya tidak lengkap.',
        cause: error,
        stackTrace: stackTrace,
      );
    } on Object catch (error, stackTrace) {
      throw ReverseQrSyncException(
        'Gagal membaca payload dari QR.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<ReverseQrImportResult> importSubmission({
    required ReverseQrSubmission submission,
    required String quizId,
    required String sessionId,
    required DateTime sessionStartedAt,
    required DateTime? sessionFinishedAt,
    required List<int> questionStartOffsets,
    required List<int> questionDurations,
    required Map<int, int> existingScores,
  }) async {
    final soals = HiveService.soalBox.values
        .where((soal) => soal.idQuiz == quizId)
        .toList(growable: false);

    if (soals.isEmpty) {
      throw const ReverseQrSyncException(
        'Quiz belum memiliki soal lokal di perangkat pengajar.',
      );
    }

    final importedAnswers = <JawabanPeserta>[];
    var totalScore = 0;

    for (final answer in submission.answers) {
      if (answer.questionIndex < 0 || answer.questionIndex >= soals.length) {
        throw ReverseQrSyncException(
          'Nomor soal ${answer.questionIndex + 1} tidak cocok dengan quiz pengajar.',
        );
      }

      final soal = soals[answer.questionIndex];

      if (answer.answerIndex < 0) {
        continue;
      }
      if (answer.answerIndex >= soal.idPilihan.length) {
        throw ReverseQrSyncException(
          'Pilihan jawaban untuk soal ${answer.questionIndex + 1} tidak valid.',
        );
      }

      importedAnswers.add(
        JawabanPeserta(
          id: _buildAnswerId(
            sessionId: sessionId,
            clientId: submission.clientId,
            questionIndex: answer.questionIndex,
          ),
          idSesi: sessionId,
          idUser: submission.participantUserId,
          idSoal: soal.id,
          idPilihanJawaban: soal.idPilihan[answer.answerIndex],
          waktuMenjawab: answer.answerMsOffset,
        ),
      );

      final correctIndex = int.tryParse(soal.idJawabanBenar) ?? -1;
      if (correctIndex == answer.answerIndex) {
        final questionStart = answer.questionIndex < questionStartOffsets.length
            ? questionStartOffsets[answer.questionIndex]
            : 0;
        final questionDuration =
            answer.questionIndex < questionDurations.length &&
                questionDurations[answer.questionIndex] > 0
            ? questionDurations[answer.questionIndex]
            : 10000;
        final speedBonus =
            (1 - ((answer.answerMsOffset - questionStart) / questionDuration)) *
            500;
        totalScore += (1000 + speedBonus.clamp(0, 500)).toInt();
      }
    }

    final updatedScores = Map<int, int>.from(existingScores)
      ..[submission.clientId] = totalScore;
    final rankedScores = updatedScores.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    final rank =
        rankedScores.indexWhere((entry) => entry.key == submission.clientId) +
        1;

    final session = SesiKuis(
      id: sessionId,
      idQuiz: quizId,
      waktuMulai: sessionStartedAt,
      waktuSelesai: sessionFinishedAt ?? DateTime.now(),
      status: 'selesai',
    );
    final peserta = PesertaSesi(
      id: _buildParticipantId(sessionId, submission.participantUserId),
      idSesi: sessionId,
      idUser: submission.participantUserId,
    );
    final hasilAkhir = HasilAkhir(
      id: _buildResultId(sessionId, submission.participantUserId),
      idSesi: sessionId,
      idUser: submission.participantUserId,
      totalSkor: totalScore,
      peringkat: rank,
    );

    await HiveService.sesiKuisBox.put(session.id, session);
    await HiveService.pesertaSesiBox.put(peserta.id, peserta);
    await HiveService.jawabanPesertaBox.putAll({
      for (final answer in importedAnswers) answer.id: answer,
    });
    await HiveService.hasilAkhirBox.put(hasilAkhir.id, hasilAkhir);

    return ReverseQrImportResult(
      importedAnswerCount: importedAnswers.length,
      totalScore: totalScore,
      rank: rank,
      participantName: submission.participantName,
    );
  }

  static String _normalizeBase64Payload(String payload) {
    if (payload.isEmpty) {
      throw const FormatException('Reverse QR payload is empty');
    }

    final remainder = payload.length % 4;
    if (remainder == 0) {
      return payload;
    }

    return '$payload${'=' * (4 - remainder)}';
  }

  static String _buildAnswerId({
    required String sessionId,
    required int clientId,
    required int questionIndex,
  }) {
    return 'jawaban_${sessionId}_${clientId}_$questionIndex';
  }

  static String _buildParticipantId(String sessionId, String participantUserId) {
    return 'peserta_${sessionId}_$participantUserId';
  }

  static String _buildResultId(String sessionId, String participantUserId) {
    return 'hasil_${sessionId}_$participantUserId';
  }
}

class ReverseQrSyncException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const ReverseQrSyncException(
    this.message, {
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() => message;
}
