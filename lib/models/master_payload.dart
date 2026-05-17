import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:AlpenQuiz/models/byte_serializable.dart';
import 'package:AlpenQuiz/models/game_payload.dart';

const MASTER_PAYLOAD_TYPE = "m";

class MasterQuestionInfo {
  final int nextQuestionMs;
  final int durationMs;
  final int choicesCount;
  final int skippedAtMs;

  const MasterQuestionInfo({
    required this.nextQuestionMs,
    required this.durationMs,
    required this.choicesCount,
    this.skippedAtMs = -1,
  });
}

class MasterPayload implements ByteSerializable, GamePayload {
  final payloadType = MASTER_PAYLOAD_TYPE;
  // anchored time
  final int masterTimeMs;
  // next question in ms after the master time
  final List<int> nextQuestion;
  // duration per question in ms
  final List<int> duration;
  // number of choices per question
  final List<int> choices;
  // ms offset when question was cut short (-1 if not skipped)
  final List<int> skippedAt;
  // flag for is game finished
  bool? gameFinished = false;
  // game ID. randomly generated
  @override
  final int gameID;

  MasterPayload({
    required this.masterTimeMs,
    List<int>? nextQuestion,
    List<int>? duration,
    List<int>? choices,
    List<int>? skippedAt,
    this.gameFinished,
    required this.gameID,
  }) : nextQuestion = nextQuestion ?? [],
       duration = duration ?? [],
       choices = choices ?? [],
       skippedAt = skippedAt ?? [];

  MasterQuestionInfo questionInfoAt(int index) {
    return MasterQuestionInfo(
      nextQuestionMs: index < nextQuestion.length ? nextQuestion[index] : 0,
      durationMs: index < duration.length ? duration[index] : 0,
      choicesCount: index < choices.length ? choices[index] : 0,
      skippedAtMs: index < skippedAt.length ? skippedAt[index] : -1,
    );
  }

  Map<String, dynamic> toMsgpackMap() {
    final map = <String, dynamic>{
      't': MASTER_PAYLOAD_TYPE,
      'mt': masterTimeMs,
      'g': gameID,
    };

    if (nextQuestion.isNotEmpty) {
      map['nq'] = nextQuestion;
    }

    if (duration.isNotEmpty) {
      map['du'] = duration;
    }

    if (choices.isNotEmpty) {
      map['ch'] = choices;
    }

    if (skippedAt.isNotEmpty) {
      map['sa'] = skippedAt;
    }

    if (gameFinished == true) {
      map['f'] = 1;
    }

    return map;
  }

  @override
  Uint8List toBytes() => Uint8List.fromList(msgpack.serialize(toMsgpackMap()));

  factory MasterPayload.fromMsgpackMap(Map<String, dynamic> map) =>
      MasterPayload(
        masterTimeMs: map['mt'] as int,
        nextQuestion: (map['nq'] as List?)?.cast<int>() ?? const [],
        duration: (map['du'] as List?)?.cast<int>() ?? const [],
        choices: (map['ch'] as List?)?.cast<int>() ?? const [],
        skippedAt: (map['sa'] as List?)?.cast<int>() ?? const [],
        gameFinished: map.containsKey('f') && map['f'] == 1,
        gameID: map['g'] as int,
      );

  factory MasterPayload.fromBytes(Uint8List bytes) {
    final decoded = msgpack.deserialize(bytes);
    if (decoded is Map) {
      final map = (decoded).cast<String, dynamic>();
      if (map['t'] != MASTER_PAYLOAD_TYPE) {
        throw FormatException('Invalid payload type');
      }
      return MasterPayload.fromMsgpackMap(Map<String, dynamic>.from(decoded));
    }
    throw FormatException('Invalid MasterMessage format');
  }
}
