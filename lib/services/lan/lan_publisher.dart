import 'package:AlpenQuiz/models/byte_serializable.dart';
import 'package:AlpenQuiz/services/logger.dart';

abstract class LanPublisher<T extends ByteSerializable> {
  final String _typeName;

  LanPublisher({required String typeName}) : _typeName = typeName;

  void publish(T data);

  void dispose() {
    log.d('LanPublisher($_typeName): disposed');
  }
}
