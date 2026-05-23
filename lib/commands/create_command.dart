import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:srik_cli/generators/project_generator.dart';
import 'package:srik_cli/prompts/project_prompts.dart';
import 'package:srik_cli/prompts/validators.dart';
import 'package:srik_cli/utils/logger.dart';

class CreateCommand extends Command<int> {
  @override
  final name = 'create';

  @override
  final description = 'Create a new Flutter project.';

  @override
  String get invocation => 'srik create <project_name> [options]';

  CreateCommand() {
    argParser
      ..addOption('description', help: 'Project description.')
      ..addOption(
        'org',
        help: 'Organization (reverse domain, e.g. com.example).',
        defaultsTo: 'com.example',
      )
      ..addOption(
        'arch',
        help: 'Architecture.',
        allowed: ['clean', 'mvvm', 'feature-first', 'simple'],
      )
      ..addOption(
        'design',
        help: 'Design preset.',
        allowed: ['material', 'vibrant', 'minimal'],
      )
      ..addFlag(
        'gradient',
        help: 'Generate gradient theme support.',
        defaultsTo: null,
      )
      ..addOption(
        'spacing',
        help: 'Spacing scale density.',
        allowed: ['compact', 'normal', 'spacious'],
      )
      ..addOption(
        'brand',
        help: 'Brand color hex (e.g. #6200EE).',
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
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        defaultsTo: false,
        help: 'Print extra diagnostics during generation.',
      );
  }

  @override
  Future<int> run() async {
    final results = argResults!;
    final rest = results.rest;

    if (results['verbose'] as bool) {
      Logger.verbose = true;
    }

    if (rest.isEmpty) {
      Logger.error('Project name is required.');
      Logger.plain('');
      Logger.plain('Usage: $invocation');
      Logger.plain('');
      Logger.plain('Examples:');
      Logger.plain('  srik create my_app');
      Logger.plain('  srik create my_app --arch=mvvm --design=vibrant');
      Logger.plain('  srik create my_app --arch=clean --gradient '
          '--spacing=spacious --brand=#FF5733');
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

    final output = results['output'] as String;
    final outputError = _validateOutputDir(output);
    if (outputError != null) {
      Logger.error(outputError);
      return 64;
    }

    final interactive = results['interactive'] as bool && stdin.hasTerminal;

    Logger.header('Creating Flutter project: $projectName');
    Logger.plain('');

    final config = ProjectPrompts.collect(
      projectName: projectName,
      providedDescription: results['description'] as String?,
      providedOrg: org,
      providedBrand: brand,
      providedArch: results['arch'] as String?,
      providedDesign: results['design'] as String?,
      providedGradient: results['gradient'] as bool?,
      providedSpacing: results['spacing'] as String?,
      outputDirectory: output,
      interactive: interactive,
    );

    Logger.plain('');
    Logger.dim('Architecture:  ${config.architecture.label}');
    Logger.dim('Design preset: ${config.designPreset.id}');
    Logger.dim('Gradient:      ${config.useGradient ? 'yes' : 'no'}');
    Logger.dim('Spacing:       ${config.spacingScale.id}');
    Logger.dim('Brand color:   ${config.brandColor}');
    Logger.dim('Output:        ${p.absolute(config.outputDirectory)}');
    Logger.plain('');

    try {
      await ProjectGenerator().generate(config);
    } on StateError catch (e) {
      Logger.error(e.message);
      return 1;
    } on FormatException catch (e) {
      Logger.error(e.message);
      return 64;
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

  /// Returns null if the directory is acceptable, or an error message.
  String? _validateOutputDir(String dir) {
    final resolved = Directory(dir);
    if (!resolved.existsSync()) {
      return 'Output directory does not exist: ${p.absolute(dir)}\n'
          '  Create it first, or pass --output=<existing-dir>.';
    }
    // Best-effort writable check: try to create+delete a temp file.
    try {
      final probe = File(p.join(dir, '.srik_write_probe'));
      probe.writeAsStringSync('');
      probe.deleteSync();
    } catch (_) {
      return 'Output directory is not writable: ${p.absolute(dir)}';
    }
    return null;
  }
}
