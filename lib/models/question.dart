import 'package:AlpenQuiz/models/db_models.dart';
import 'package:AlpenQuiz/services/hive_service.dart';


class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String? photoUrl;
  final String? localPhotoPath;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    this.correctAnswerIndex = -1,
    this.photoUrl,
    this.localPhotoPath,
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
    final correctIndex = int.parse(soal.idJawabanBenar);

    return Question(
      id: soal.id,
      text: soal.teksSoal,
      options: options,
      correctAnswerIndex: correctIndex,
      photoUrl: soal.fotoSoal,
      localPhotoPath: soal.localFotoPath,
    );
  }
}
