import 'dart:async';
import 'dart:typed_data';

import 'package:AlpenQuiz/models/client_payload.dart';
import 'package:AlpenQuiz/services/lan/lan_listener.dart';
import 'package:AlpenQuiz/services/lan/lan_service.dart';
import 'package:AlpenQuiz/services/logger.dart';

class LanClientListener extends LanListener<ClientPayload> {
  final int _gameId;
  StreamSubscription? _sub;

  final Map<String, ClientPayload> _latestPayloads = {};

  LanClientListener({
    required LanService lanService,
    required int gameId,
  })  : _gameId = gameId,
        super(typeName: 'LanClientListener') {
    _sub = lanService.onClientData.listen((record) {
      final (senderId, data) = record;
      final payload = parse(data);
      if (payload == null) return;

      final existing = _latestPayloads[senderId];
      if (existing != null &&
          existing.toBytes().length >= payload.toBytes().length) {
        log.d(
          'LanClientListener: dropped duplicate senderId=$senderId',
        );
        return;
      }

      _latestPayloads[senderId] = payload;
      emit(payload);
    });
  }

  @override
  ClientPayload? parse(Uint8List data) {
    try {
      final payload = ClientPayload.fromBytes(data);
      if (payload.gameID != _gameId) {
        log.d(
          'LanClientListener: gameID mismatch expected=$_gameId got=${payload.gameID}',
        );
        return null;
      }
      log.d(
        'LanClientListener: received gameID=${payload.gameID} clientId=${payload.clientId} name=${payload.name} answers=${payload.answers.length}',
      );
      return payload;
    } catch (e) {
      log.w('LanClientListener: parse failed — $e');
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
