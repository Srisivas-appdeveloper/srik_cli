import 'dart:io';

import 'package:srik_cli/utils/logger.dart';

/// Wraps Process.run with consistent error handling.
class ShellRunner {
  /// Runs a command and returns the result.
  /// On non-zero exit, logs the error and returns false.
  static Future<bool> run(
    String executable,
    List<String> arguments, {
    required String workingDirectory,
    bool silent = false,
  }) async {
    try {
      final result = await Process.run(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        runInShell: Platform.isWindows,
      );

      if (result.exitCode != 0) {
        if (!silent) {
          Logger.error('$executable ${arguments.join(' ')} failed');
          if (result.stderr.toString().isNotEmpty) {
            Logger.dim(result.stderr.toString().trim());
          }
        }
        return false;
      }
      return true;
    } catch (e) {
      if (!silent) {
        Logger.error('Failed to run $executable: $e');
      }
      return false;
    }
  }

  /// Checks if an executable exists on PATH.
  static Future<bool> hasExecutable(String executable) async {
    try {
      final cmd = Platform.isWindows ? 'where' : 'which';
      final result = await Process.run(cmd, [executable]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
