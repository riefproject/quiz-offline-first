import 'client_payload.dart';

class ReverseQrAnswer {
  final int questionIndex;
  final int answerIndex;
  final int answerMsOffset;

  const ReverseQrAnswer({
    required this.questionIndex,
    required this.answerIndex,
    required this.answerMsOffset,
  });

  factory ReverseQrAnswer.fromClientAnswer({
    required int questionIndex,
    required ClientAnswer answer,
  }) {
    return ReverseQrAnswer(
      questionIndex: questionIndex,
      answerIndex: answer.answer,
      answerMsOffset: answer.answerMsOffset,
    );
  }

  factory ReverseQrAnswer.fromJson(Map<String, dynamic> json) {
    return ReverseQrAnswer(
      questionIndex: json['q'] as int,
      answerIndex: json['a'] as int,
      answerMsOffset: json['o'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'q': questionIndex,
        'a': answerIndex,
        'o': answerMsOffset,
      };
}

class ReverseQrSubmission {
  static const int schemaVersion = 1;

  final String participantUserId;
  final String participantName;
  final int gameId;
  final int clientId;
  final int createdAtMs;
  final List<ReverseQrAnswer> answers;

  ReverseQrSubmission({
    required this.participantUserId,
    required this.participantName,
    required this.gameId,
    required this.clientId,
    required this.createdAtMs,
    required List<ReverseQrAnswer> answers,
  }) : answers = List.unmodifiable(answers);

  factory ReverseQrSubmission.fromClientAnswers({
    required String participantUserId,
    required String participantName,
    required int gameId,
    required int clientId,
    required List<ClientAnswer> answers,
    int? createdAtMs,
  }) {
    return ReverseQrSubmission(
      participantUserId: participantUserId,
      participantName: participantName,
      gameId: gameId,
      clientId: clientId,
      createdAtMs: createdAtMs ?? DateTime.now().millisecondsSinceEpoch,
      answers: [
        for (var index = 0; index < answers.length; index++)
          ReverseQrAnswer.fromClientAnswer(
            questionIndex: index,
            answer: answers[index],
          ),
      ],
    );
  }

  factory ReverseQrSubmission.fromJson(Map<String, dynamic> json) {
    if (json['v'] != schemaVersion) {
      throw FormatException('Unsupported reverse QR schema version: ${json['v']}');
    }

    final answersJson = json['a'];
    if (answersJson is! List) {
      throw const FormatException('Invalid reverse QR answers payload');
    }

    return ReverseQrSubmission(
      participantUserId: json['u'] as String,
      participantName: json['n'] as String,
      gameId: json['g'] as int,
      clientId: json['c'] as int,
      createdAtMs: json['t'] as int,
      answers: answersJson.map((entry) {
        if (entry is! Map) {
          throw const FormatException('Invalid reverse QR answer entry');
        }
        return ReverseQrAnswer.fromJson(Map<String, dynamic>.from(entry));
      }).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'v': schemaVersion,
        'u': participantUserId,
        'n': participantName,
        'g': gameId,
        'c': clientId,
        't': createdAtMs,
        'a': answers.map((entry) => entry.toJson()).toList(growable: false),
      };

  int get submittedAnswerCount =>
      answers.where((answer) => answer.answerIndex >= 0).length;
}

class ReverseQrImportResult {
  final int importedAnswerCount;
  final int totalScore;
  final int rank;
  final String participantName;

  const ReverseQrImportResult({
    required this.importedAnswerCount,
    required this.totalScore,
    required this.rank,
    required this.participantName,
  });
}
