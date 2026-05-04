import 'package:AlpenQuiz/models/master_payload.dart';
import 'package:AlpenQuiz/services/quiz/quiz_publisher.dart';

class MasterPublisher extends QuizPublisher<MasterPayload> {
  MasterPublisher({required super.bleService}) : super(typeName: 'MasterPublisher');
}