import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:AlpenQuiz/models/client_payload.dart';
import 'package:AlpenQuiz/services/lan/lan_client_listener.dart';
import 'package:AlpenQuiz/services/lan/lan_service.dart';
import 'package:logger/logger.dart';
import 'package:AlpenQuiz/config.dart';
import 'package:AlpenQuiz/services/logger.dart';

void main() {
  setUpAll(() {
    log = Logger(printer: PrettyPrinter());
  });

  group('ClientPayload Serialization Tests', () {
    test('ClientPayload can serialize to bytes and deserialize back', () {
      final payload = ClientPayload(
        name: 'Player 1',
        answers: [
          const ClientAnswer(answer: 1, answerMsOffset: 1200),
          const ClientAnswer(answer: 2, answerMsOffset: 3400),
        ],
        gameID: 999,
        clientId: 10,
      );

      final bytes = payload.toBytes();
      expect(bytes, isNotEmpty);

      // Deserialize
      final decoded = ClientPayload.fromBytes(bytes);
      expect(decoded.name, 'Player 1');
      expect(decoded.gameID, 999);
      expect(decoded.clientId, 10);
      expect(decoded.answers.length, 2);
      expect(decoded.answers[0].answer, 1);
      expect(decoded.answers[0].answerMsOffset, 1200);
      expect(decoded.answers[1].answer, 2);
      expect(decoded.answers[1].answerMsOffset, 3400);
    });

    test('ClientPayload fromBytes throws FormatException for invalid bytes', () {
      final invalidBytes = Uint8List.fromList([0, 1, 2, 3]);
      expect(
        () => ClientPayload.fromBytes(invalidBytes),
        throwsA(isA<Exception>()), 
      );
    });
  });

  group('LanClientListener Tests', () {
    test('LanClientListener drops mismatched gameId and duplicate payloads', () async {
      Config.mockSessionOverride = true;
      
      final hostService = await LanService.host(
        gameId: 999,
        questionCount: 10,
      ) as dynamic;

      final clientService = await LanService.client(
        hostIp: '127.0.0.1',
        wsPort: 8080,
        gameId: 999,
        playerName: 'Budi',
        clientId: 5,
      ) as dynamic;

      final listener = LanClientListener(
        lanService: hostService,
        gameId: 999,
      );

      final receivedPayloads = <ClientPayload>[];
      final sub = listener.stream.listen((payload) {
        receivedPayloads.add(payload);
      });

      // 1. Send valid payload
      final payload1 = const ClientPayload(
        name: 'Budi',
        answers: [ClientAnswer(answer: 1, answerMsOffset: 100)],
        gameID: 999,
        clientId: 5,
      );
      clientService.mockSendToHost(payload1.toBytes());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(receivedPayloads.length, 1);

      // 2. Send duplicate payload (same length, should be dropped)
      clientService.mockSendToHost(payload1.toBytes());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(receivedPayloads.length, 1, reason: 'Duplicate payload should be dropped');

      // 3. Send payload with mismatched gameId (should be dropped)
      final payloadWrongGame = const ClientPayload(
        name: 'Budi',
        answers: [ClientAnswer(answer: 2, answerMsOffset: 200)],
        gameID: 111, // Wrong!
        clientId: 5,
      );
      clientService.mockSendToHost(payloadWrongGame.toBytes());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(receivedPayloads.length, 1, reason: 'Mismatched gameId should be dropped');

      // 4. Send updated payload (longer length because more answers)
      final payload2 = const ClientPayload(
        name: 'Budi',
        answers: [
          ClientAnswer(answer: 1, answerMsOffset: 100),
          ClientAnswer(answer: 2, answerMsOffset: 200),
        ],
        gameID: 999,
        clientId: 5,
      );
      clientService.mockSendToHost(payload2.toBytes());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(receivedPayloads.length, 2, reason: 'Updated longer payload should be accepted');

      hostService.dispose();
      clientService.dispose();
      listener.dispose();
      await sub.cancel();
      Config.mockSessionOverride = null;
    });
  });
}
