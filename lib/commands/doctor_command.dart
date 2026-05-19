import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:srik_cli/utils/logger.dart';
import 'package:srik_cli/utils/shell_runner.dart';

class DoctorCommand extends Command<int> {
  @override
  final name = 'doctor';

  @override
  final description = 'Check that your environment is ready to use srik.';

  @override
  Future<int> run() async {
    Logger.header('srik_cli doctor');
    Logger.plain('');

    var allOk = true;

    // Check Dart
    final dartOk = await _check('dart', ['--version']);
    allOk &= dartOk;

    // Check Flutter
    final flutterOk = await _check('flutter', ['--version']);
    allOk &= flutterOk;

    // Check git
    final gitOk = await _check('git', ['--version']);
    allOk &= gitOk;

    Logger.plain('');
    if (allOk) {
      Logger.success('All checks passed. You are ready to run `srik create`.');
      return 0;
    } else {
      Logger.warn('Some checks failed. Install missing tools and retry.');
      return 1;
    }
  }

  Future<bool> _check(String executable, List<String> args) async {
    final hasIt = await ShellRunner.hasExecutable(executable);
    if (!hasIt) {
      Logger.error('$executable: not found on PATH');
      return false;
    }
    try {
      final result = await Process.run(executable, args);
      final firstLine = result.stdout.toString().split('\n').first.trim();
      Logger.success('$executable: $firstLine');
      return true;
    } catch (e) {
      Logger.error('$executable: error ($e)');
      return false;
    }
  }
}
