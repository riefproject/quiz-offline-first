import 'dart:convert';
import 'dart:typed_data';

import 'package:py_4/models/client_payload.dart';
import 'package:py_4/models/master_payload.dart';
import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;

String _formatTimestamp(int ms) {
  final dt = DateTime.fromMillisecondsSinceEpoch(ms);
  return '${dt.hour.toString().padLeft(2, "0")}:'
      '${dt.minute.toString().padLeft(2, "0")}:'
      '${dt.second.toString().padLeft(2, "0")}.'
      '${dt.millisecond.toString().padLeft(3, "0")}';
}

String formatBlePayload(Uint8List data) {
  try {
    final decoded = msgpack.deserialize(data);
    if (decoded is! Map) {
      return ' [${data.length} raw bytes]';
    }
    final map = Map<String, dynamic>.from(decoded);
    final type = map['t'];

    if (type == MASTER_PAYLOAD_TYPE) {
      try {
        final payload = MasterPayload.fromBytes(data);
        final pretty = payload.toMsgpackMap()
          ..['masterTimeMs'] = _formatTimestamp(payload.masterTimeMs);
        if (payload.nextQuestion.isNotEmpty) {
          pretty['nextQuestion_offsets'] = payload.nextQuestion
              .map((ms) => '${(ms / 1000).toStringAsFixed(1)}s')
              .toList();
        }
        return '\n${const JsonEncoder.withIndent('  ').convert(pretty)}';
      } catch (_) {
        return '\n${const JsonEncoder.withIndent('  ').convert(map)}';
      }
    }

    if (type == CLIENT_PAYLOAD_TYPE) {
      try {
        final payload = ClientPayload.fromBytes(data);
        final pretty = <String, dynamic>{
          't': payload.payloadType,
          'name': payload.name,
          'gameId': payload.gameID,
          'clientId': payload.clientId,
          'answers': payload.answers
              .map(
                (a) => {
                  'answer': a.answer,
                  'offsetMs': '${a.answerMsOffset}ms',
                },
              )
              .toList(),
        };
        return '\n${const JsonEncoder.withIndent('  ').convert(pretty)}';
      } catch (_) {
        return '\n${const JsonEncoder.withIndent('  ').convert(map)}';
      }
    }

    return '\n${const JsonEncoder.withIndent('  ').convert(map)}';
  } catch (_) {
    final hex = data
        .take(16)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(' ');
    return ' [${data.length} bytes, hex: $hex${data.length > 16 ? ' ...' : ''}]';
  }
}
