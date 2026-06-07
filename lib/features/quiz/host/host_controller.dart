import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:AlpenQuiz/models/client_payload.dart';
import 'package:AlpenQuiz/models/master_payload.dart';
import 'package:AlpenQuiz/models/question.dart';
import 'package:AlpenQuiz/models/reverse_qr_submission.dart';
import 'package:AlpenQuiz/services/auth_service.dart';
import 'package:AlpenQuiz/services/hive_service.dart';
import 'package:AlpenQuiz/services/logger.dart';
import 'package:AlpenQuiz/services/quiz_history_service.dart';
import 'package:AlpenQuiz/services/reverse_qr_sync_service.dart';
import 'package:AlpenQuiz/services/audio_service.dart';
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
    var entries = _scores.entries.map((e) {
      final name = _participants[e.key] ?? 'Unknown';
      return (name: name, clientId: e.key, score: e.value, rank: 0);
    }).toList();

    for (final entry in _participants.entries) {
      if (!_scores.containsKey(entry.key)) {
        entries.add((
          name: entry.value,
          clientId: entry.key,
          score: 0,
          rank: 0,
        ));
      }
    }

    final hasAnyScore = entries.any((e) => e.score > 0);
    if (hasAnyScore) {
      entries.sort((a, b) => b.score.compareTo(a.score));
    } else {
      entries.sort((a, b) => a.name.compareTo(b.name));
    }

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
  int _lastCountdownSecond = 0;

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

  HostController({required this.quizId}) {
    if (!_canCurrentUserHostQuiz(quizId)) {
      throw StateError('You do not have permission to start this quiz.');
    }
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
      throw StateError('You do not have permission to start this quiz.');
    }

    _gameId = Random().nextInt(999999) + 100000;
    _sessionId = 'sesi_$_gameId';
    _sessionStartedAt = DateTime.now();
    _sessionFinishedAt = null;

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
    AudioService.instance.playBgm();
    notifyListeners();
    log.i(
      'HostController: game started gameId=$_gameId questionCount=${questions.length}',
    );
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
      if (_currentQuestionIndex < 0 ||
          _currentQuestionIndex >= p.answers.length) {
        return <ParticipantAnswer>[];
      }
      final a = p.answers[_currentQuestionIndex];
      return [
        ParticipantAnswer(
          name: p.name,
          clientId: p.clientId,
          answer: a.answer,
          offsetMs: a.answerMsOffset,
        ),
      ];
    }).toList();

    notifyListeners();
  }

  Future<void> nextQuestion() async {
    AudioService.instance.stopBgm();
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
    _lastCountdownSecond = (_countdownRemainingMs / 1000).ceil() + 1;
    notifyListeners();

    _currentPayload.nextQuestion.add(
      DateTime.now().millisecondsSinceEpoch -
          _currentPayload.masterTimeMs +
          5000,
    );
    _currentPayload.duration.add(questionDuration);
    _currentPayload.choices.add(currentQuestion.options.length);
    _currentPayload.skippedAt.add(-1);
    _lanPublisher!.publish(_currentPayload);

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _countdownRemainingMs -= 100;
      if (_countdownRemainingMs <= 0) {
        _countdownTimer?.cancel();
        _countdownTimer = null;
        _startQuestion();
      } else {
        final currentSecond = (_countdownRemainingMs / 1000).ceil();
        if (currentSecond != _lastCountdownSecond) {
          _lastCountdownSecond = currentSecond;
          AudioService.instance.playTick();
        }
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

    AudioService.instance.playBgm();

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
    AudioService.instance.stopBgm();
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
    _lanPublisher!.publish(_currentPayload);
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
    AudioService.instance.stopBgm();
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
    _lastCountdownSecond = (_countdownRemainingMs / 1000).ceil() + 1;
    notifyListeners();

    _currentPayload.nextQuestion.add(
      DateTime.now().millisecondsSinceEpoch -
          _currentPayload.masterTimeMs +
          5000,
    );
    _currentPayload.duration.add(questionDuration);
    _currentPayload.choices.add(currentQuestion.options.length);
    _currentPayload.skippedAt.add(-1);
    _lanPublisher!.publish(_currentPayload);

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _countdownRemainingMs -= 100;
      if (_countdownRemainingMs <= 0) {
        _countdownTimer?.cancel();
        _countdownTimer = null;
        _startQuestion();
      } else {
        final currentSecond = (_countdownRemainingMs / 1000).ceil();
        if (currentSecond != _lastCountdownSecond) {
          _lastCountdownSecond = currentSecond;
          AudioService.instance.playTick();
        }
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

    AudioService.instance.stopBgm();
    AudioService.instance.playFanfare();

    _currentPayload.gameFinished = true;
    _lanPublisher!.publish(_currentPayload);
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
    AudioService.instance.stopBgm();
    _countdownTimer?.cancel();
    _questionTimer?.cancel();
    _clientSub?.cancel();
    _lanClientListener?.dispose();
    _lanPublisher?.dispose();
    _lanService?.dispose();
    super.dispose();
  }
}
