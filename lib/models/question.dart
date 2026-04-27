import 'package:py_4/models/db_models.dart';
import 'package:py_4/services/hive_service.dart';

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    this.correctAnswerIndex = -1,
  });

  static List<Question> fromQuizId(String quizId) {
    final soals = HiveService.soalBox.values
        .where((soal) => soal.idQuiz == quizId)
        .toList();
    return soals.map((soal) => fromSoal(soal)).toList();
  }

  static Question fromSoal(Soal soal) {
    final options = soal.idPilihan.map((id) {
      final pilihan = HiveService.pilihanJawabanBox.get(id);
      return pilihan?.teksPilihan ?? id;
    }).toList();
    final correctIndex = soal.idPilihan.indexOf(soal.idJawabanBenar);
    return Question(
      id: soal.id,
      text: soal.teksSoal,
      options: options,
      correctAnswerIndex: correctIndex,
    );
  }
}