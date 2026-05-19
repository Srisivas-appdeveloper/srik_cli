/// srik_cli — Flutter project scaffolder.
///
/// Programmatic API is not the primary use case; install globally and use
/// from the command line:
///
/// ```bash
/// dart pub global activate srik_cli
/// srik create my_app
/// ```
library srik_cli;

export 'commands/create_command.dart';
export 'commands/doctor_command.dart';
export 'generators/clean_architecture_generator.dart';
export 'models/project_config.dart';
