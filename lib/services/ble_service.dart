import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

const int kManufacturerId = 0xFFFF;
const String kMasterLocalName = 'KahoofMaster';
const String kNodeLocalNamePrefix = 'KahoofNode';

class BleService {
  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();

  final ValueNotifier<bool> isAdvertising = ValueNotifier(false);
  final ValueNotifier<String> advertisingStatus = ValueNotifier('Idle');
  final ValueNotifier<bool> isScanning = ValueNotifier(false);
  final ValueNotifier<List<ScanResult>> scanResults = ValueNotifier([]);

  StreamSubscription? _advStateSub;
  StreamSubscription? _adapterStateSub;
  StreamSubscription? _isScanningSub;
  StreamSubscription? _scanResultsSub;

  Future<void> init() async {
    _advStateSub = _peripheral.onPeripheralStateChanged?.listen((state) {
      isAdvertising.value = state == PeripheralState.advertising;
      advertisingStatus.value = state.name;
    });

    _adapterStateSub = FlutterBluePlus.adapterState.listen((state) {
      debugPrint('BLE Adapter State: $state');
    });

    _isScanningSub = FlutterBluePlus.isScanning.listen((scanning) {
      isScanning.value = scanning;
    });

    _scanResultsSub = FlutterBluePlus.scanResults.listen((results) {
      scanResults.value = results;
    });

    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  }

  Future<bool> requestAllPermissions() async {
    final status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();
    return status.values.every((s) => s.isGranted);
  }

  Future<bool> requestScanPermissions() async {
    final status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    return status.values.every((s) => s.isGranted);
  }

  Future<bool> requestAdvertisePermissions() async {
    final status = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    return status.values.every((s) => s.isGranted);
  }

  Future<void> startAdvertising(
    Uint8List data, {
    String localName = kMasterLocalName,
  }) async {
    final hasPerms = await requestAdvertisePermissions();
    if (!hasPerms) throw Exception('Missing BLE advertise permissions');

    final isOn = await _peripheral.isBluetoothOn;
    if (!isOn) throw Exception('Bluetooth is off');

    try {
      await _peripheral.stop();
    } catch (e) {
      // Ignore errors if it wasn't advertising
    }

    final advertiseData = AdvertiseData(
      localName: localName,
      manufacturerId: kManufacturerId,
      manufacturerData: data,
    );

    await _peripheral.start(advertiseData: advertiseData);
  }

  Future<void> stopAdvertising() async {
    await _peripheral.stop();
  }

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final hasPerms = await requestScanPermissions();
    if (!hasPerms) throw Exception('Missing BLE scan permissions');

    scanResults.value = [];

    await FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: true,
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  static Uint8List? getManufacturerData(ScanResult result) {
    final data = result.advertisementData.manufacturerData[kManufacturerId];
    if (data == null) return null;
    return Uint8List.fromList(data);
  }

  static bool hasManufacturerData(ScanResult result) {
    return result.advertisementData.manufacturerData.containsKey(
      kManufacturerId,
    );
  }

  void dispose() {
    _advStateSub?.cancel();
    _adapterStateSub?.cancel();
    _isScanningSub?.cancel();
    _scanResultsSub?.cancel();
    stopScan();
    stopAdvertising();
  }
}
