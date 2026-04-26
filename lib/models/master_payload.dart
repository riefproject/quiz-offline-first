import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:py_4/models/byte_serializable.dart';

const MASTER_PAYLOAD_TYPE = "m";

class MasterPayload implements ByteSerializable {
  final payloadType = MASTER_PAYLOAD_TYPE;
  // anchored time
  final int masterTimeMs;
  // next question in ms after the master time
  final List<int> nextQuestion;
  // flag for is game finished
  final bool? gameFinished;
  // game ID. randomly generated
  final int gameID;

  const MasterPayload({
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
        gameFinished: map.containsKey('f') && map['f'] == 1,
        gameID: map['g'] as int,
      );

  factory MasterPayload.fromBytes(Uint8List bytes) {
    final decoded = msgpack.deserialize(bytes);
    if (decoded is Map) {
      if ((decoded as Map<String, dynamic>)['t'] != MASTER_PAYLOAD_TYPE) {
        throw FormatException('Invalid payload type');
      }
      return MasterPayload.fromMsgpackMap(Map<String, dynamic>.from(decoded));
    }
    throw FormatException('Invalid MasterMessage format');
  }
}
