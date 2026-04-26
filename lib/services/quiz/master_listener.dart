import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:py_4/models/master_payload.dart';
import 'package:py_4/services/quiz/quiz_listener.dart';

class MasterListener extends QuizListener<MasterPayload> {
  int gameId;
  MasterListener({required super.bleService, required this.gameId});

  @override
  MasterPayload? parseResult(Uint8List data) {
    try {
      final payload = MasterPayload.fromBytes(data);
      if (payload.gameID != gameId) return null;
      return payload;
    } catch (e) {
      debugPrint("Failed to parse master payload: $e");
      return null;
    }
  }
}
