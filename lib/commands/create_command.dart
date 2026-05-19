import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:srik_cli/generators/clean_architecture_generator.dart';
import 'package:srik_cli/prompts/project_prompts.dart';
import 'package:srik_cli/prompts/validators.dart';
import 'package:srik_cli/utils/logger.dart';

class CreateCommand extends Command<int> {
  @override
  final name = 'create';

  @override
  final description =
      'Create a new Flutter project (Clean Architecture + Riverpod).';

  @override
  String get invocation => 'srik create <project_name> [options]';

  CreateCommand() {
    argParser
      ..addOption(
        'description',
        help: 'Project description.',
      )
      ..addOption(
        'org',
        help: 'Organization (reverse domain, e.g., com.example).',
        defaultsTo: 'com.example',
      )
      ..addOption(
        'brand',
        help: 'Brand color hex (e.g., #6200EE).',
        defaultsTo: '#6200EE',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Parent directory for the new project.',
        defaultsTo: '.',
      )
      ..addFlag(
        'interactive',
        defaultsTo: true,
        help: 'Prompt for missing values. Disable with --no-interactive.',
      );
  }

  @override
  Future<int> run() async {
    final results = argResults!;
    final rest = results.rest;

    if (rest.isEmpty) {
      Logger.error('Project name is required.');
      Logger.plain('');
      Logger.plain('Usage: $invocation');
      Logger.plain('');
      Logger.plain('Example:');
      Logger.plain('  srik create my_app');
      Logger.plain('  srik create my_app --org=com.acme --brand=#FF5733');
      return 64;
    }

    final projectName = rest.first;
    final nameError = Validators.projectName(projectName);
    if (nameError != null) {
      Logger.error(nameError);
      return 64;
    }

    final brand = results['brand'] as String;
    final brandError = Validators.hexColor(brand);
    if (brandError != null) {
      Logger.error('Invalid --brand value: $brandError');
      return 64;
    }

    final org = results['org'] as String;
    final orgError = Validators.organization(org);
    if (orgError != null) {
      Logger.error('Invalid --org value: $orgError');
      return 64;
    }

    final interactive = results['interactive'] as bool && stdin.hasTerminal;

    Logger.header('Creating Flutter project: $projectName');
    Logger.dim('Architecture: Clean Architecture');
    Logger.dim('State management: Riverpod');
    Logger.dim('Routing: go_router');
    Logger.dim('Networking: Dio');
    Logger.dim('Storage: shared_preferences');
    Logger.plain('');

    final config = ProjectPrompts.collect(
      providedName: projectName,
      providedDescription: results['description'] as String?,
      providedOrg: org,
      providedBrand: brand,
      outputDirectory: results['output'] as String,
      interactive: interactive,
    );

    try {
      await CleanRiverpodGenerator().generate(config);
    } on StateError catch (e) {
      Logger.error(e.message);
      return 1;
    } catch (e) {
      Logger.error('Generation failed: $e');
      return 1;
    }

    Logger.plain('');
    Logger.success('Project ready: ${config.projectPath}');
    Logger.plain('');
    Logger.plain('Next steps:');
    Logger.plain('  cd ${config.projectName}');
    Logger.plain('  flutter run');
    Logger.plain('');
    return 0;
  }
}
