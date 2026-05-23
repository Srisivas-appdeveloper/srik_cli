import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:srik_cli/generators/feature_generator.dart';
import 'package:srik_cli/models/project_context.dart';
import 'package:srik_cli/prompts/validators.dart';
import 'package:srik_cli/utils/logger.dart';

class AddCommand extends Command<int> {
  @override
  final name = 'add';

  @override
  final description = 'Add a feature module or screen to an existing project.';

  AddCommand() {
    addSubcommand(AddFeatureCommand());
    addSubcommand(AddScreenCommand());
  }
}

class AddFeatureCommand extends Command<int> {
  @override
  final name = 'feature';

  @override
  final description =
      'Add a new feature module (data + domain + presentation layers).';

  @override
  String get invocation => 'srik add feature <feature_name>';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      Logger.error('Feature name is required.');
      Logger.plain('');
      Logger.plain('Usage: $invocation');
      Logger.plain('Example: srik add feature profile');
      return 64;
    }

    final featureName = rest.first;
    final featureError = Validators.featureName(featureName);
    if (featureError != null) {
      Logger.error(featureError);
      return 64;
    }

    final ctx = ProjectContext.load(Directory.current.path);
    if (ctx == null) {
      Logger.error(
        'No srik.yaml found. Run this command inside a project '
        'created with `srik create`.',
      );
      return 1;
    }

    try {
      FeatureGenerator().generateFeature(ctx, featureName);
      return 0;
    } on StateError catch (e) {
      Logger.error(e.message);
      return 1;
    } catch (e) {
      Logger.error('Failed to generate feature: $e');
      return 1;
    }
  }
}

class AddScreenCommand extends Command<int> {
  @override
  final name = 'screen';

  @override
  final description = 'Add a screen to an existing feature.';

  @override
  String get invocation =>
      'srik add screen <screen_name> --feature <feature_name>';

  AddScreenCommand() {
    argParser.addOption(
      'feature',
      abbr: 'f',
      help: 'Existing feature to add the screen into.',
      defaultsTo: 'home',
    );
  }

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      Logger.error('Screen name is required.');
      Logger.plain('');
      Logger.plain('Usage: $invocation');
      Logger.plain('Example: srik add screen settings --feature home');
      return 64;
    }

    final screenName = rest.first;
    final feature = argResults!['feature'] as String;

    final screenError = Validators.featureName(screenName);
    if (screenError != null) {
      Logger.error(screenError);
      return 64;
    }

    final ctx = ProjectContext.load(Directory.current.path);
    if (ctx == null) {
      Logger.error(
        'No srik.yaml found. Run this command inside a project '
        'created with `srik create`.',
      );
      return 1;
    }

    try {
      FeatureGenerator().generateScreen(ctx, screenName, feature: feature);
      return 0;
    } on StateError catch (e) {
      Logger.error(e.message);
      return 1;
    } catch (e) {
      Logger.error('Failed to generate screen: $e');
      return 1;
    }
  }
}
