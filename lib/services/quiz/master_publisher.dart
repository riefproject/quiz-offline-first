import 'package:py_4/models/master_payload.dart';
import 'package:py_4/services/quiz/quiz_publisher.dart';

class MasterPublisher extends QuizPublisher<MasterPayload> {
  MasterPublisher({required super.bleService});
}