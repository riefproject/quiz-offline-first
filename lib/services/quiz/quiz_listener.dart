import 'dart:async';
import 'dart:typed_data';

import 'package:py_4/services/ble_payload_formatter.dart';
import 'package:py_4/services/ble_service_base.dart';
import 'package:py_4/services/logger.dart';

abstract class QuizListener<T> {
  final _controller = StreamController<T>();

  Stream<T> get stream => _controller.stream;
  BleServiceBase bleService;
  final String _typeName;

  T? parseResult(Uint8List data);

  void _onScanData() {
    final entries = bleService.rawScanData.value;
    log.d('Listener($_typeName): received ${entries.length} scan entries');
    for (final bytes in entries) {
      try {
        final payload = parseResult(bytes);
        if (payload == null) {
          log.d('Listener($_typeName): payload filtered\n${formatBlePayload(bytes)}');
          continue;
        }
        log.i('Listener($_typeName): payload parsed\n${formatBlePayload(bytes)}');
        _controller.sink.add(payload);
      } catch (e) {
        log.w('Listener($_typeName): parse error — $e\n${formatBlePayload(bytes)}');
      }
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