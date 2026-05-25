import 'dart:async';
import 'dart:typed_data';

import 'package:AlpenQuiz/models/master_payload.dart';
import 'package:AlpenQuiz/services/lan/lan_listener.dart';
import 'package:AlpenQuiz/services/lan/lan_service.dart';
import 'package:AlpenQuiz/services/logger.dart';

class LanMasterListener extends LanListener<MasterPayload> {
  final int _gameId;
  StreamSubscription? _sub;

  LanMasterListener({
    required LanService lanService,
    required int gameId,
  })  : _gameId = gameId,
        super(typeName: 'LanMasterListener') {
    _sub = lanService.onHostData.listen((data) {
      final payload = parse(data);
      if (payload != null) {
        emit(payload);
      }
    });
  }

  @override
  MasterPayload? parse(Uint8List data) {
    try {
      final payload = MasterPayload.fromBytes(data);
      if (payload.gameID != _gameId) {
        log.d(
          'LanMasterListener: gameID mismatch expected=$_gameId got=${payload.gameID}',
        );
        return null;
      }
      log.d(
        'LanMasterListener: received gameID=${payload.gameID} nextQuestion=${payload.nextQuestion.length} gameFinished=${payload.gameFinished}',
      );
      return payload;
    } catch (e) {
      log.w('LanMasterListener: parse failed — $e');
      return null;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }
}
