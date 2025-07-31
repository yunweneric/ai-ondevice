// ignore_for_file: avoid_annotating_with_dynamic

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:offline_ai/shared/shared.dart';
import 'ansi.dart';

const kLoggerFileName = 'latest.log';
const kLoggerFileSizeKB = 3072;

/// override default ConsoleOutput to log to console
///
class AppLoggerOutput extends LogOutput {
  @override
  void output(OutputEvent event) => event.lines.forEach(log);
}

class AppLoggerFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

class AppLogger {
  late final Logger _logger;
  static AppLogger? _instance;
  factory AppLogger() => _instance!;

  AppLogger._(AppEnv _, {String? path}) {
    if (kDebugMode || kProfileMode) {
      _logger = Logger(
        filter: AppLoggerFilter(),
        printer: PrettyPrinter(
          printEmojis: false,
          methodCount: 0,
          noBoxingByDefault: true,
          colors: false,
        ),
        output: MultiOutput([
          AppLoggerOutput(),
          if (path != null)
            AdvancedFileOutput(
              path: path,
              // ignore: avoid_redundant_argument_values
              latestFileName: kLoggerFileName,
              maxFileSizeKB: kLoggerFileSizeKB,
            ),
        ]),
      );
      return;
    }

    _logger = Logger(
      level: Level.off,
      filter: ProductionFilter(),
    );
  }

  static void init(AppEnv env, {String? path}) =>
      _instance = AppLogger._(env, path: path);

  static void dispose() => _instance?._logger.close();

  static void log(dynamic message) => _instance?._logger.d(message);

  static void i(dynamic message, {String? name}) {
    final trimmed = _trim(message);
    if (trimmed is String && trimmed.isEmpty) {
      return;
    }

    _instance?._logger.i(_m(trimmed, name));
  }

  static void e(dynamic message,
          {String? name, Object? error, StackTrace? stackTrace}) =>
      _instance?._logger.e(
        _e(message, name),
        error: error,
        stackTrace: stackTrace ?? StackTrace.current,
      );

  static dynamic _m(dynamic message, String? name) => // _
      name != null
          ? '$_time $kYellow[$name]$kReset $message'
          : '$_time $kYellow$message$kReset';

  static dynamic _e(dynamic message, String? name) => name != null
      ? '$_time $kRed[$name]$kReset $message'
      : '$_time $kRed$message$kReset';

  static String get _time =>
      '$kCyan${DateFormat('HH:mm:ss.SSS').format(DateTime.now())}$kReset';

  static dynamic _trim(dynamic message) {
    if (message is String) {
      return message.trim();
    }

    return message;
  }
}
