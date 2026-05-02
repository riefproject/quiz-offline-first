import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:py_4/models/byte_serializable.dart';
import 'package:py_4/models/game_payload.dart';

const MASTER_PAYLOAD_TYPE = "m";

class MasterPayload implements ByteSerializable, GamePayload {
  final payloadType = MASTER_PAYLOAD_TYPE;
  // anchored time
  final int masterTimeMs;
  // next question in ms after the master time
  final List<int> nextQuestion;
  // flag for is game finished
  bool? gameFinished = false;
  // game ID. randomly generated
  @override
  final int gameID;

  MasterPayload({
    required this.masterTimeMs,
    this.nextQuestion = const [],
    this.gameFinished,
    required this.gameID,
  });

  Map<String, dynamic> toMsgpackMap() {
    final map = <String, dynamic>{
      't': MASTER_PAYLOAD_TYPE,
      'mt': masterTimeMs,
      'g': gameID,
    };

    if (nextQuestion.isNotEmpty) {
      map['nq'] = nextQuestion;
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
        gameFinished: map.containsKey('f') && map['f'] == 1,
        gameID: map['g'] as int,
      );

  factory MasterPayload.fromBytes(Uint8List bytes) {
    final decoded = msgpack.deserialize(bytes);
    if (decoded is Map) {
      final map = (decoded as Map).cast<String, dynamic>();
      if (map['t'] != MASTER_PAYLOAD_TYPE) {
        throw FormatException('Invalid payload type');
      }
      return MasterPayload.fromMsgpackMap(Map<String, dynamic>.from(decoded));
    }
    throw FormatException('Invalid MasterMessage format');
  }
}
