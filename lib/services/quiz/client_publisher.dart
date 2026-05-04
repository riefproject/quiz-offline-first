import 'package:AlpenQuiz/models/client_payload.dart';
import 'package:AlpenQuiz/services/quiz/quiz_publisher.dart';

class ClientPublisher extends QuizPublisher<ClientPayload> {
  ClientPublisher({required super.bleService}) : super(typeName: 'ClientPublisher');
}