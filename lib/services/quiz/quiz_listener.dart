import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:py_4/services/ble_service.dart';

abstract class QuizListener<T> {
  final _controller = StreamController<T>();

  Stream<T> get stream => _controller.stream;
  BleService bleService;

  T? parseResult(ScanResult result);

  void _onScanResult() {
    for (var result in bleService.scanResults.value) {
      if (BleService.hasManufacturerData(result)) {
        final data = BleService.getManufacturerData(result);
        if (data != null) {
          try {
            final payload = parseResult(result);

            if (payload == null) continue;

            _controller.sink.add(payload);
          } catch (e) {
            // TODO: log error
            print(e);
          }
        }
      }
    }
  }

  QuizListener({required this.bleService}) {
    bleService.scanResults.addListener(_onScanResult);
  }

  void dispose() {
    bleService.scanResults.removeListener(_onScanResult);
    _controller.close();
  }
}
