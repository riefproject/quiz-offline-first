import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:py_4/models/question.dart';

enum GamePhase {
  idle,
  syncing,
  waitingQuestion,
  questionActive,
  showingResults,
  finished,
}

class MasterMessage {
  final int masterTimeMs;
  final Question? question;
  final int? questionStartTimeMs;
  final bool? gameFinished;

  const MasterMessage({
    required this.masterTimeMs,
    this.question,
    this.questionStartTimeMs,
    this.gameFinished,
  });

  Map<String, dynamic> toMsgpackMap() {
    final map = <String, dynamic>{'t': 'm', 'mt': masterTimeMs};
    if (question != null) {
      map['q'] = question!.toMsgpackMap();
      map['s'] = questionStartTimeMs!;
    }
    if (gameFinished == true) {
      map['f'] = 1;
    }
    return map;
  }

  Uint8List toBytes() => Uint8List.fromList(msgpack.serialize(toMsgpackMap()));

  factory MasterMessage.fromMsgpackMap(Map<String, dynamic> map) =>
      MasterMessage(
        masterTimeMs: map['mt'] as int,
        question: map.containsKey('q')
            ? Question.fromMsgpackMap(map['q'] as Map<String, dynamic>)
            : null,
        questionStartTimeMs: map['s'] as int?,
        gameFinished: map.containsKey('f') && map['f'] == 1,
      );

  factory MasterMessage.fromBytes(Uint8List bytes) {
    final decoded = msgpack.deserialize(bytes);
    if (decoded is Map) {
      return MasterMessage.fromMsgpackMap(Map<String, dynamic>.from(decoded));
    }
    throw FormatException('Invalid MasterMessage format');
  }
}
