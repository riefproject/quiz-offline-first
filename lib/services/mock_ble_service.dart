import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:py_4/models/client_payload.dart';
import 'package:py_4/models/master_payload.dart';
import 'package:py_4/services/ble_payload_formatter.dart';
import 'package:py_4/services/ble_service_base.dart';
import 'package:py_4/services/logger.dart';

class MockBleService extends BleServiceBase {
  int _advertiseCount = 0;
  int _scanCount = 0;
  bool _scanning = false;
  bool _clientSimulationActive = false;

  static const int _mockGameId = 123456;

  static const List<({String name, int clientId})> _mockClients = [
    (name: 'Alice', clientId: 900001),
    (name: 'Bob', clientId: 900002),
  ];

  final Map<int, List<ClientAnswer>> _mockClientAnswers = {};

  @override
  Future<void> init() async {
    log.i('MockBLE: initialized');
  }

  @override
  Future<bool> requestAllPermissions() async {
    log.i('MockBLE: requestAllPermissions() → true');
    return true;
  }

  @override
  Future<bool> requestScanPermissions() async {
    log.i('MockBLE: requestScanPermissions() → true');
    return true;
  }

  @override
  Future<bool> requestAdvertisePermissions() async {
    log.i('MockBLE: requestAdvertisePermissions() → true');
    return true;
  }

  @override
  Future<void> startAdvertising(
    Uint8List data, {
    String localName = 'KahoofMaster',
  }) async {
    _advertiseCount++;
    log.i(
      'MockBLE: ADVERTISE #$_advertiseCount (localName=$localName, ${data.length} bytes)\n${formatBlePayload(data)}',
    );
    isAdvertising.value = true;

    try {
      final payload = MasterPayload.fromBytes(data);
      _clientSimulationActive = true;
      _runMockClientSimulation(payload);
    } catch (e) {
      log.w(
        'MockBLE: could not decode host payload for client simulation — $e',
      );
    }
  }

  void _runMockClientSimulation(MasterPayload hostPayload) async {
    if (hostPayload.gameFinished == true) {
      log.i('MockBLE: host sent gameFinished — cancelling client simulation');
      _clientSimulationActive = false;
      return;
    }

    if (hostPayload.nextQuestion.isEmpty) {
      for (final client in _mockClients) {
        await Future.delayed(Duration(seconds: 1 + Random().nextInt(2)));
        if (!_clientSimulationActive) return;

        _mockClientAnswers[client.clientId] = [];

        final joinPayload = ClientPayload(
          name: client.name,
          answers: [],
          gameID: hostPayload.gameID,
          clientId: client.clientId,
        );
        final existing = List<Uint8List>.from(rawScanData.value)
          ..add(joinPayload.toBytes());
        rawScanData.value = existing;

        log.i(
          'MockBLE: CLIENT JOINED (name=${client.name}, clientId=${client.clientId})\n${formatBlePayload(joinPayload.toBytes())}',
        );
      }
      return;
    }

    for (final client in _mockClients) {
      await Future.delayed(Duration(seconds: 1 + Random().nextInt(3)));
      if (!_clientSimulationActive) return;

      final answerIndex = Random().nextInt(4);
      final offsetMs = 1000 + Random().nextInt(3000);
      final previousAnswers = _mockClientAnswers[client.clientId] ?? [];
      final newAnswer = ClientAnswer(
        answer: answerIndex,
        answerMsOffset: offsetMs,
      );
      final allAnswers = [...previousAnswers, newAnswer];
      _mockClientAnswers[client.clientId] = allAnswers;

      final answerLabels = ['A', 'B', 'C', 'D'];
      final answerPayload = ClientPayload(
        name: client.name,
        answers: allAnswers,
        gameID: hostPayload.gameID,
        clientId: client.clientId,
      );
      final existing = List<Uint8List>.from(rawScanData.value)
        ..add(answerPayload.toBytes());
      rawScanData.value = existing;

      log.i(
        'MockBLE: CLIENT ANSWER (name=${client.name}, answer=${answerLabels[answerIndex]} ($answerIndex), offsetMs=${offsetMs}ms, total=${allAnswers.length})\n${formatBlePayload(answerPayload.toBytes())}',
      );
    }
  }

  @override
  Future<void> stopAdvertising() async {
    log.i(
      'MockBLE: stopAdvertising() — total advertisements: $_advertiseCount',
    );
    _clientSimulationActive = false;
    isAdvertising.value = false;
  }

  @override
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    _scanCount++;
    log.i(
      'MockBLE: SCAN #$_scanCount started (timeout=${timeout.inSeconds}s) — will simulate: discovery → Q1 → Q2 → finish',
    );

    rawScanData.value = [];
    isScanning.value = true;
    _scanning = true;

    _runMockScanSimulation();
  }

  Future<void> _runMockScanSimulation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!_scanning) return;

    final lobbyPayload = MasterPayload(
      masterTimeMs: DateTime.now().millisecondsSinceEpoch,
      nextQuestion: [],
      gameID: _mockGameId,
    );
    rawScanData.value = List<Uint8List>.from(rawScanData.value)
      ..add(lobbyPayload.toBytes());
    log.i(
      'MockBLE: DISCOVERED game #$_mockGameId (lobby)\n${formatBlePayload(lobbyPayload.toBytes())}',
    );

    await Future.delayed(const Duration(seconds: 3));
    if (!_scanning) return;

    final q1Payload = MasterPayload(
      masterTimeMs: DateTime.now().millisecondsSinceEpoch,
      nextQuestion: [5000],
      gameID: _mockGameId,
    );
    rawScanData.value = List<Uint8List>.from(rawScanData.value)
      ..add(q1Payload.toBytes());
    log.i(
      'MockBLE: QUESTION 1 broadcast (gameID=$_mockGameId, nextQuestion=[5.0s])\n${formatBlePayload(q1Payload.toBytes())}',
    );

    await Future.delayed(const Duration(seconds: 3));
    if (!_scanning) return;

    final q2Payload = MasterPayload(
      masterTimeMs: DateTime.now().millisecondsSinceEpoch,
      nextQuestion: [5000, 10000],
      gameID: _mockGameId,
    );
    rawScanData.value = List<Uint8List>.from(rawScanData.value)
      ..add(q2Payload.toBytes());
    log.i(
      'MockBLE: QUESTION 2 broadcast (gameID=$_mockGameId, nextQuestion=[5.0s, 10.0s])\n${formatBlePayload(q2Payload.toBytes())}',
    );

    await Future.delayed(const Duration(seconds: 3));
    if (!_scanning) return;

    final endPayload = MasterPayload(
      masterTimeMs: DateTime.now().millisecondsSinceEpoch,
      nextQuestion: [],
      gameFinished: true,
      gameID: _mockGameId,
    );
    rawScanData.value = List<Uint8List>.from(rawScanData.value)
      ..add(endPayload.toBytes());
    log.i(
      'MockBLE: GAME FINISHED broadcast (gameID=$_mockGameId)\n${formatBlePayload(endPayload.toBytes())}',
    );
  }

  @override
  Future<void> stopScan() async {
    log.i('MockBLE: stopScan()');
    _scanning = false;
    isScanning.value = false;
  }

  @override
  void dispose() {
    log.i('MockBLE: dispose() — ads: $_advertiseCount, scans: $_scanCount');
    _scanning = false;
    _clientSimulationActive = false;
  }
}
