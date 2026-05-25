import 'package:AlpenQuiz/models/client_payload.dart';
import 'package:AlpenQuiz/services/lan/lan_publisher.dart';
import 'package:AlpenQuiz/services/lan/lan_service.dart';
import 'package:AlpenQuiz/services/logger.dart';

class LanClientPublisher extends LanPublisher<ClientPayload> {
  final LanService _lanService;

  LanClientPublisher({required LanService lanService})
      : _lanService = lanService,
        super(typeName: 'LanClientPublisher');

  @override
  void publish(ClientPayload data) {
    final bytes = data.toBytes();
    log.i('LanClientPublisher: publish ${bytes.length}bytes clientId=${data.clientId} gameID=${data.gameID}');
    _lanService.sendToHost(bytes);
  }
}
