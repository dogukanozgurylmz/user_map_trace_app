import 'package:flutter/foundation.dart';
import 'dart:developer' as x;

enum LogLevel { info, warning, error }

final class AppLogger {
  static final AppLogger instance = AppLogger._();
  AppLogger._();

  /// Prints message according to log level
  void log(String message, {LogLevel level = LogLevel.info}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = "[$timestamp] [${level.name.toUpperCase()}] $message";

    if (kDebugMode) {
      // Print directly to screen in debug mode
      x.log(logMessage);
    } else {
      // Save to log file in Production mode
      x.log(logMessage);
    }
  }

  /// Manages error logs privately
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.error);
    if (error != null) {
      log("Error Details: $error", level: LogLevel.error);
    }
    if (stackTrace != null) {
      log("StackTrace: $stackTrace", level: LogLevel.error);
    }
  }
}
