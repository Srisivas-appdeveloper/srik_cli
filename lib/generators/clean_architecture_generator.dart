import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/templates/clean_riverpod/app_template.dart';
import 'package:srik_cli/templates/clean_riverpod/config_templates.dart';
import 'package:srik_cli/templates/clean_riverpod/constants_templates.dart';
import 'package:srik_cli/templates/clean_riverpod/core_templates.dart';
import 'package:srik_cli/templates/clean_riverpod/home_feature_templates.dart';
import 'package:srik_cli/templates/clean_riverpod/main_template.dart';
import 'package:srik_cli/templates/clean_riverpod/pubspec_template.dart';
import 'package:srik_cli/utils/logger.dart';
import 'package:srik_cli/utils/shell_runner.dart';

/// Generates a Clean Architecture + Riverpod Flutter project.
class CleanRiverpodGenerator {
  Future<void> generate(ProjectConfig config) async {
    final projectDir = Directory(config.projectPath);

    if (projectDir.existsSync()) {
      throw StateError(
        'Directory already exists: ${config.projectPath}',
      );
    }

    Logger.info('Creating project structure...');
    projectDir.createSync(recursive: true);

    await _runFlutterCreate(config);

    Logger.info('Generating Clean Architecture folders...');
    _writeAllTemplates(config);

    Logger.info('Installing dependencies...');
    await _runPubGet(config);

    Logger.info('Initializing git repository...');
    await _initGit(config);

    Logger.success('Done!');
  }

  Future<void> _runFlutterCreate(ProjectConfig config) async {
    final tempName = '_srik_temp';
    final tempPath = p.join(config.outputDirectory, tempName);

    final hasFlutter = await ShellRunner.hasExecutable('flutter');
    if (!hasFlutter) {
      Logger.warn(
        'Flutter not found on PATH. Skipping `flutter create` step. '
        'You will need to add the platform folders manually.',
      );
      return;
    }

    Logger.info('Running flutter create (this may take a moment)...');
    final ok = await ShellRunner.run(
      'flutter',
      [
        'create',
        '--no-pub',
        '--org=${config.organization}',
        '--project-name=${config.projectName}',
        '--platforms=android,ios',
        tempName,
      ],
      workingDirectory: config.outputDirectory,
      silent: true,
    );

    if (!ok) {
      Logger.warn(
        'flutter create failed. Continuing with Dart-only structure. '
        'Run `flutter create .` manually inside the project later.',
      );
      return;
    }

    // Move flutter-created files into our project dir
    final tempDir = Directory(tempPath);
    for (final entity in tempDir.listSync()) {
      final basename = p.basename(entity.path);
      // Skip lib/ — we generate our own
      if (basename == 'lib' || basename == 'test') {
        if (entity is Directory) {
          entity.deleteSync(recursive: true);
        }
        continue;
      }
      final dest = p.join(config.projectPath, basename);
      if (entity is Directory) {
        _copyDirectory(entity, Directory(dest));
      } else if (entity is File) {
        entity.copySync(dest);
      }
    }
    tempDir.deleteSync(recursive: true);
  }

  void _copyDirectory(Directory source, Directory destination) {
    destination.createSync(recursive: true);
    for (final entity in source.listSync(recursive: false)) {
      final newPath = p.join(destination.path, p.basename(entity.path));
      if (entity is Directory) {
        _copyDirectory(entity, Directory(newPath));
      } else if (entity is File) {
        entity.copySync(newPath);
      }
    }
  }

  void _writeAllTemplates(ProjectConfig config) {
    final root = config.projectPath;

    // Top-level config files
    _writeFile(p.join(root, 'pubspec.yaml'), pubspecTemplate(config));
    _writeFile(
        p.join(root, 'analysis_options.yaml'), analysisOptionsTemplate(config));
    _writeFile(p.join(root, 'srik.yaml'), srikYamlTemplate(config));
    _writeFile(p.join(root, 'README.md'), readmeTemplate(config));
    // Only write .gitignore if flutter create didn't already create one
    final gitignorePath = p.join(root, '.gitignore');
    if (!File(gitignorePath).existsSync()) {
      _writeFile(gitignorePath, gitignoreTemplate(config));
    }

    // lib/main.dart, lib/app.dart
    _writeFile(p.join(root, 'lib', 'main.dart'), mainDartTemplate(config));
    _writeFile(p.join(root, 'lib', 'app.dart'), appDartTemplate(config));

    // lib/core/constants/
    final constants = p.join(root, 'lib', 'core', 'constants');
    _writeFile(p.join(constants, 'app_colors.dart'), appColorsTemplate(config));
    _writeFile(
        p.join(constants, 'app_spacing.dart'), appSpacingTemplate(config));
    _writeFile(p.join(constants, 'app_radius.dart'), appRadiusTemplate(config));
    _writeFile(
        p.join(constants, 'app_text_styles.dart'),
        appTextStylesTemplate(config));
    _writeFile(p.join(constants, 'app_durations.dart'),
        appDurationsTemplate(config));
    _writeFile(p.join(constants, 'app_theme.dart'), appThemeTemplate(config));

    // lib/core/error/
    final error = p.join(root, 'lib', 'core', 'error');
    _writeFile(p.join(error, 'exceptions.dart'), exceptionsTemplate(config));
    _writeFile(p.join(error, 'failures.dart'), failuresTemplate(config));

    // lib/core/network/
    final network = p.join(root, 'lib', 'core', 'network');
    _writeFile(p.join(network, 'dio_client.dart'), dioClientTemplate(config));

    // lib/core/storage/
    final storage = p.join(root, 'lib', 'core', 'storage');
    _writeFile(
        p.join(storage, 'local_storage.dart'), localStorageTemplate(config));

    // lib/core/router/
    final router = p.join(root, 'lib', 'core', 'router');
    _writeFile(p.join(router, 'app_router.dart'), appRouterTemplate(config));

    // lib/features/home/
    final home = p.join(root, 'lib', 'features', 'home');
    _writeFile(p.join(home, 'domain', 'entities', 'home_entity.dart'),
        homeEntityTemplate(config));
    _writeFile(p.join(home, 'domain', 'repositories', 'home_repository.dart'),
        homeRepositoryTemplate(config));
    _writeFile(
        p.join(home, 'data', 'repositories', 'home_repository_impl.dart'),
        homeRepositoryImplTemplate(config));
    _writeFile(p.join(home, 'presentation', 'providers', 'home_provider.dart'),
        homeProviderTemplate(config));
    _writeFile(p.join(home, 'presentation', 'screens', 'home_screen.dart'),
        homeScreenTemplate(config));
  }

  void _writeFile(String path, String contents) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(contents);
  }

  Future<void> _runPubGet(ProjectConfig config) async {
    final hasFlutter = await ShellRunner.hasExecutable('flutter');
    if (!hasFlutter) {
      Logger.warn('flutter not on PATH. Skipping `flutter pub get`.');
      return;
    }
    await ShellRunner.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: config.projectPath,
      silent: true,
    );
  }

  Future<void> _initGit(ProjectConfig config) async {
    final hasGit = await ShellRunner.hasExecutable('git');
    if (!hasGit) {
      Logger.warn('git not on PATH. Skipping git init.');
      return;
    }
    await ShellRunner.run('git', ['init'],
        workingDirectory: config.projectPath, silent: true);
    await ShellRunner.run('git', ['add', '.'],
        workingDirectory: config.projectPath, silent: true);
    await ShellRunner.run(
      'git',
      ['commit', '-m', 'Initial commit from srik_cli'],
      workingDirectory: config.projectPath,
      silent: true,
    );
  }
}
