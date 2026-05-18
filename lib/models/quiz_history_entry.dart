import 'db_models.dart';

class QuizHistoryLeaderboardEntry {
  final String participantName;
  final int score;
  final int rank;

  const QuizHistoryLeaderboardEntry({
    required this.participantName,
    required this.score,
    required this.rank,
  });
}

class QuizHistoryEntry {
  final Quiz quiz;
  final SesiKuis session;
  final int questionCount;
  final int participantCount;
  final List<QuizHistoryLeaderboardEntry> leaderboard;

  const QuizHistoryEntry({
    required this.quiz,
    required this.session,
    required this.questionCount,
    required this.participantCount,
    required this.leaderboard,
  });
}
