import 'dart:typed_data';

import 'package:flutter/foundation.dart';

abstract class BleServiceBase {
  final ValueNotifier<List<Uint8List>> rawScanData = ValueNotifier([]);
  final ValueNotifier<bool> isAdvertising = ValueNotifier(false);
  final ValueNotifier<bool> isScanning = ValueNotifier(false);

  Future<void> init();
  Future<bool> requestAllPermissions();
  Future<bool> requestScanPermissions();
  Future<bool> requestAdvertisePermissions();
  Future<void> startAdvertising(Uint8List data, {String localName});
  Future<void> stopAdvertising();
  Future<void> startScan({Duration timeout});
  Future<void> stopScan();
  void dispose();
}