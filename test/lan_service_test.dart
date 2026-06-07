import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:logger/logger.dart';
import 'package:AlpenQuiz/config.dart';
import 'package:AlpenQuiz/services/lan/lan_service.dart';
import 'package:AlpenQuiz/services/logger.dart';

void main() {
  setUpAll(() {
    // Memaksa LanService untuk menggunakan LanMockService (in-memory bus)
    Config.mockSessionOverride = true;
    log = Logger(printer: PrettyPrinter());
  });

  tearDownAll(() {
    Config.mockSessionOverride = null;
  });

  group('LanService Mocked Network Tests', () {
    test('Host mode initializes correctly and broadcasts discovery', () async {
      // Buka channel discovery
      final discoveryService = await LanService.discovery();
      
      DiscoveredGame? foundGame;
      final sub = discoveryService.onGameDiscovered.listen((game) {
        foundGame = game;
      });

      // Buka host mode
      final hostService = await LanService.host(
        gameId: 101,
        questionCount: 15,
        hostName: 'Test Host',
      );

      // Tunggu sebentar agar event stream lewat
      await Future.delayed(const Duration(milliseconds: 50));

      expect(hostService.isRunning, true);
      expect(foundGame, isNotNull);
      expect(foundGame!.gameId, 101);
      expect(foundGame!.questionCount, 15);
      expect(foundGame!.hostName, 'Test Host');

      hostService.dispose();
      discoveryService.dispose();
      await sub.cancel();
    });

    test('Host to Client data transfer', () async {
      final hostService = await LanService.host(
        gameId: 202,
        questionCount: 10,
      ) as dynamic; // Cast to dynamic to access mock method

      final clientService = await LanService.client(
        hostIp: '127.0.0.1',
        wsPort: 8080,
        gameId: 202,
        playerName: 'Player 1',
        clientId: 1,
      );

      Uint8List? receivedData;
      final sub = clientService.onHostData.listen((data) {
        receivedData = data;
      });

      final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
      // Memanggil fungsi mock khusus untuk mensimulasikan broadcast dari Host
      hostService.mockBroadcast(testData);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(receivedData, isNotNull);
      expect(receivedData, equals(testData));

      hostService.dispose();
      clientService.dispose();
      await sub.cancel();
    });

    test('Client to Host data transfer', () async {
      final hostService = await LanService.host(
        gameId: 303,
        questionCount: 5,
      );

      final clientService = await LanService.client(
        hostIp: '127.0.0.1',
        wsPort: 8080,
        gameId: 303,
        playerName: 'Player 2',
        clientId: 2,
      ) as dynamic; // Cast to access mock method

      (String, Uint8List)? receivedAtHost;
      final sub = hostService.onClientData.listen((data) {
        receivedAtHost = data;
      });

      final testData = Uint8List.fromList([9, 8, 7]);
      // Mensimulasikan pengiriman data dari Klien ke Host
      clientService.mockSendToHost(testData);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(receivedAtHost, isNotNull);
      expect(receivedAtHost!.$1, 'mock-client-303');
      expect(receivedAtHost!.$2, equals(testData));

      hostService.dispose();
      clientService.dispose();
      await sub.cancel();
    });
  });
}
