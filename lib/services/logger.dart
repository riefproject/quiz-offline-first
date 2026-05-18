import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

late Logger log;

Future<void> initLogger() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/kahoof_debug.log');

  log = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    output: MultiOutput([
      ConsoleOutput(),
      FileOutput(file: file),
    ]),
    level: Level.trace,
  );
}
