import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:py_4/config.dart';
import 'package:py_4/models/client_payload.dart';
import 'package:py_4/models/master_payload.dart';
import 'package:py_4/models/question.dart';
import 'package:py_4/services/ble_service_base.dart';
import 'package:py_4/services/ble_service.dart';
import 'package:py_4/services/logger.dart';
import 'package:py_4/services/mock_ble_service.dart';
import 'package:py_4/services/quiz/client_listener.dart';
import 'package:py_4/services/quiz/master_publisher.dart';

enum HostPhase { lobby, question, results }

class ParticipantAnswer {
  final String name;
  final int clientId;
  final int answer;
  final int offsetMs;

  const ParticipantAnswer({
    required this.name,
    required this.clientId,
    required this.answer,
    required this.offsetMs,
  });
}

class HostController extends ChangeNotifier {
  late BleServiceBase _bleService;
  MasterPublisher? _publisher;
  ClientListener? _clientListener;

  int _gameId = 0;
  int get gameId => _gameId;

  HostPhase _phase = HostPhase.lobby;
  HostPhase get phase => _phase;

  int _currentQuestionIndex = -1;
  final String quizId;
  List<Question> questions = [];

  int get currentQuestionIndex => _currentQuestionIndex;
  Question get currentQuestion => questions[_currentQuestionIndex];

  List<ParticipantAnswer> _answers = [];
  List<ParticipantAnswer> get answers => _answers;

  final Map<int, String> _participants = {};
  Map<int, String> get participants => _participants;

  final Map<int, int> _processedAnswerCounts = {};

  StreamSubscription? _clientSub;
  bool _isAdvertising = false;
  bool get isAdvertising => _isAdvertising;
  var _currentPayload = MasterPayload(
    masterTimeMs: DateTime.now().millisecondsSinceEpoch,
    nextQuestion: [],
    gameID: 0,
  );

  HostController({BleServiceBase? bleService, required this.quizId}) {
    _bleService = Config.isSessionMocked
        ? MockBleService()
        : bleService ?? BleService();
    questions = Question.fromQuizId(quizId);
    log.i('HostController: loaded ${questions.length} questions for quiz $quizId');
  }
  Future<void> startGame() async {
    _gameId = Random().nextInt(999999) + 100000;

    await _bleService.init();
    await _bleService.requestAllPermissions();

    _publisher = MasterPublisher(bleService: _bleService);
    _clientListener = ClientListener(bleService: _bleService, gameId: _gameId);
    _bleService.startScan(timeout: Duration(seconds: 120));

    _clientSub = _clientListener!.stream.listen(_onClientPayload);

    final payload = MasterPayload(
      masterTimeMs: DateTime.now().millisecondsSinceEpoch,
      nextQuestion: [],
      gameID: _gameId,
    );
    _currentPayload = payload;
    _publisher!.publish(payload);

    _isAdvertising = true;
    notifyListeners();
  }

  void _onClientPayload(ClientPayload payload) {
    if (payload.gameId != _gameId) return;

    _participants[payload.clientId] = payload.name;

    final alreadyProcessed = _processedAnswerCounts[payload.clientId] ?? 0;
    final newAnswers = payload.answers.skip(alreadyProcessed);

    for (final answer in newAnswers) {
      _answers = List.from(_answers)
        ..add(
          ParticipantAnswer(
            name: payload.name,
            clientId: payload.clientId,
            answer: answer.answer,
            offsetMs: answer.answerMsOffset,
          ),
        );
    }

    _processedAnswerCounts[payload.clientId] = payload.answers.length;
    notifyListeners();
  }

  Future<void> nextQuestion() async {
    _currentQuestionIndex++;
    if (_currentQuestionIndex >= questions.length) {
      await endGame();
      return;
    }

    _phase = HostPhase.question;
    _answers = [];
    _processedAnswerCounts.clear();

    _currentPayload.nextQuestion.add(
      DateTime.now().millisecondsSinceEpoch -
          _currentPayload.masterTimeMs +
          Duration(seconds: 5).inMilliseconds,
    );

    _publisher!.publish(_currentPayload);

    notifyListeners();
  }

  Future<void> endGame() async {
    _phase = HostPhase.results;

    _currentPayload.gameFinished = true;
    _publisher!.publish(_currentPayload);
    await _bleService.stopAdvertising();
    _isAdvertising = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _clientSub?.cancel();
    _clientListener?.dispose();
    _publisher?.dispose();
    _bleService.dispose();
    super.dispose();
  }
}
