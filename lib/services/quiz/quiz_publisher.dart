import 'dart:async';
import 'package:py_4/models/master_payload.dart';
import 'package:py_4/services/ble_service.dart';
import 'package:py_4/models/byte_serializable.dart';

class QuizPublisher<T extends ByteSerializable> {
  final BleService bleService;

  Timer? _cooldownTimer;
  T? _queuedPayload;

  QuizPublisher({required this.bleService});

  void publish(T data) {
    // 1. Check if we are currently in a cooldown period
    if (_cooldownTimer?.isActive ?? false) {
      // 2. We are cooling down. Overwrite the queue with this NEWEST data.
      // Any older data sitting in the queue is instantly destroyed.
      _queuedPayload = data;
    } else {
      // 3. No cooldown! The line is clear. Publish immediately.
      _executePublish(data);
    }
  }

  void _executePublish(T data) {
    // Send it to the BLE hardware
    bleService.startAdvertising(data.toBytes());

    // Start the 200ms cooldown timer
    _cooldownTimer = Timer(const Duration(milliseconds: 200), () {
      // When the 200ms is up, check if anyone left data in the queue
      if (_queuedPayload != null) {
        // Grab the latest queued data, clear the queue, and publish it
        final nextData = _queuedPayload!;
        _queuedPayload = null;

        // This will restart the cooldown loop
        _executePublish(nextData);
      }
    });
  }

  // Prevent memory leaks if this publisher is ever destroyed
  void dispose() {
    _cooldownTimer?.cancel();
  }
}
