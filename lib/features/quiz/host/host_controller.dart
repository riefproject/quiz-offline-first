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

enum HostPhase {
  lobby,
  countdown,
  question,
  answerReveal,
  leaderboard,
  results,
}

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

  final Map<int, int> _scores = {};
  Map<int, int> get scores => _scores;

  List<({String name, int clientId, int score, int rank})> get leaderboard {
    final entries = _scores.entries.where((e) => e.value > 0).map((e) {
      final name = _participants[e.key] ?? 'Unknown';
      return (name: name, clientId: e.key, score: e.value, rank: 0);
    }).toList();
    entries.sort((a, b) => b.score.compareTo(a.score));
    for (var i = 0; i < entries.length; i++) {
      entries[i] = (
        name: entries[i].name,
        clientId: entries[i].clientId,
        score: entries[i].score,
        rank: i + 1,
      );
    }
    return entries.take(5).toList();
  }

  StreamSubscription? _clientSub;
  Timer? _countdownTimer;
  bool _isDisposed = false;
  bool _isAdvertising = false;
  bool get isAdvertising => _isAdvertising;

  Timer? _countdownTimer;
  Timer? _questionTimer;

  int _countdownRemainingMs = 0;
  int get countdownRemainingMs => _countdownRemainingMs;

  int _questionRemainingMs = 0;
  int get questionRemainingMs => _questionRemainingMs;

  int questionDuration = 10000;
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
<<<<<<< HEAD
    if (_phase == HostPhase.countdown) return;
=======
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _questionTimer?.cancel();
    _questionTimer = null;
>>>>>>> 60115b4 (feat: host view enchantment)

    _currentQuestionIndex++;
    if (_currentQuestionIndex >= questions.length) {
      await endGame();
      return;
    }

<<<<<<< HEAD
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

=======
    _answers = [];
    _latestPayloads.clear();

    _phase = HostPhase.countdown;
    _countdownRemainingMs = 5000;
    notifyListeners();

    _currentPayload.nextQuestion.add(
      DateTime.now().millisecondsSinceEpoch -
          _currentPayload.masterTimeMs +
          5000,
    );
    _currentPayload.duration.add(questionDuration);
    _currentPayload.choices.add(currentQuestion.options.length);
    _currentPayload.skippedAt.add(-1);
    _publisher!.publish(_currentPayload);

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _countdownRemainingMs -= 100;
      if (_countdownRemainingMs <= 0) {
        _countdownTimer?.cancel();
        _countdownTimer = null;
        _startQuestion();
      } else {
        notifyListeners();
      }
    });
  }

  void skipCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _startQuestion();
  }

  void _startQuestion() {
    _phase = HostPhase.question;
    _questionRemainingMs = questionDuration;
    notifyListeners();

    _questionTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _questionRemainingMs -= 100;
      if (_questionRemainingMs <= 0) {
        _questionTimer?.cancel();
        _questionTimer = null;
        endQuestion();
      } else {
        notifyListeners();
      }
    });
  }

  void endQuestion() {
    _questionTimer?.cancel();
    _questionTimer = null;
    if (_currentQuestionIndex < 0 || _currentQuestionIndex >= questions.length)
      return;
    final now =
        DateTime.now().millisecondsSinceEpoch - _currentPayload.masterTimeMs;
    if (_currentQuestionIndex < _currentPayload.skippedAt.length) {
      _currentPayload.skippedAt[_currentQuestionIndex] = now;
    }
    _calculateScores();
    _phase = HostPhase.answerReveal;
    _publisher!.publish(_currentPayload);
>>>>>>> 60115b4 (feat: host view enchantment)
    notifyListeners();
  }

  void _calculateScores() {
    final correctIndex = currentQuestion.correctAnswerIndex;
    final duration = questionDuration;
    for (final answer in _answers) {
      if (answer.answer == correctIndex) {
        final speedBonus =
            (1 -
                (answer.offsetMs -
                        _currentPayload.nextQuestion[_currentQuestionIndex]) /
                    duration) *
            500;
        final points = (1000 + speedBonus.clamp(0, 500)).toInt();
        _scores[answer.clientId] = (_scores[answer.clientId] ?? 0) + points;
      }
    }
  }

  void showLeaderboard() {
    _phase = HostPhase.leaderboard;
    notifyListeners();
  }

  Future<void> nextFromLeaderboard() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _questionTimer?.cancel();
    _questionTimer = null;

    _currentQuestionIndex++;
    if (_currentQuestionIndex >= questions.length) {
      await endGame();
      return;
    }

    _answers = [];
    _latestPayloads.clear();

    _phase = HostPhase.countdown;
    _countdownRemainingMs = 5000;
    notifyListeners();

    _currentPayload.nextQuestion.add(
      DateTime.now().millisecondsSinceEpoch -
          _currentPayload.masterTimeMs +
          5000,
    );
    _currentPayload.duration.add(questionDuration);
    _currentPayload.choices.add(currentQuestion.options.length);
    _currentPayload.skippedAt.add(-1);
    _publisher!.publish(_currentPayload);

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _countdownRemainingMs -= 100;
      if (_countdownRemainingMs <= 0) {
        _countdownTimer?.cancel();
        _countdownTimer = null;
        _startQuestion();
      } else {
        notifyListeners();
      }
    });
  }

  Future<void> endGame() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _questionTimer?.cancel();
    _questionTimer = null;
    _phase = HostPhase.results;
    _countdownEndsAtMs = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;

    _currentPayload.gameFinished = true;
    _publisher!.publish(_currentPayload);
    _isAdvertising = false;

    notifyListeners();
  }

  @override
  void dispose() {
<<<<<<< HEAD
    _isDisposed = true;
    _countdownTimer?.cancel();
=======
    _countdownTimer?.cancel();
    _questionTimer?.cancel();
>>>>>>> 60115b4 (feat: host view enchantment)
    _clientSub?.cancel();
    _clientListener?.dispose();
    _publisher?.dispose();
    _bleService.dispose();
    super.dispose();
  }
}
