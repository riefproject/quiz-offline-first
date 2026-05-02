import 'dart:typed_data';

import 'package:py_4/models/client_payload.dart';
import 'package:py_4/services/logger.dart';
import 'package:py_4/services/quiz/quiz_listener.dart';

class ClientListener extends QuizListener<ClientPayload> {
  int gameId;
  ClientListener({required super.bleService, required this.gameId})
    : super(typeName: 'ClientListener');

  @override
  ClientPayload? parseResult(Uint8List data) {
    try {
      final payload = ClientPayload.fromBytes(data);
      if (payload.gameID != gameId) {
        log.d(
          'ClientListener: game ID mismatch (expected=$gameId, got=${payload.gameID})',
        );
        return null;
      }
      return payload;
    } catch (e) {
      log.w('ClientListener: parse failed — $e');
      return null;
    }
  }
}
