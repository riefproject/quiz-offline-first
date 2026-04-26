import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:py_4/models/master_payload.dart';
import 'package:py_4/services/ble_service.dart';
import 'package:py_4/services/quiz/quiz_listener.dart';

class MasterListener extends QuizListener<MasterPayload> {
  int gameId;
  MasterListener({required super.bleService, required this.gameId});

  @override
  MasterPayload? parseResult(ScanResult result) {
    if (!BleService.hasManufacturerData(result)) return null;
    final data = BleService.getManufacturerData(result);
    if (data == null) return null;
    try {
      final payload = MasterPayload.fromBytes(data);
      if (payload.gameID != gameId) return null;
      return payload;
    } catch (e) {
      print(e); // TODO: log the error
      return null;
    }
  }
}
