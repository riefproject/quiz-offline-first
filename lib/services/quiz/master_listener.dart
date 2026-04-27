import 'dart:typed_data';

import 'package:py_4/models/master_payload.dart';
import 'package:py_4/services/logger.dart';
import 'package:py_4/services/quiz/quiz_listener.dart';

class MasterListener extends QuizListener<MasterPayload> {
  int gameId;
  MasterListener({required super.bleService, required this.gameId})
      : super(typeName: 'MasterListener');

  @override
  MasterPayload? parseResult(Uint8List data) {
    try {
      final payload = MasterPayload.fromBytes(data);
      if (payload.gameID != gameId) {
        log.d('MasterListener: game ID mismatch (expected=$gameId, got=${payload.gameID})');
        return null;
      }
      return payload;
    } catch (e) {
      log.w('MasterListener: parse failed — $e');
      return null;
    }
  }
}