import 'dart:developer' as developer;

import 'package:intl/intl.dart';

class LoggerUtil {
  static void log(String message, {String? tag, StackTrace? stackTrace}) {
    // if (AppConfig.instance.values.enableLog) {
    String time = '(${DateFormat('HH:mm:ss').format(DateTime.now())})';
    developer.log('$time - $message',
        name: tag ?? 'log', stackTrace: stackTrace);
    // }
  }

  // Blue text
  static void info(String msg, {String? tag, StackTrace? stackTrace}) {
    log(msg, tag: tag, stackTrace: stackTrace);
    // log('\x1B[34m$msg\x1B[0m', tag: tag, stackTrace: stackTrace);
  }

  // Green text
  static void logSuccess(String msg, {String? tag, StackTrace? stackTrace}) {
    log(msg, tag: tag, stackTrace: stackTrace);
    // log('\x1B[32m$msg\x1B[0m', tag: tag, stackTrace: stackTrace);
  }

  // Yellow text
  static void warning(String msg, {String? tag, StackTrace? stackTrace}) {
    log(msg, tag: tag, stackTrace: stackTrace);
    // log('\x1B[33m$msg\x1B[0m', tag: tag, stackTrace: stackTrace);
  }

  // Red text
  static void error(String msg, {String? tag, StackTrace? stackTrace}) {
    log(msg, tag: tag, stackTrace: stackTrace);
    // log('\x1B[31m$msg\x1B[0m', tag: tag, stackTrace: stackTrace);
  }
}
