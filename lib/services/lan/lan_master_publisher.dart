import 'package:AlpenQuiz/models/master_payload.dart';
import 'package:AlpenQuiz/services/lan/lan_publisher.dart';
import 'package:AlpenQuiz/services/lan/lan_service.dart';
import 'package:AlpenQuiz/services/logger.dart';

class LanMasterPublisher extends LanPublisher<MasterPayload> {
  final LanService _lanService;

  LanMasterPublisher({required LanService lanService})
      : _lanService = lanService,
        super(typeName: 'LanMasterPublisher');

  @override
  void publish(MasterPayload data) {
    final bytes = data.toBytes();
    log.i('LanMasterPublisher: publish ${bytes.length}bytes gameID=${data.gameID}');
    _lanService.broadcast(bytes);
  }
}
