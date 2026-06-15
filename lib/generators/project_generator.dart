import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:srik_cli/generators/gradle_editor.dart';
import 'package:srik_cli/models/enums.dart';
import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/templates/architectures/clean_templates.dart';
import 'package:srik_cli/templates/architectures/feature_first_templates.dart';
import 'package:srik_cli/templates/architectures/mvvm_templates.dart';
import 'package:srik_cli/templates/architectures/simple_templates.dart';
import 'package:srik_cli/templates/shared/common_templates.dart';
import 'package:srik_cli/templates/shared/design_templates.dart';
import 'package:srik_cli/utils/logger.dart';
import 'package:srik_cli/utils/shell_runner.dart';
import 'package:srik_cli/utils/spinner.dart';

/// Generates a Flutter project for any supported architecture.
class ProjectGenerator {
  Future<void> generate(ProjectConfig config) async {
    final projectDir = Directory(config.projectPath);
    if (projectDir.existsSync()) {
      throw StateError('Directory already exists: ${config.projectPath}');
    }

    Logger.info('Creating project structure...');
    projectDir.createSync(recursive: true);

    await _runFlutterCreate(config);

    Logger.info('Generating ${config.architecture.label} files...');
    _writeArchitectureFiles(config);

    Logger.info('Applying ${config.designPreset.id} design system...');
    _writeDesignFiles(config);

    Logger.info('Writing config files...');
    _writeCommonFiles(config);

    if (config.hasFlavors) {
      Logger.info('Configuring Android build flavors...');
      GradleEditor.apply(config);
      GradleEditor.applyManifest(config);
    }

    // `flutter pub get` and `git init` are independent of each other, so run
    // them concurrently. The git commit (which needs `git init` to have run
    // and all files to be written) happens afterward.
    final hasGit = await ShellRunner.hasExecutable('git');
    final spinner = Spinner('Installing dependencies & initializing git...');
    spinner.start();
    await Future.wait([
      _runPubGet(config),
      if (hasGit) _gitInit(config),
    ]);
    spinner.stop();
    Logger.info('Dependencies installed');

    if (hasGit) {
      await _gitCommit(config);
      Logger.info('Initialized git repository');
    }

    Logger.success('Done!');
  }

  /// Returns the design folder (relative to lib/) for the chosen architecture.
  String _designDir(AppArchitecture arch) {
    switch (arch) {
      case AppArchitecture.clean:
        return CleanTemplates.designDir;
      case AppArchitecture.mvvm:
        return MvvmTemplates.designDir;
      case AppArchitecture.featureFirst:
        return FeatureFirstTemplates.designDir;
      case AppArchitecture.simple:
        return SimpleTemplates.designDir;
    }
  }

  Map<String, String> _architectureFiles(ProjectConfig config) {
    switch (config.architecture) {
      case AppArchitecture.clean:
        return CleanTemplates.files(config);
      case AppArchitecture.mvvm:
        return MvvmTemplates.files(config);
      case AppArchitecture.featureFirst:
        return FeatureFirstTemplates.files(config);
      case AppArchitecture.simple:
        return SimpleTemplates.files(config);
    }
  }

  void _writeArchitectureFiles(ProjectConfig config) {
    final files = _architectureFiles(config);
    files.forEach((relativePath, contents) {
      _write(p.join(config.projectPath, relativePath), contents);
    });
  }

  void _writeDesignFiles(ProjectConfig config) {
    final designDir = _designDir(config.architecture);
    final files = DesignTemplates.allFiles(config);
    files.forEach((fileName, contents) {
      _write(
        p.join(config.projectPath, 'lib', designDir, fileName),
        contents,
      );
    });
  }

  void _writeCommonFiles(ProjectConfig config) {
    final root = config.projectPath;
    _write(p.join(root, 'pubspec.yaml'), CommonTemplates.pubspec(config));
    _write(p.join(root, 'analysis_options.yaml'),
        CommonTemplates.analysisOptions(config));
    _write(p.join(root, 'srik.yaml'), CommonTemplates.srikYaml(config));
    _write(p.join(root, 'README.md'), CommonTemplates.readme(config));

    final gitignorePath = p.join(root, '.gitignore');
    if (!File(gitignorePath).existsSync()) {
      _write(gitignorePath, CommonTemplates.gitignore(config));
    }
  }

  Future<void> _runFlutterCreate(ProjectConfig config) async {
    final hasFlutter = await ShellRunner.hasExecutable('flutter');
    if (!hasFlutter) {
      Logger.warn(
        'Flutter not found on PATH. Skipping platform folder creation. '
        'Run `flutter create .` inside the project later.',
      );
      return;
    }

    const tempName = '_srik_temp';
    final tempPath = p.join(config.outputDirectory, tempName);

    // `--empty` (Flutter 3.6+) skips the default counter-app boilerplate that
    // srik throws away anyway. Use it when available.
    final supportsEmpty = await _supportsEmptyFlag();
    Logger.debug('flutter create --empty supported: $supportsEmpty');

    final spinner = Spinner('Running flutter create...');
    spinner.start();
    final ok = await ShellRunner.run(
      'flutter',
      [
        'create',
        '--no-pub',
        if (supportsEmpty) '--empty',
        '--org=${config.organization}',
        '--project-name=${config.projectName}',
        '--platforms=android,ios',
        tempName,
      ],
      workingDirectory: config.outputDirectory,
      silent: true,
    );
    spinner.stop();
    if (ok) Logger.info('flutter create completed');

    if (!ok) {
      Logger.warn('flutter create failed. Continuing with Dart-only files.');
      return;
    }

    final tempDir = Directory(tempPath);
    for (final entity in tempDir.listSync()) {
      final basename = p.basename(entity.path);
      // Skip lib/ and test/ — srik generates its own.
      if (basename == 'lib' || basename == 'test') {
        if (entity is Directory) entity.deleteSync(recursive: true);
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

  bool? _emptyFlagSupported;

  /// Whether the installed Flutter supports `flutter create --empty`
  /// (added in Flutter 3.6). Detected once by inspecting `create --help`.
  Future<bool> _supportsEmptyFlag() async {
    if (_emptyFlagSupported != null) return _emptyFlagSupported!;
    try {
      final result = await Process.run('flutter', ['create', '--help']);
      final out = '${result.stdout}${result.stderr}';
      _emptyFlagSupported = out.contains('--empty');
    } catch (_) {
      _emptyFlagSupported = false;
    }
    return _emptyFlagSupported!;
  }

  void _copyDirectory(Directory source, Directory destination) {
    destination.createSync(recursive: true);
    for (final entity in source.listSync()) {
      final newPath = p.join(destination.path, p.basename(entity.path));
      if (entity is Directory) {
        _copyDirectory(entity, Directory(newPath));
      } else if (entity is File) {
        entity.copySync(newPath);
      }
    }
  }

  void _write(String path, String contents) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(contents);
  }

  Future<void> _runPubGet(ProjectConfig config) async {
    final hasFlutter = await ShellRunner.hasExecutable('flutter');
    if (!hasFlutter) return;
    await ShellRunner.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: config.projectPath,
      silent: true,
    );
  }

  Future<void> _gitInit(ProjectConfig config) async {
    await ShellRunner.run('git', ['init'],
        workingDirectory: config.projectPath, silent: true);
  }

  Future<void> _gitCommit(ProjectConfig config) async {
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
