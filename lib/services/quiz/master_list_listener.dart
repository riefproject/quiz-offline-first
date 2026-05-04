import 'dart:typed_data';

import 'package:AlpenQuiz/models/master_payload.dart';
import 'package:AlpenQuiz/services/logger.dart';
import 'package:AlpenQuiz/services/quiz/quiz_listener.dart';

class MasterListListener extends QuizListener<MasterPayload> {
  MasterListListener({required super.bleService}) : super(typeName: 'MasterListListener');

  @override
  MasterPayload? parseResult(Uint8List data) {
    try {
      final payload = MasterPayload.fromBytes(data);
      return payload;
    } catch (e) {
      log.w('MasterListListener: parse failed — $e');
      return null;
    }
  }
}