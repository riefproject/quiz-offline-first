import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:py_4/models/master_payload.dart';
import 'package:py_4/services/quiz/quiz_listener.dart';

class MasterListListener extends QuizListener<MasterPayload> {
  MasterListListener({required super.bleService});

  @override
  MasterPayload? parseResult(Uint8List data) {
    try {
      final payload = MasterPayload.fromBytes(data);
      return payload;
    } catch (e) {
      debugPrint("Failed to parse master payload from list: $e");
      return null;
    }
  }
}
