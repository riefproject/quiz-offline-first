import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:AlpenQuiz/config.dart';
import 'package:AlpenQuiz/models/client_payload.dart';
import 'package:AlpenQuiz/models/master_payload.dart';
import 'package:AlpenQuiz/models/reverse_qr_submission.dart';
import 'package:AlpenQuiz/services/ble_service.dart';
import 'package:AlpenQuiz/services/ble_service_base.dart';
import 'package:AlpenQuiz/services/logger.dart';
import 'package:AlpenQuiz/services/mock_ble_service.dart';
import 'package:AlpenQuiz/services/quiz/client_publisher.dart';
import 'package:AlpenQuiz/services/quiz/master_list_listener.dart';
import 'package:AlpenQuiz/services/quiz/master_listener.dart';
import 'package:AlpenQuiz/services/lan/lan_service.dart';
import 'package:AlpenQuiz/services/lan/lan_master_list_listener.dart';
import 'package:AlpenQuiz/services/lan/lan_master_listener.dart';
import 'package:AlpenQuiz/services/lan/lan_client_publisher.dart';

enum ClientPhase { scanning, lobby, countdown, question, finished }

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

  LanService? _lanService;
  LanService? _lanDiscoveryService;
  LanMasterListListener? _lanMasterListListener;
  LanMasterListener? _lanMasterListener;
  LanClientPublisher? _lanClientPublisher;

  List<MasterPayload> _discoveredGames = [];
  List<MasterPayload> get discoveredGames => _discoveredGames;

  int? _joinedGameId;
  int? get joinedGameId => _joinedGameId;

  MasterPayload? _currentPayload;
  MasterPayload? get currentPayload => _currentPayload;

  String _playerName = '';
  String get playerName => _playerName;
  int _clientId = 0;
  int get clientId => _clientId;

  List<ClientAnswer> _myAnswers = [];
  List<ClientAnswer> get myAnswers => _myAnswers;

  StreamSubscription? _masterListSub;
  StreamSubscription? _masterSub;
  Timer? _countdownTimer;
  Timer? _questionTimer;

  int _countdownRemainingMs = 0;
  int get countdownRemainingMs => _countdownRemainingMs;

  int _remainingTimeMs = 0;
  int get remainingTimeMs => _remainingTimeMs;

  MasterQuestionInfo? get currentQuestionInfo {
    if (_currentPayload == null) return null;
    final index = _myAnswers.length;
    if (index >= _currentPayload!.nextQuestion.length) return null;
    return _currentPayload!.questionInfoAt(index);
  }

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
      if (Config.useLan) {
        _lanDiscoveryService = await LanService.discovery();
        _lanMasterListListener = LanMasterListListener(
          lanService: _lanDiscoveryService!,
        );
        _masterListSub =
            _lanMasterListListener!.stream.listen(_onDiscovery);
        log.i(
          'ClientController: LAN discovery started playerName=$_playerName',
        );
      } else {
        await _bleService.init();
        await _bleService.requestScanPermissions();
        await _bleService.startScan(timeout: const Duration(seconds: 30));

        _masterListListener = MasterListListener(bleService: _bleService);
        _masterListSub = _masterListListener!.stream.listen(_onDiscovery);
      }
    } catch (e) {
      _scanError = 'Scan failed: $e';
      log.w('ClientController: scan failed — $e');
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

    ({String hostIp, int wsPort})? connInfo;
    if (Config.useLan) {
      connInfo = _lanMasterListListener?.connectionInfoFor(game.gameID);
    }

    _masterListSub?.cancel();
    _masterListSub = null;
    _masterListListener?.dispose();
    _masterListListener = null;
    _lanMasterListListener?.dispose();
    _lanMasterListListener = null;

    if (Config.useLan) {
      if (connInfo == null) {
        _scanError = 'Host connection info not found for game #${game.gameID}';
        notifyListeners();
        return;
      }

      _lanService = await LanService.client(
        hostIp: connInfo.hostIp,
        wsPort: connInfo.wsPort,
        gameId: game.gameID,
        playerName: _playerName,
        clientId: _clientId,
      );

      _lanMasterListener = LanMasterListener(
        lanService: _lanService!,
        gameId: game.gameID,
      );
      _masterSub = _lanMasterListener!.stream.listen(_onQuestion);

      _lanClientPublisher = LanClientPublisher(lanService: _lanService!);

      _phase = ClientPhase.lobby;
      _lanClientPublisher!.publish(
        ClientPayload(
          name: _playerName,
          answers: [],
          gameID: _joinedGameId!,
          clientId: _clientId,
        ),
      );
      log.i(
        'ClientController: joined game via LAN gameID=${game.gameID} host=${connInfo.hostIp}:${connInfo.wsPort}',
      );
      notifyListeners();
      return;
    }

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
        gameID: _joinedGameId!,
        clientId: _clientId,
      ),
    );
    notifyListeners();
  }

  void _onQuestion(MasterPayload payload) {
    _currentPayload = payload;
    _questionTimer?.cancel();
    _questionTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;

    if (payload.gameFinished == true) {
      _phase = ClientPhase.finished;
      notifyListeners();
      return;
    }

    final questionIndex = _myAnswers.length;
    if (questionIndex >= payload.questionCount) {
      _phase = ClientPhase.finished;
      notifyListeners();
      return;
    }

    if (payload.nextQuestion.isNotEmpty &&
        questionIndex < payload.nextQuestion.length) {
      final info = payload.questionInfoAt(questionIndex);

      if (info.skippedAtMs != -1) {
        _submitNoAnswer();
        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final questionStart = payload.masterTimeMs + info.nextQuestionMs;
      final questionEnd = questionStart + info.durationMs;
      final timeToStart = questionStart - now;
      final remaining = questionEnd - now;

      if (remaining <= 0) {
        _submitNoAnswer();
        return;
      }

      if (timeToStart > 0) {
        _countdownRemainingMs = timeToStart;
        _phase = ClientPhase.countdown;

        _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (
          _,
        ) {
          final elapsed = DateTime.now().millisecondsSinceEpoch - now;
          _countdownRemainingMs = timeToStart - elapsed;
          if (_countdownRemainingMs <= 0) {
            _countdownTimer?.cancel();
            _countdownTimer = null;
            _startQuestion(questionEnd);
          } else {
            notifyListeners();
          }
        });
      } else {
        _startQuestion(questionEnd);
      }

      notifyListeners();
    }
  }

  void _startQuestion(int questionEnd) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = questionEnd - now;

    if (remaining <= 0) {
      _submitNoAnswer();
      return;
    }

    _remainingTimeMs = remaining;
    _phase = ClientPhase.question;

    _questionTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - now;
      _remainingTimeMs = remaining - elapsed;
      if (_remainingTimeMs <= 0) {
        _questionTimer?.cancel();
        _questionTimer = null;
        _submitNoAnswer();
      } else {
        notifyListeners();
      }
    });
  }

  void submitAnswer(int answerIndex) {
    _questionTimer?.cancel();
    _questionTimer = null;
    _publishAnswer(answerIndex);
    _phase = ClientPhase.lobby;
    notifyListeners();
  }

  void _submitNoAnswer() {
    _publishAnswer(-1);
    _phase = ClientPhase.lobby;
    notifyListeners();
  }

  void _publishAnswer(int answerIndex) {
    if (_currentPayload == null) return;
    final offset =
        DateTime.now().millisecondsSinceEpoch - _currentPayload!.masterTimeMs;
    final answer = ClientAnswer(answer: answerIndex, answerMsOffset: offset);
    _myAnswers = List.from(_myAnswers)..add(answer);

    final payload = ClientPayload(
      name: _playerName,
      answers: _myAnswers,
      gameID: _joinedGameId!,
      clientId: _clientId,
    );

    if (Config.useLan) {
      _lanClientPublisher?.publish(payload);
    } else {
      _clientPublisher?.publish(payload);
    }
  }

  ReverseQrSubmission buildReverseQrSubmission({
    required String participantUserId,
  }) {
    final gameId = _joinedGameId;
    if (gameId == null) {
      throw StateError('Participant is not connected to a game.');
    }

    return ReverseQrSubmission.fromClientAnswers(
      participantUserId: participantUserId,
      participantName: _playerName,
      gameId: gameId,
      clientId: _clientId,
      answers: _myAnswers,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _questionTimer?.cancel();
    _masterListSub?.cancel();
    _masterSub?.cancel();
    _masterListListener?.dispose();
    _masterListener?.dispose();
    _clientPublisher?.dispose();
    _lanMasterListListener?.dispose();
    _lanMasterListener?.dispose();
    _lanClientPublisher = null;
    _lanService?.dispose();
    _lanDiscoveryService?.dispose();
    _bleService.dispose();
    super.dispose();
  }
}
