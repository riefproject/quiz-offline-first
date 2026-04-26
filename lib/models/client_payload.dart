import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:py_4/models/byte_serializable.dart';

const CLIENT_PAYLOAD_TYPE = "c";

class ClientAnswer {
  final int answer;
  final int answerMsOffset;

  const ClientAnswer({required this.answer, required this.answerMsOffset});

  Map<String, dynamic> toMsgpackMap() => {'a': answer, 'o': answerMsOffset};

  factory ClientAnswer.fromMsgpackMap(Map<String, dynamic> map) =>
      ClientAnswer(answer: map['a'] as int, answerMsOffset: map['o'] as int);
}

class ClientPayload implements ByteSerializable {
  final payloadType = CLIENT_PAYLOAD_TYPE;
  // max 20 bytes (20 length)
  final String name;
  // answers submitted to the master
  final List<ClientAnswer> answers;
  // the game ID this payload is for
  final int gameId;
  // the client ID
  final int clientId;

  const ClientPayload({
    required this.name,
    required this.answers,
    required this.gameId,
    required this.clientId,
  });

  @override
  Uint8List toBytes() => Uint8List.fromList(msgpack.serialize(toMsgpackMap()));

  Map<String, dynamic> toMsgpackMap() => {
    "t": payloadType,
    'n': name,
    'g': gameId,
    'c': clientId,
    'a': answers.map((e) => e.toMsgpackMap()).toList(),
  };

  factory ClientPayload.fromMsgpackMap(Map<String, dynamic> map) =>
      ClientPayload(
        name: map['n'] as String,
        gameId: map['g'] as int,
        clientId: map['c'] as int,
        answers: (map['a'] as List)
            .map(
              (e) => ClientAnswer.fromMsgpackMap(Map<String, dynamic>.from(e)),
            )
            .toList(),
      );

  factory ClientPayload.fromBytes(Uint8List bytes) {
    final decoded = msgpack.deserialize(bytes);
    if (decoded is Map) {
      if ((decoded as Map<String, dynamic>)['t'] != CLIENT_PAYLOAD_TYPE) {
        throw FormatException('Invalid payload type');
      }
      return ClientPayload.fromMsgpackMap(Map<String, dynamic>.from(decoded));
    }
    throw FormatException('Invalid ClientPayload format');
  }
}
