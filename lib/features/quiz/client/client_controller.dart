import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:py_4/config.dart';
import 'package:py_4/models/client_payload.dart';
import 'package:py_4/models/master_payload.dart';
import 'package:py_4/services/ble_service.dart';
import 'package:py_4/services/ble_service_base.dart';
import 'package:py_4/services/mock_ble_service.dart';
import 'package:py_4/services/quiz/client_publisher.dart';
import 'package:py_4/services/quiz/master_list_listener.dart';
import 'package:py_4/services/quiz/master_listener.dart';

enum ClientPhase { scanning, lobby, question, finished }

class ClientController extends ChangeNotifier {
  final BleServiceBase _bleService;

  ClientPhase _phase = ClientPhase.scanning;
  ClientPhase get phase => _phase;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  String? _scanError;
  String? get scanError => _scanError;

  MasterListListener? _masterListListener;
  MasterListener? _masterListener;
  ClientPublisher? _clientPublisher;

  List<MasterPayload> _discoveredGames = [];
  List<MasterPayload> get discoveredGames => _discoveredGames;

  int? _joinedGameId;
  int? get joinedGameId => _joinedGameId;

  MasterPayload? _currentPayload;
  MasterPayload? get currentPayload => _currentPayload;

  String _playerName = '';
  String get playerName => _playerName;
  int _clientId = 0;

  List<ClientAnswer> _myAnswers = [];
  List<ClientAnswer> get myAnswers => _myAnswers;

  StreamSubscription? _masterListSub;
  StreamSubscription? _masterSub;

  ClientController({BleServiceBase? bleService})
    : _bleService = Config.isSessionMocked
          ? MockBleService()
          : bleService ?? BleService();

  set playerName(String value) {
    _playerName = value;
    notifyListeners();
  }

  Future<void> startScan() async {
    if (_isScanning) return;
    _scanError = null;
    _isScanning = true;
    notifyListeners();

    try {
      await _bleService.init();
      await _bleService.requestScanPermissions();
      await _bleService.startScan(timeout: const Duration(seconds: 30));

      _masterListListener = MasterListListener(bleService: _bleService);
      _masterListSub = _masterListListener!.stream.listen(_onDiscovery);
    } catch (e) {
      _scanError = 'Scan failed: $e';
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  void _onDiscovery(MasterPayload payload) {
    final exists = _discoveredGames.any((g) => g.gameID == payload.gameID);
    if (!exists) {
      _discoveredGames = List.from(_discoveredGames)..add(payload);
      notifyListeners();
    }
  }

  Future<void> joinGame(MasterPayload game) async {
    _joinedGameId = game.gameID;
    _clientId = DateTime.now().millisecondsSinceEpoch % 100000;

    // await _bleService.stopScan();

    _masterListSub?.cancel();
    _masterListSub = null;
    _masterListListener?.dispose();
    _masterListListener = null;

    _masterListener = MasterListener(
      bleService: _bleService,
      gameId: game.gameID,
    );
    _masterSub = _masterListener!.stream.listen(_onQuestion);

    _clientPublisher = ClientPublisher(bleService: _bleService);

    _phase = ClientPhase.lobby;
    _clientPublisher!.publish(
      ClientPayload(
        name: _playerName,
        answers: [],
        gameId: _joinedGameId!,
        clientId: _clientId,
      ),
    );
    notifyListeners();
  }

  void _onQuestion(MasterPayload payload) {
    _currentPayload = payload;

    if (payload.gameFinished == true) {
      _phase = ClientPhase.finished;
      notifyListeners();
      return;
    }

    if (payload.nextQuestion.isNotEmpty) {
      if (myAnswers.length < payload.nextQuestion.length) {
        _phase = ClientPhase.question;
        notifyListeners();
      }
    }

    // if (payload.nextQuestion.isNotEmpty) {
    //   _phase = ClientPhase.question;
    //   notifyListeners();
    // }
  }

  void submitAnswer(int answerIndex) {
    if (_currentPayload == null) return;

    final offset =
        DateTime.now().millisecondsSinceEpoch - _currentPayload!.masterTimeMs;
    final answer = ClientAnswer(answer: answerIndex, answerMsOffset: offset);
    _myAnswers = List.from(_myAnswers)..add(answer);

    final payload = ClientPayload(
      name: _playerName,
      answers: _myAnswers,
      gameId: _joinedGameId!,
      clientId: _clientId,
    );

    _clientPublisher?.publish(payload);

    _phase = ClientPhase.lobby;
    notifyListeners();
  }

  @override
  void dispose() {
    _masterListSub?.cancel();
    _masterSub?.cancel();
    _masterListListener?.dispose();
    _masterListener?.dispose();
    _clientPublisher?.dispose();
    _bleService.dispose();
    super.dispose();
  }
}
