import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:py_4/models/client_payload.dart';
import 'package:py_4/models/master_payload.dart';
import 'package:py_4/services/ble_service_base.dart';

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

  Map<String, dynamic>? _decodePayload(Uint8List data) {
    try {
      final decoded = msgpack.deserialize(data);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _formatPayload(Uint8List data) {
    final decoded = _decodePayload(data);
    if (decoded != null) {
      final type = decoded['t'];
      String? pretty;
      if (type == MASTER_PAYLOAD_TYPE) {
        try {
          final payload = MasterPayload.fromBytes(data);
          final map = payload.toMsgpackMap()
            ..['masterTimeMs'] = _formatTimestamp(payload.masterTimeMs);
          if (payload.nextQuestion.isNotEmpty) {
            map['nextQuestion_offsets'] = payload.nextQuestion
                .map((ms) => '${(ms / 1000).toStringAsFixed(1)}s')
                .toList();
          }
          pretty = const JsonEncoder.withIndent('  ').convert(map);
        } catch (_) {
          pretty = const JsonEncoder.withIndent('  ').convert(decoded);
        }
      } else if (type == CLIENT_PAYLOAD_TYPE) {
        try {
          final payload = ClientPayload.fromBytes(data);
          final map = <String, dynamic>{
            't': payload.payloadType,
            'name': payload.name,
            'gameId': payload.gameId,
            'clientId': payload.clientId,
            'answers': payload.answers
                .map((a) => {'answer': a.answer, 'offsetMs': '${a.answerMsOffset}ms'})
                .toList(),
          };
          pretty = const JsonEncoder.withIndent('  ').convert(map);
        } catch (_) {
          pretty = const JsonEncoder.withIndent('  ').convert(decoded);
        }
      } else {
        pretty = const JsonEncoder.withIndent('  ').convert(decoded);
      }
      return '\n$pretty';
    }
    return ' [${data.length} raw bytes, hex: ${data.take(8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}...]';
  }

  String _formatTimestamp(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.hour.toString().padLeft(2, "0")}:'
        '${dt.minute.toString().padLeft(2, "0")}:'
        '${dt.second.toString().padLeft(2, "0")}.'
        '${dt.millisecond.toString().padLeft(3, "0")}';
  }

  @override
  Future<void> init() async {
    debugPrint('[MockBLE] ┌───────────────────────────');
    debugPrint('[MockBLE] │ init()');
    debugPrint('[MockBLE] └───────────────────────────');
  }

  @override
  Future<bool> requestAllPermissions() async {
    debugPrint('[MockBLE] requestAllPermissions() → true');
    return true;
  }

  @override
  Future<bool> requestScanPermissions() async {
    debugPrint('[MockBLE] requestScanPermissions() → true');
    return true;
  }

  @override
  Future<bool> requestAdvertisePermissions() async {
    debugPrint('[MockBLE] requestAdvertisePermissions() → true');
    return true;
  }

  @override
  Future<void> startAdvertising(Uint8List data, {String localName = 'KahoofMaster'}) async {
    _advertiseCount++;
    debugPrint('[MockBLE] ┌───────────────────────────');
    debugPrint('[MockBLE] │ ADVERTISE #$_advertiseCount');
    debugPrint('[MockBLE] │ localName: $localName');
    debugPrint('[MockBLE] │ bytes: ${data.length}');
    debugPrint('[MockBLE] │ payload:${_formatPayload(data)}');
    debugPrint('[MockBLE] └───────────────────────────');
    isAdvertising.value = true;

    try {
      final payload = MasterPayload.fromBytes(data);
      _clientSimulationActive = true;
      _runMockClientSimulation(payload);
    } catch (e) {
      debugPrint('[MockBLE] Could not decode host payload for client simulation: $e');
    }
  }

  void _runMockClientSimulation(MasterPayload hostPayload) async {
    if (hostPayload.gameFinished == true) {
      debugPrint('[MockBLE] Host sent gameFinished — cancelling client simulation');
      _clientSimulationActive = false;
      return;
    }

    if (hostPayload.nextQuestion.isEmpty) {
      // Lobby phase — mock clients join
      for (final client in _mockClients) {
        await Future.delayed(Duration(seconds: 1 + Random().nextInt(2)));
        if (!_clientSimulationActive) return;

        _mockClientAnswers[client.clientId] = [];

        final joinPayload = ClientPayload(
          name: client.name,
          answers: [],
          gameId: hostPayload.gameID,
          clientId: client.clientId,
        );
        final existing = List<Uint8List>.from(rawScanData.value)..add(joinPayload.toBytes());
        rawScanData.value = existing;

        debugPrint('[MockBLE] ┌───────────────────────────');
        debugPrint('[MockBLE] │ CLIENT JOINED');
        debugPrint('[MockBLE] │ name: ${client.name}, clientId: ${client.clientId}');
        debugPrint('[MockBLE] │ payload:${_formatPayload(joinPayload.toBytes())}');
        debugPrint('[MockBLE] └───────────────────────────');
      }
      return;
    }

    // Question phase — mock clients answer
    for (final client in _mockClients) {
      await Future.delayed(Duration(seconds: 1 + Random().nextInt(3)));
      if (!_clientSimulationActive) return;

      final answerIndex = Random().nextInt(4);
      final offsetMs = 1000 + Random().nextInt(3000);
      final previousAnswers = _mockClientAnswers[client.clientId] ?? [];
      final newAnswer = ClientAnswer(answer: answerIndex, answerMsOffset: offsetMs);
      final allAnswers = [...previousAnswers, newAnswer];
      _mockClientAnswers[client.clientId] = allAnswers;

      final answerLabels = ['A', 'B', 'C', 'D'];
      final answerPayload = ClientPayload(
        name: client.name,
        answers: allAnswers,
        gameId: hostPayload.gameID,
        clientId: client.clientId,
      );
      final existing = List<Uint8List>.from(rawScanData.value)..add(answerPayload.toBytes());
      rawScanData.value = existing;

      debugPrint('[MockBLE] ┌───────────────────────────');
      debugPrint('[MockBLE] │ CLIENT ANSWER');
      debugPrint('[MockBLE] │ name: ${client.name}, answer: ${answerLabels[answerIndex]} (${answerIndex})');
      debugPrint('[MockBLE] │ offsetMs: ${offsetMs}ms, total answers: ${allAnswers.length}');
      debugPrint('[MockBLE] │ payload:${_formatPayload(answerPayload.toBytes())}');
      debugPrint('[MockBLE] └───────────────────────────');
    }
  }

  @override
  Future<void> stopAdvertising() async {
    debugPrint('[MockBLE] stopAdvertising() — total advertisements: $_advertiseCount');
    _clientSimulationActive = false;
    isAdvertising.value = false;
  }

  @override
  Future<void> startScan({Duration timeout = const Duration(seconds: 30)}) async {
    _scanCount++;
    debugPrint('[MockBLE] ┌───────────────────────────');
    debugPrint('[MockBLE] │ SCAN #$_scanCount started');
    debugPrint('[MockBLE] │ timeout: ${timeout.inSeconds}s');
    debugPrint('[MockBLE] │ Will simulate: discovery → Q1 → Q2 → finish');
    debugPrint('[MockBLE] └───────────────────────────');

    rawScanData.value = [];
    isScanning.value = true;
    _scanning = true;

    _runMockScanSimulation();
  }

  Future<void> _runMockScanSimulation() async {
    // Phase 1 (t+2s): Discovery — lobby state, no questions
    await Future.delayed(const Duration(seconds: 2));
    if (!_scanning) return;

    final lobbyPayload = MasterPayload(
      masterTimeMs: DateTime.now().millisecondsSinceEpoch,
      nextQuestion: [],
      gameID: _mockGameId,
    );
    rawScanData.value = List<Uint8List>.from(rawScanData.value)..add(lobbyPayload.toBytes());
    debugPrint('[MockBLE] ┌───────────────────────────');
    debugPrint('[MockBLE] │ DISCOVERED game #$_mockGameId (lobby)');
    debugPrint('[MockBLE] │ payload:${_formatPayload(lobbyPayload.toBytes())}');
    debugPrint('[MockBLE] └───────────────────────────');

    // Phase 2 (t+3s): First question
    await Future.delayed(const Duration(seconds: 3));
    if (!_scanning) return;

    final q1Payload = MasterPayload(
      masterTimeMs: DateTime.now().millisecondsSinceEpoch,
      nextQuestion: [5000],
      gameID: _mockGameId,
    );
    rawScanData.value = List<Uint8List>.from(rawScanData.value)..add(q1Payload.toBytes());
    debugPrint('[MockBLE] ┌───────────────────────────');
    debugPrint('[MockBLE] │ QUESTION 1 broadcast');
    debugPrint('[MockBLE] │ gameID: $_mockGameId, nextQuestion: [5.0s]');
    debugPrint('[MockBLE] │ payload:${_formatPayload(q1Payload.toBytes())}');
    debugPrint('[MockBLE] └───────────────────────────');

    // Phase 3 (t+3s): Second question
    await Future.delayed(const Duration(seconds: 3));
    if (!_scanning) return;

    final q2Payload = MasterPayload(
      masterTimeMs: DateTime.now().millisecondsSinceEpoch,
      nextQuestion: [5000, 10000],
      gameID: _mockGameId,
    );
    rawScanData.value = List<Uint8List>.from(rawScanData.value)..add(q2Payload.toBytes());
    debugPrint('[MockBLE] ┌───────────────────────────');
    debugPrint('[MockBLE] │ QUESTION 2 broadcast');
    debugPrint('[MockBLE] │ gameID: $_mockGameId, nextQuestion: [5.0s, 10.0s]');
    debugPrint('[MockBLE] │ payload:${_formatPayload(q2Payload.toBytes())}');
    debugPrint('[MockBLE] └───────────────────────────');

    // Phase 4 (t+3s): Game finished
    await Future.delayed(const Duration(seconds: 3));
    if (!_scanning) return;

    final endPayload = MasterPayload(
      masterTimeMs: DateTime.now().millisecondsSinceEpoch,
      nextQuestion: [],
      gameFinished: true,
      gameID: _mockGameId,
    );
    rawScanData.value = List<Uint8List>.from(rawScanData.value)..add(endPayload.toBytes());
    debugPrint('[MockBLE] ┌───────────────────────────');
    debugPrint('[MockBLE] │ GAME FINISHED broadcast');
    debugPrint('[MockBLE] │ gameID: $_mockGameId');
    debugPrint('[MockBLE] │ payload:${_formatPayload(endPayload.toBytes())}');
    debugPrint('[MockBLE] └───────────────────────────');
  }

  @override
  Future<void> stopScan() async {
    debugPrint('[MockBLE] stopScan()');
    _scanning = false;
    isScanning.value = false;
  }

  @override
  void dispose() {
    debugPrint('[MockBLE] dispose() — ads: $_advertiseCount, scans: $_scanCount');
    _scanning = false;
    _clientSimulationActive = false;
  }
}