import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:py_4/models/client_payload.dart';
import 'package:py_4/services/quiz/quiz_listener.dart';

class ClientListener extends QuizListener<ClientPayload> {
  int gameId;
  ClientListener({required super.bleService, required this.gameId});

  @override
  ClientPayload? parseResult(Uint8List data) {
    try {
      final payload = ClientPayload.fromBytes(data);
      if (payload.gameId != gameId) return null;
      return payload;
    } catch (e) {
      debugPrint("Failed to parse client payload: $e");
      return null;
    }
  }
}
