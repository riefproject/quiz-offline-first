import 'dart:async';
import 'package:py_4/models/byte_serializable.dart';
import 'package:py_4/services/ble_service_base.dart';

class QuizPublisher<T extends ByteSerializable> {
  final BleServiceBase bleService;

  Timer? _cooldownTimer;
  T? _queuedPayload;

  QuizPublisher({required this.bleService});

  void publish(T data) {
    if (_cooldownTimer?.isActive ?? false) {
      _queuedPayload = data;
    } else {
      _executePublish(data);
    }
  }

  void _executePublish(T data) {
    bleService.startAdvertising(data.toBytes());

    _cooldownTimer = Timer(const Duration(milliseconds: 200), () {
      if (_queuedPayload != null) {
        final nextData = _queuedPayload!;
        _queuedPayload = null;
        _executePublish(nextData);
      }
    });
  }

  void dispose() {
    _cooldownTimer?.cancel();
  }
}