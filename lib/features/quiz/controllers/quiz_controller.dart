import 'package:flutter/foundation.dart';

import '../../../models/db_models.dart';
import '../../../services/hive_service.dart';
import '../../../services/quiz_sync_service.dart';

class QuizController extends ChangeNotifier {
  List<Quiz> get quizzes => HiveService.quizBox.values.toList();

  List<Soal> getQuestionsForQuiz(String quizId) {
    return HiveService.soalBox.values
        .where((soal) => soal.idQuiz == quizId)
        .toList();
  }

  Future<void> createQuizWithQuestions(
    String judul,
    String deskripsi,
    String pembuat,
    List<Soal> questions,
  ) async {
    final quizId = 'quiz_${DateTime.now().millisecondsSinceEpoch}';
    final newQuiz = Quiz(
      id: quizId,
      judul: judul,
      deskripsi: deskripsi,
      pembuat: pembuat,
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
    String pembuat,
    List<Soal> questions,
  ) async {
    final existingQuiz = HiveService.quizBox.get(quizId);
    if (existingQuiz != null) {
      final updatedQuiz = existingQuiz.copyWith(
        judul: judul,
        deskripsi: deskripsi,
        pembuat: pembuat,
        isSynced: false,
      );
      await HiveService.quizBox.put(quizId, updatedQuiz);
    }

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
    // Delete all questions associated with the quiz
    final questions = getQuestionsForQuiz(quizId);
    for (var q in questions) {
      await HiveService.soalBox.delete(q.id);
    }
    // Delete the quiz
    await HiveService.quizBox.delete(quizId);
    notifyListeners();
  }
}
