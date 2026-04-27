import 'dart:async';
import 'package:py_4/models/byte_serializable.dart';
import 'package:py_4/services/ble_payload_formatter.dart';
import 'package:py_4/services/ble_service_base.dart';
import 'package:py_4/services/logger.dart';

class QuizPublisher<T extends ByteSerializable> {
  final BleServiceBase bleService;
  final String _typeName;

  Timer? _cooldownTimer;
  T? _queuedPayload;

  QuizPublisher({required this.bleService, required String typeName})
      : _typeName = typeName;

  void publish(T data) {
    final bytes = data.toBytes();
    if (_cooldownTimer?.isActive ?? false) {
      log.d('Publisher($_typeName): queued (cooldown active)\n${formatBlePayload(bytes)}');
      _queuedPayload = data;
    } else {
      _executePublish(data);
    }
  }

  void _executePublish(T data) {
    final bytes = data.toBytes();
    log.i('Publisher($_typeName): emitting (${bytes.length} bytes)\n${formatBlePayload(bytes)}');
    bleService.startAdvertising(bytes);

    _cooldownTimer = Timer(const Duration(milliseconds: 200), () {
      if (_queuedPayload != null) {
        final nextData = _queuedPayload!;
        _queuedPayload = null;
        _executePublish(nextData);
      }
    });
  }

  void dispose() {
    log.d('Publisher($_typeName): disposed');
    _cooldownTimer?.cancel();
  }
}