import 'dart:async';
import 'dart:typed_data';

import 'package:py_4/models/game_payload.dart';
import 'package:py_4/services/ble_payload_formatter.dart';
import 'package:py_4/services/ble_service_base.dart';
import 'package:py_4/services/logger.dart';

abstract class QuizListener<T extends GamePayload> {
  final _controller = StreamController<T>();

  Stream<T> get stream => _controller.stream;
  BleServiceBase bleService;
  final String _typeName;

  T? parseResult(Uint8List data);

  void _onScanData() {
    final entries = bleService.rawScanData.value;
    final bestPayloads = <int, _PayloadWrapper<T>>{};

    for (final bytes in entries) {
      try {
        final payload = parseResult(bytes);
        if (payload == null) continue;

        final id = payload.gameID;
        final weight = bytes.length;

        if (!bestPayloads.containsKey(id) ||
            bestPayloads[id]!.weight < weight) {
          bestPayloads[id] = _PayloadWrapper(
            payload: payload,
            weight: weight,
            bytes: bytes,
          );
        }
      } catch (e) {
        log.w('Listener($_typeName): parse error — $e');
      }
    }

    for (final wrapper in bestPayloads.values) {
      _controller.sink.add(wrapper.payload);
    }
  }

  QuizListener({required this.bleService, required String typeName})
    : _typeName = typeName {
    bleService.rawScanData.addListener(_onScanData);
  }

  void dispose() {
    log.d('Listener($_typeName): disposed');
    bleService.rawScanData.removeListener(_onScanData);
    _controller.close();
  }
}

class _PayloadWrapper<T> {
  final T payload;
  final int weight;
  final Uint8List bytes;

  _PayloadWrapper({
    required this.payload,
    required this.weight,
    required this.bytes,
  });
}
