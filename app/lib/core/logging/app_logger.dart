import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Logger global para la app. Expone una instancia compartida y un
/// `PrettyPrinter` apto para desarrollo. En release se baja el nivel
/// y se omite la info muy verbosa.
final Logger appLogger = Logger(
  level: kReleaseMode ? Level.warning : Level.debug,
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
