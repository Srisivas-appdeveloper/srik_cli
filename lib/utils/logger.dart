import 'dart:io';

/// Lightweight colored logger. No external deps.
class Logger {
  static const _reset = '\x1B[0m';
  static const _bold = '\x1B[1m';
  static const _green = '\x1B[32m';
  static const _red = '\x1B[31m';
  static const _yellow = '\x1B[33m';
  static const _cyan = '\x1B[36m';
  static const _gray = '\x1B[90m';

  static bool _supportsAnsi() {
    if (Platform.isWindows) {
      return stdout.supportsAnsiEscapes;
    }
    return true;
  }

  static String _wrap(String text, String color) {
    if (!_supportsAnsi()) return text;
    return '$color$text$_reset';
  }

  static void info(String message) {
    stdout.writeln(_wrap('• $message', _cyan));
  }

  static void success(String message) {
    stdout.writeln(_wrap('✓ $message', _green));
  }

  static void warn(String message) {
    stdout.writeln(_wrap('⚠ $message', _yellow));
  }

  static void error(String message) {
    stderr.writeln(_wrap('✗ $message', _red));
  }

  static void header(String message) {
    stdout.writeln(_wrap('\n$message', _bold));
  }

  static void dim(String message) {
    stdout.writeln(_wrap(message, _gray));
  }

  static void plain(String message) {
    stdout.writeln(message);
  }
}
