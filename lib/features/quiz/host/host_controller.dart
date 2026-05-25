import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:AlpenQuiz/config.dart';
import 'package:AlpenQuiz/models/client_payload.dart';
import 'package:AlpenQuiz/models/master_payload.dart';
import 'package:AlpenQuiz/models/question.dart';
import 'package:AlpenQuiz/models/reverse_qr_submission.dart';
import 'package:AlpenQuiz/services/auth_service.dart';
import 'package:AlpenQuiz/services/ble_service_base.dart';
import 'package:AlpenQuiz/services/ble_service.dart';
import 'package:AlpenQuiz/services/hive_service.dart';
import 'package:AlpenQuiz/services/logger.dart';
import 'package:AlpenQuiz/services/mock_ble_service.dart';
import 'package:AlpenQuiz/services/quiz_history_service.dart';
import 'package:AlpenQuiz/services/quiz/client_listener.dart';
import 'package:AlpenQuiz/services/quiz/master_publisher.dart';
import 'package:AlpenQuiz/services/reverse_qr_sync_service.dart';
import 'package:AlpenQuiz/services/lan/lan_service.dart';
import 'package:AlpenQuiz/services/lan/lan_client_listener.dart';
import 'package:AlpenQuiz/services/lan/lan_master_publisher.dart';

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
  late BleServiceBase _bleService;
  MasterPublisher? _publisher;
  ClientListener? _clientListener;

  LanService? _lanService;
  LanMasterPublisher? _lanPublisher;
  LanClientListener? _lanClientListener;

  int _gameId = 0;
  int get gameId => _gameId;
  String _sessionId = '';
  String get sessionId => _sessionId;
  DateTime? _sessionStartedAt;
  DateTime? _sessionFinishedAt;

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

  final Map<int, ClientPayload> _latestPayloads = {};

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
    questionCount: 0,
    masterTimeMs: DateTime.now().millisecondsSinceEpoch,
    nextQuestion: [],
    choices: [],
    duration: [],
    skippedAt: [],
    gameID: 0,
  );

  HostController({BleServiceBase? bleService, required this.quizId}) {
    if (!_canCurrentUserHostQuiz(quizId)) {
      throw StateError('Anda tidak memiliki izin untuk memulai kuis ini.');
    }

    _bleService = Config.isSessionMocked
        ? MockBleService()
        : bleService ?? BleService();
    questions = Question.fromQuizId(quizId);
    log.i(
      'HostController: loaded ${questions.length} questions for quiz $quizId',
    );
  }

  bool _canCurrentUserHostQuiz(String quizId) {
    final session = AuthService.currentSession;
    final quiz = HiveService.quizBox.get(quizId);
    if (session == null || session.isGuest || quiz == null) return false;

    return quiz.pembuat == session.userId ||
        quiz.pembuat == session.displayName;
  }

  Future<void> startGame() async {
    if (!_canCurrentUserHostQuiz(quizId)) {
      throw StateError('Anda tidak memiliki izin untuk memulai kuis ini.');
    }

    _gameId = Random().nextInt(999999) + 100000;
    _sessionId = 'sesi_$_gameId';
    _sessionStartedAt = DateTime.now();
    _sessionFinishedAt = null;

    if (Config.useLan) {
      _lanService = await LanService.host(
        gameId: _gameId,
        questionCount: questions.length,
      );
      _lanPublisher = LanMasterPublisher(lanService: _lanService!);
      _lanClientListener = LanClientListener(
        lanService: _lanService!,
        gameId: _gameId,
      );
      _clientSub = _lanClientListener!.stream.listen(_onClientPayload);

      _currentPayload = MasterPayload(
        questionCount: questions.length,
        masterTimeMs: DateTime.now().millisecondsSinceEpoch,
        nextQuestion: [],
        gameID: _gameId,
      );
      _lanPublisher!.publish(_currentPayload);

      _isAdvertising = true;
      notifyListeners();
      log.i(
        'HostController: LAN game started gameId=$_gameId questionCount=${questions.length}',
      );
      return;
    }

    await _bleService.init();
    await _bleService.requestAllPermissions();

    _publisher = MasterPublisher(bleService: _bleService);
    _clientListener = ClientListener(bleService: _bleService, gameId: _gameId);
    _bleService.startScan(timeout: Duration(seconds: 120));

    _clientSub = _clientListener!.stream.listen(_onClientPayload);

    final payload = MasterPayload(
      questionCount: questions.length,
      masterTimeMs: DateTime.now().millisecondsSinceEpoch,
      nextQuestion: [],
      gameID: _gameId,
    );
    _currentPayload = payload;
    _currentPayload = MasterPayload(
      questionCount: questions.length,
      masterTimeMs: payload.masterTimeMs,
      nextQuestion: payload.nextQuestion,
      duration: payload.duration,
      choices: payload.choices,
      skippedAt: payload.skippedAt,
      gameFinished: payload.gameFinished,
      gameID: _gameId,
    );
    _publishCurrentPayload();

    _isAdvertising = true;
    notifyListeners();
  }

  void _publishCurrentPayload() {
    if (Config.useLan) {
      _lanPublisher!.publish(_currentPayload);
    } else {
      _publishCurrentPayload();
    }
  }

  void _onClientPayload(ClientPayload payload) {
    if (payload.gameID != _gameId) return;

    _participants[payload.clientId] = payload.name;

    final existing = _latestPayloads[payload.clientId];
    if (existing != null &&
        existing.toBytes().length >= payload.toBytes().length) {
      return;
    }

    _latestPayloads[payload.clientId] = payload;

    _answers = _latestPayloads.values.expand((p) {
      return p.answers.map(
        (a) => ParticipantAnswer(
          name: p.name,
          clientId: p.clientId,
          answer: a.answer,
          offsetMs: a.answerMsOffset,
        ),
      );
    }).toList();

    notifyListeners();
  }

  Future<void> nextQuestion() async {
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
    _publishCurrentPayload();

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
    if (_currentQuestionIndex < 0 || _currentQuestionIndex >= questions.length) {
      return;
    }
    final now =
        DateTime.now().millisecondsSinceEpoch - _currentPayload.masterTimeMs;
    if (_currentQuestionIndex < _currentPayload.skippedAt.length) {
      _currentPayload.skippedAt[_currentQuestionIndex] = now;
    }
    _calculateScores();
    _phase = HostPhase.answerReveal;
    _publishCurrentPayload();
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
    _publishCurrentPayload();

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
    _sessionFinishedAt = DateTime.now();

    _currentPayload.gameFinished = true;
    _publishCurrentPayload();
    _isAdvertising = false;

    final startedAt = _sessionStartedAt;
    if (startedAt != null && _sessionId.isNotEmpty) {
      await QuizHistoryService.saveHostedSession(
        quizId: quizId,
        sessionId: _sessionId,
        startedAt: startedAt,
        finishedAt: _sessionFinishedAt!,
        participants: _participants,
        scores: _scores,
      );
    }

    notifyListeners();
  }

  Future<ReverseQrImportResult> importReverseQrSubmission(
    ReverseQrSubmission submission,
  ) async {
    if (submission.gameId != _gameId) {
      throw const ReverseQrSyncException(
        'QR ini berasal dari game yang berbeda.',
      );
    }
    final startedAt = _sessionStartedAt;
    if (startedAt == null || _sessionId.isEmpty) {
      throw const ReverseQrSyncException(
        'Sesi host belum siap untuk menerima fallback QR.',
      );
    }

    final result = await ReverseQrSyncService.importSubmission(
      submission: submission,
      quizId: quizId,
      sessionId: _sessionId,
      sessionStartedAt: startedAt,
      sessionFinishedAt: _sessionFinishedAt,
      questionStartOffsets: List<int>.from(_currentPayload.nextQuestion),
      questionDurations: List<int>.from(_currentPayload.duration),
    );

    _participants[submission.clientId] = submission.participantName;
    _scores[submission.clientId] = result.totalScore;
    final rankMap = await QuizHistoryService.saveHostedSession(
      quizId: quizId,
      sessionId: _sessionId,
      startedAt: startedAt,
      finishedAt: _sessionFinishedAt ?? DateTime.now(),
      participants: _participants,
      scores: _scores,
    );
    notifyListeners();

    return ReverseQrImportResult(
      importedAnswerCount: result.importedAnswerCount,
      totalScore: result.totalScore,
      rank: rankMap[submission.clientId] ?? result.rank,
      participantName: result.participantName,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _questionTimer?.cancel();
    _clientSub?.cancel();
    _clientListener?.dispose();
    _publisher?.dispose();
    _lanClientListener?.dispose();
    _lanPublisher?.dispose();
    _lanService?.dispose();
    _bleService.dispose();
    super.dispose();
  }
}
