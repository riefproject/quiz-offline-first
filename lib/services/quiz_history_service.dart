import '../models/db_models.dart';
import '../models/quiz_history_entry.dart';
import 'hive_service.dart';

class QuizHistoryService {
  const QuizHistoryService._();

  static String buildHostedParticipantUserId({
    required String sessionId,
    required int clientId,
  }) {
    return 'hosted_${sessionId}_$clientId';
  }

  static Future<Map<int, int>> saveHostedSession({
    required String quizId,
    required String sessionId,
    required DateTime startedAt,
    required DateTime finishedAt,
    required Map<int, String> participants,
    required Map<int, int> scores,
  }) async {
    final rankMap = _computeRanks(scores, participants.keys.toList());

    await HiveService.sesiKuisBox.put(
      sessionId,
      SesiKuis(
        id: sessionId,
        idQuiz: quizId,
        waktuMulai: startedAt,
        waktuSelesai: finishedAt,
        status: 'selesai',
      ),
    );

    final userEntries = <String, AppUser>{};
    final pesertaEntries = <String, PesertaSesi>{};
    final hasilEntries = <String, HasilAkhir>{};

    for (final participant in participants.entries) {
      final clientId = participant.key;
      final participantName = participant.value.trim().isEmpty
          ? 'Peserta $clientId'
          : participant.value.trim();
      final hostedUserId = buildHostedParticipantUserId(
        sessionId: sessionId,
        clientId: clientId,
      );
      final score = scores[clientId] ?? 0;
      final rank = rankMap[clientId] ?? participants.length;

      userEntries[hostedUserId] = AppUser(
        id: hostedUserId,
        namaLengkap: participantName,
        isGuest: true,
        isSynced: true,
      );
      pesertaEntries['peserta_${sessionId}_$clientId'] = PesertaSesi(
        id: 'peserta_${sessionId}_$clientId',
        idSesi: sessionId,
        idUser: hostedUserId,
      );
      hasilEntries['hasil_${sessionId}_$clientId'] = HasilAkhir(
        id: 'hasil_${sessionId}_$clientId',
        idSesi: sessionId,
        idUser: hostedUserId,
        totalSkor: score,
        peringkat: rank,
      );
    }

    await HiveService.usersBox.putAll(userEntries);
    await HiveService.pesertaSesiBox.putAll(pesertaEntries);
    await HiveService.hasilAkhirBox.putAll(hasilEntries);

    return rankMap;
  }

  static List<QuizHistoryEntry> loadHistoryForCreator(String creatorUserId) {
    final quizzes = HiveService.quizBox.values
        .where((quiz) => quiz.pembuat == creatorUserId)
        .toList(growable: false);
    final quizzesById = {
      for (final quiz in quizzes) quiz.id: quiz,
    };

    final sessions = HiveService.sesiKuisBox.values
        .where((session) => quizzesById.containsKey(session.idQuiz))
        .toList()
      ..sort((left, right) => right.waktuMulai.compareTo(left.waktuMulai));

    return sessions.map((session) {
      final quiz = quizzesById[session.idQuiz]!;
      final questionCount = HiveService.soalBox.values
          .where((soal) => soal.idQuiz == quiz.id)
          .length;
      final peserta = HiveService.pesertaSesiBox.values
          .where((participant) => participant.idSesi == session.id)
          .toList(growable: false);
      final results = HiveService.hasilAkhirBox.values
          .where((result) => result.idSesi == session.id)
          .toList()
        ..sort((left, right) {
          final rankComparison = left.peringkat.compareTo(right.peringkat);
          if (rankComparison != 0) {
            return rankComparison;
          }
          return right.totalSkor.compareTo(left.totalSkor);
        });

      final leaderboard = results.map((result) {
        final participantUser = HiveService.usersBox.get(result.idUser);
        return QuizHistoryLeaderboardEntry(
          participantName: participantUser?.namaLengkap ?? result.idUser,
          score: result.totalSkor,
          rank: result.peringkat,
        );
      }).toList(growable: false);

      return QuizHistoryEntry(
        quiz: quiz,
        session: session,
        questionCount: questionCount,
        participantCount: peserta.length,
        leaderboard: leaderboard,
      );
    }).toList(growable: false);
  }

  static List<QuizHistoryEntry> loadHistoryForQuiz(String quizId) {
    final quiz = HiveService.quizBox.get(quizId);
    if (quiz == null) {
      return const [];
    }

    final sessions = HiveService.sesiKuisBox.values
        .where((session) => session.idQuiz == quizId)
        .toList()
      ..sort((left, right) => right.waktuMulai.compareTo(left.waktuMulai));

    return sessions.map((session) {
      final questionCount = HiveService.soalBox.values
          .where((soal) => soal.idQuiz == quiz.id)
          .length;
      final peserta = HiveService.pesertaSesiBox.values
          .where((participant) => participant.idSesi == session.id)
          .toList(growable: false);
      final results = HiveService.hasilAkhirBox.values
          .where((result) => result.idSesi == session.id)
          .toList()
        ..sort((left, right) {
          final rankComparison = left.peringkat.compareTo(right.peringkat);
          if (rankComparison != 0) {
            return rankComparison;
          }
          return right.totalSkor.compareTo(left.totalSkor);
        });

      final leaderboard = results.map((result) {
        final participantUser = HiveService.usersBox.get(result.idUser);
        return QuizHistoryLeaderboardEntry(
          participantName: participantUser?.namaLengkap ?? result.idUser,
          score: result.totalSkor,
          rank: result.peringkat,
        );
      }).toList(growable: false);

      return QuizHistoryEntry(
        quiz: quiz,
        session: session,
        questionCount: questionCount,
        participantCount: peserta.length,
        leaderboard: leaderboard,
      );
    }).toList(growable: false);
  }

  static Map<int, int> _computeRanks(
    Map<int, int> scores,
    List<int> participantIds,
  ) {
    final rows = participantIds
        .map((clientId) => (clientId: clientId, score: scores[clientId] ?? 0))
        .toList()
      ..sort((left, right) {
        final scoreComparison = right.score.compareTo(left.score);
        if (scoreComparison != 0) {
          return scoreComparison;
        }
        return left.clientId.compareTo(right.clientId);
      });

    return {
      for (var index = 0; index < rows.length; index++)
        rows[index].clientId: index + 1,
    };
  }
}
