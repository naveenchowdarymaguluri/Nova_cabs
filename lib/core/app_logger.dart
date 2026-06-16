// lib/core/app_logger.dart
// Centralised logger for Nova Cabs.
// Usage: AppLogger.d('msg'), AppLogger.w('msg'), AppLogger.e('msg', error: e)
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void d(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  static void i(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  static void w(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  static void e(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
