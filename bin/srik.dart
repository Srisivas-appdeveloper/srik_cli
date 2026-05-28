import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:srik_cli/commands/add_command.dart';
import 'package:srik_cli/commands/create_command.dart';
import 'package:srik_cli/commands/doctor_command.dart';
import 'package:srik_cli/utils/logger.dart';

const String version = '0.2.1';

Future<void> main(List<String> arguments) async {
  final runner = CommandRunner<int>(
    'srik',
    'Flutter project scaffolder with Clean Architecture + Riverpod.\n\n'
        'Run `srik create <project_name>` to generate a new app.',
  )
    ..argParser.addFlag(
      'version',
      negatable: false,
      abbr: 'v',
      help: 'Print the current version.',
    )
    ..addCommand(CreateCommand())
    ..addCommand(AddCommand())
    ..addCommand(DoctorCommand());

  try {
    if (arguments.contains('--version') || arguments.contains('-v')) {
      stdout.writeln('srik_cli v$version');
      exit(0);
    }
    final exitCode = await runner.run(arguments) ?? 0;
    exit(exitCode);
  } on UsageException catch (e) {
    Logger.error(e.message);
    stdout.writeln(e.usage);
    exit(64);
  } catch (e, st) {
    Logger.error('Unexpected error: $e');
    if (Platform.environment['SRIK_DEBUG'] == 'true') {
      stdout.writeln(st);
    }
    exit(1);
  }
}
