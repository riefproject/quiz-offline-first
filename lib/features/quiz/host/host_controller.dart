import 'package:py_4/services/ble_service.dart';

class HostController {
  final BleService _bleService;

  HostController(this._bleService);

  Future<void> init() async {
    await _bleService.init();
  }

  Future<void> start_game() async {}
}
