import 'package:py_4/models/client_payload.dart';
import 'package:py_4/services/quiz/quiz_publisher.dart';

class ClientPublisher extends QuizPublisher<ClientPayload> {
  ClientPublisher({required super.bleService});
}