import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:py_4/services/ble_service_base.dart';

const int kManufacturerId = 0xFFFF;
const String kMasterLocalName = 'KahoofMaster';
const String kNodeLocalNamePrefix = 'KahoofNode';

class BleService extends BleServiceBase {
  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();

  final ValueNotifier<String> advertisingStatus = ValueNotifier('Idle');

  StreamSubscription? _advStateSub;
  StreamSubscription? _adapterStateSub;
  StreamSubscription? _isScanningSub;
  StreamSubscription? _scanResultsSub;

  @override
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
      final bytesList = <Uint8List>[];
      for (final result in results) {
        final data = result.advertisementData.manufacturerData[kManufacturerId];
        if (data != null) {
          bytesList.add(Uint8List.fromList(data));
        }
      }
      rawScanData.value = bytesList;
    });

    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  }

  @override
  Future<bool> requestAllPermissions() async {
    final status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();
    return status.values.every((s) => s.isGranted);
  }

  @override
  Future<bool> requestScanPermissions() async {
    final status = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    return status.values.every((s) => s.isGranted);
  }

  @override
  Future<bool> requestAdvertisePermissions() async {
    final status = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    return status.values.every((s) => s.isGranted);
  }

  @override
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

  @override
  Future<void> stopAdvertising() async {
    await _peripheral.stop();
  }

  @override
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final hasPerms = await requestScanPermissions();
    if (!hasPerms) throw Exception('Missing BLE scan permissions');

    rawScanData.value = [];

    await FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: true,
    );
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  @override
  void dispose() {
    _advStateSub?.cancel();
    _adapterStateSub?.cancel();
    _isScanningSub?.cancel();
    _scanResultsSub?.cancel();
    stopScan();
    stopAdvertising();
  }
}