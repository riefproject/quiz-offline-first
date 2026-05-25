import 'dart:async';
import 'dart:typed_data';

import 'package:AlpenQuiz/models/master_payload.dart';
import 'package:AlpenQuiz/services/lan/lan_listener.dart';
import 'package:AlpenQuiz/services/lan/lan_service.dart';
import 'package:AlpenQuiz/services/logger.dart';

class LanMasterListListener extends LanListener<MasterPayload> {
  final LanService _lanService;
  StreamSubscription? _sub;

  final _connectionInfo = <int, ({String hostIp, int wsPort})>{};

  LanMasterListListener({required LanService lanService})
      : _lanService = lanService,
        super(typeName: 'LanMasterListListener') {
    _sub = _lanService.onGameDiscovered.listen((game) {
      _connectionInfo[game.gameId] = (
        hostIp: game.hostIp,
        wsPort: game.wsPort,
      );

      final payload = MasterPayload(
        questionCount: game.questionCount,
        masterTimeMs: 0,
        nextQuestion: [],
        gameID: game.gameId,
      );

      log.i(
        'LanMasterListListener: discovered gameID=${game.gameId} host=${game.hostIp}:${game.wsPort} questionCount=${game.questionCount}',
      );
      emit(payload);
    });
  }

  ({String hostIp, int wsPort})? connectionInfoFor(int gameId) {
    return _connectionInfo[gameId];
  }

  @override
  MasterPayload? parse(Uint8List data) => null;

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }
}
