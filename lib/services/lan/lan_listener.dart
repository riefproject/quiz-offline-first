import 'dart:async';
import 'dart:typed_data';

import 'package:AlpenQuiz/services/logger.dart';

abstract class LanListener<T> {
  final _controller = StreamController<T>();
  final String _typeName;

  Stream<T> get stream => _controller.stream;

  LanListener({required String typeName}) : _typeName = typeName {
    log.i('LanListener($typeName): created');
  }

  T? parse(Uint8List data);

  void emit(T payload) {
    log.d('LanListener($_typeName): emitting payload');
    _controller.sink.add(payload);
  }

  void dispose() {
    log.i('LanListener($_typeName): disposed');
    _controller.close();
  }
}
