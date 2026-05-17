import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:AlpenQuiz/config.dart';
import 'package:AlpenQuiz/models/client_payload.dart';
import 'package:AlpenQuiz/models/master_payload.dart';
import 'package:AlpenQuiz/models/question.dart';
import 'package:AlpenQuiz/services/ble_service_base.dart';
import 'package:AlpenQuiz/services/ble_service.dart';
import 'package:AlpenQuiz/services/logger.dart';
import 'package:AlpenQuiz/services/mock_ble_service.dart';
import 'package:AlpenQuiz/services/quiz/client_listener.dart';
import 'package:AlpenQuiz/services/quiz/master_publisher.dart';

enum HostPhase { lobby, countdown, question, results }

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
  static const int _firstQuestionCountdownMs = 5000;

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
  int? _countdownEndsAtMs;
  int? get countdownEndsAtMs => _countdownEndsAtMs;

  int get currentQuestionIndex => _currentQuestionIndex;
  Question get currentQuestion => questions[_currentQuestionIndex];

  List<ParticipantAnswer> _answers = [];
  List<ParticipantAnswer> get answers => _answers;

  final Map<int, String> _participants = {};
  Map<int, String> get participants => _participants;

  final Map<int, int> _processedAnswerCounts = {};

  StreamSubscription? _clientSub;
  Timer? _countdownTimer;
  bool _isDisposed = false;
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
    log.i(
      'HostController: loaded ${questions.length} questions for quiz $quizId',
    );
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
    if (payload.gameID != _gameId) return;

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
    if (_phase == HostPhase.countdown) return;

    _currentQuestionIndex++;
    if (_currentQuestionIndex >= questions.length) {
      await endGame();
      return;
    }

    if (_currentQuestionIndex == 0) {
      await _startFirstQuestionCountdown();
      return;
    }

    await _publishQuestion();
  }

  Future<void> _startFirstQuestionCountdown() async {
    _phase = HostPhase.countdown;
    _answers = [];
    _processedAnswerCounts.clear();
    _countdownEndsAtMs =
        DateTime.now().millisecondsSinceEpoch + _firstQuestionCountdownMs;

    final countdownPayload = MasterPayload(
      masterTimeMs: _currentPayload.masterTimeMs,
      questionStartsAtMs: _countdownEndsAtMs,
      nextQuestion: const [],
      gameID: _gameId,
    );
    _currentPayload = countdownPayload;
    _publisher!.publish(countdownPayload);
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer(
      const Duration(milliseconds: _firstQuestionCountdownMs),
      () {
        if (_isDisposed || _phase != HostPhase.countdown) return;
        _publishQuestion();
      },
    );
  }

  Future<void> _publishQuestion() async {
    _phase = HostPhase.question;
    _countdownEndsAtMs = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _answers = [];
    _processedAnswerCounts.clear();

    final nextQuestion = <int>[
      ..._currentPayload.nextQuestion,
      DateTime.now().millisecondsSinceEpoch - _currentPayload.masterTimeMs,
    ];

    final questionPayload = MasterPayload(
      masterTimeMs: _currentPayload.masterTimeMs,
      nextQuestion: nextQuestion,
      gameID: _gameId,
    );

    _currentPayload = questionPayload;
    _publisher!.publish(questionPayload);

    notifyListeners();
  }

  Future<void> endGame() async {
    _phase = HostPhase.results;
    _countdownEndsAtMs = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;

    _currentPayload.gameFinished = true;
    _publisher!.publish(_currentPayload);
    await _bleService.stopAdvertising();
    _isAdvertising = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _countdownTimer?.cancel();
    _clientSub?.cancel();
    _clientListener?.dispose();
    _publisher?.dispose();
    _bleService.dispose();
    super.dispose();
  }
}
