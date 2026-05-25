import 'package:flutter/foundation.dart';

import '../../../models/db_models.dart';
import '../../../services/auth_service.dart';
import '../../../services/hive_service.dart';
import '../../../services/quiz_sync_service.dart';

class QuizController extends ChangeNotifier {
  AuthSession get _currentAccount {
    final session = AuthService.currentSession;
    if (session == null || session.isGuest) {
      throw StateError('You must be logged in to manage quizzes.');
    }
    return session;
  }

  bool isOwnedByCurrentUser(Quiz quiz) {
    final session = AuthService.currentSession;
    if (session == null || session.isGuest) return false;

    return quiz.pembuat == session.userId ||
        quiz.pembuat == session.displayName;
  }

  List<Quiz> get quizzes {
    return HiveService.quizBox.values.where(isOwnedByCurrentUser).toList();
  }

  Quiz? getOwnedQuiz(String quizId) {
    final quiz = HiveService.quizBox.get(quizId);
    if (quiz == null || !isOwnedByCurrentUser(quiz)) return null;
    return quiz;
  }

  List<Soal> getQuestionsForQuiz(String quizId) {
    final quiz = HiveService.quizBox.get(quizId);
    if (quiz == null || !isOwnedByCurrentUser(quiz)) {
      return [];
    }

    return HiveService.soalBox.values
        .where((soal) => soal.idQuiz == quizId)
        .toList();
  }

  Future<void> createQuizWithQuestions(
    String judul,
    String deskripsi,
    List<Soal> questions,
  ) async {
    final owner = _currentAccount;
    final quizId = 'quiz_${DateTime.now().millisecondsSinceEpoch}';
    final newQuiz = Quiz(
      id: quizId,
      judul: judul,
      deskripsi: deskripsi,
      pembuat: owner.userId,
      isSynced: false,
    );

    await HiveService.quizBox.put(quizId, newQuiz);

    for (var q in questions) {
      final soalId =
          'soal_${DateTime.now().millisecondsSinceEpoch}_${q.hashCode}';
      final newSoal = q.copyWith(id: soalId, idQuiz: quizId, isSynced: false);
      await HiveService.soalBox.put(soalId, newSoal);
    }

    notifyListeners();
    QuizSyncService().syncNow();
  }

  Future<void> updateQuizWithQuestions(
    String quizId,
    String judul,
    String deskripsi,
    List<Soal> questions,
  ) async {
    final session = _currentAccount;
    final existingQuiz = HiveService.quizBox.get(quizId);
    if (existingQuiz == null || (existingQuiz.pembuat != session.userId && existingQuiz.pembuat != session.displayName)) {
      throw StateError('You do not have permission to modify this quiz.');
    }

    final updatedQuiz = existingQuiz.copyWith(
      judul: judul,
      deskripsi: deskripsi,
      pembuat: session.userId,
      isSynced: false,
    );
    await HiveService.quizBox.put(quizId, updatedQuiz);

    final existingQuestions = getQuestionsForQuiz(quizId);
    for (var q in existingQuestions) {
      await HiveService.soalBox.delete(q.id);
    }

    for (var q in questions) {
      final soalId = q.id.isEmpty
          ? 'soal_${DateTime.now().millisecondsSinceEpoch}_${q.hashCode}'
          : q.id;
      final newSoal = q.copyWith(id: soalId, idQuiz: quizId, isSynced: false);
      await HiveService.soalBox.put(soalId, newSoal);
    }

    notifyListeners();
    QuizSyncService().syncNow();
  }

  Future<void> deleteQuiz(String quizId) async {
    final session = _currentAccount;
    final quiz = HiveService.quizBox.get(quizId);
    if (quiz == null || (quiz.pembuat != session.userId && quiz.pembuat != session.displayName)) {
      throw StateError('You do not have permission to delete this quiz.');
    }

    final questions = getQuestionsForQuiz(quizId);
    for (var q in questions) {
      await HiveService.soalBox.delete(q.id);
    }

    await HiveService.quizBox.delete(quizId);
    notifyListeners();
  }
}
