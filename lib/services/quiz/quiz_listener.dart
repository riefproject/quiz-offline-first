import 'dart:async';
import 'dart:typed_data';

import 'package:py_4/services/ble_service_base.dart';

abstract class QuizListener<T> {
  final _controller = StreamController<T>();

  Stream<T> get stream => _controller.stream;
  BleServiceBase bleService;

  T? parseResult(Uint8List data);

  void _onScanData() {
    for (final bytes in bleService.rawScanData.value) {
      try {
        final payload = parseResult(bytes);
        if (payload == null) continue;
        _controller.sink.add(payload);
      } catch (e) {
        print(e);
      }
    }
  }

  QuizListener({required this.bleService}) {
    bleService.rawScanData.addListener(_onScanData);
  }

  void dispose() {
    bleService.rawScanData.removeListener(_onScanData);
    _controller.close();
  }
}