import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:srik_cli/models/project_context.dart';
import 'package:srik_cli/templates/add/feature_first_templates.dart';
import 'package:srik_cli/templates/add/feature_module_templates.dart';
import 'package:srik_cli/templates/add/mvvm_feature_templates.dart';
import 'package:srik_cli/templates/add/screen_templates.dart';
import 'package:srik_cli/templates/add/simple_templates.dart';
import 'package:srik_cli/utils/logger.dart';
import 'package:srik_cli/utils/string_utils.dart';

/// Generates feature modules and screens inside existing srik projects.
///
/// Supports all four architectures:
///   - clean         → layered (domain/data/presentation) under features/<name>/
///   - mvvm          → model/service/viewmodel/view across top-level folders
///   - feature-first → flat files under features/<name>/
///   - simple        → screens/ + models/, no layering
class FeatureGenerator {
  /// Maps an architecture id to its design folder (relative to lib/).
  static String designDirFor(String architecture) {
    switch (architecture) {
      case 'clean':
        return 'core/constants';
      case 'mvvm':
        return 'core/constants';
      case 'feature-first':
        return 'shared/theme';
      case 'simple':
        return 'theme';
      default:
        throw ArgumentError(
          'Unknown architecture "$architecture". '
          'Expected one of: clean, mvvm, feature-first, simple.',
        );
    }
  }

  /// Generate a full feature for the project's architecture.
  void generateFeature(ProjectContext ctx, String featureName) {
    final snake = StringUtils.toSnakeCase(featureName);
    if (!StringUtils.isValidPackageName(snake)) {
      throw StateError(
        'Invalid feature name "$featureName". Use lowercase letters, '
        'numbers, and underscores (e.g., user_profile).',
      );
    }

    switch (ctx.architecture) {
      case 'clean':
        _generateCleanFeature(ctx, snake);
        break;
      case 'mvvm':
        _generateMvvmFeature(ctx, snake);
        break;
      case 'feature-first':
        _generateFeatureFirstFeature(ctx, snake);
        break;
      case 'simple':
        _generateSimpleFeature(ctx, snake);
        break;
      default:
        throw StateError(
          'Unknown architecture "${ctx.architecture}" in srik.yaml.',
        );
    }

    ctx.appendFeature(snake);
  }

  /// Generate a single screen for the project's architecture.
  void generateScreen(
    ProjectContext ctx,
    String screenName, {
    required String feature,
  }) {
    final snake = StringUtils.toSnakeCase(screenName);
    if (!StringUtils.isValidPackageName(snake)) {
      throw StateError(
        'Invalid screen name "$screenName". Use lowercase letters, '
        'numbers, and underscores (e.g., user_profile).',
      );
    }

    switch (ctx.architecture) {
      case 'clean':
        _generateCleanScreen(ctx, snake, feature: feature);
        break;
      case 'mvvm':
        _generateMvvmScreen(ctx, snake);
        break;
      case 'feature-first':
        _generateFeatureFirstScreen(ctx, snake, feature: feature);
        break;
      case 'simple':
        _generateSimpleScreen(ctx, snake);
        break;
      default:
        throw StateError(
          'Unknown architecture "${ctx.architecture}" in srik.yaml.',
        );
    }
  }

  // ---------------------------------------------------------------- Clean

  void _generateCleanFeature(ProjectContext ctx, String snake) {
    final featureRoot = p.join(ctx.projectRoot, 'lib', 'features', snake);
    _ensureNotExists(featureRoot, 'Feature', 'lib/features/$snake');

    final name = ctx.projectName;
    final designDir = designDirFor(ctx.architecture);

    Logger.info('Generating feature: $snake');

    _write(
      p.join(featureRoot, 'domain', 'entities', '${snake}_entity.dart'),
      FeatureModuleTemplates.entity(name, snake),
    );
    _write(
      p.join(featureRoot, 'domain', 'repositories',
          '${snake}_repository.dart'),
      FeatureModuleTemplates.repository(name, snake),
    );
    _write(
      p.join(featureRoot, 'data', 'repositories',
          '${snake}_repository_impl.dart'),
      FeatureModuleTemplates.repositoryImpl(name, snake),
    );
    _write(
      p.join(featureRoot, 'presentation', 'providers',
          '${snake}_provider.dart'),
      FeatureModuleTemplates.provider(name, snake),
    );
    _write(
      p.join(featureRoot, 'presentation', 'screens', '${snake}_screen.dart'),
      FeatureModuleTemplates.screen(name, snake, designDir),
    );

    Logger.success('Feature "$snake" created at lib/features/$snake/');
    Logger.dim('  Add a route in lib/core/router/app_router.dart to use it.');
  }

  void _generateCleanScreen(
    ProjectContext ctx,
    String snake, {
    required String feature,
  }) {
    final featureSnake = StringUtils.toSnakeCase(feature);
    final featureRoot =
        p.join(ctx.projectRoot, 'lib', 'features', featureSnake);
    if (!Directory(featureRoot).existsSync()) {
      throw StateError(
        'Feature "$featureSnake" does not exist. '
        'Run `srik add feature $featureSnake` first.',
      );
    }

    final screenPath = p.join(
        featureRoot, 'presentation', 'screens', '${snake}_screen.dart');
    _ensureFileNotExists(screenPath, 'Screen');

    final name = ctx.projectName;
    final designDir = designDirFor(ctx.architecture);

    Logger.info('Generating screen: $snake in feature $featureSnake');

    _write(
      screenPath,
      ScreenTemplates.screen(name, featureSnake, snake, designDir),
    );
    _write(
      p.join(featureRoot, 'presentation', 'providers',
          '${snake}_provider.dart'),
      ScreenTemplates.provider(snake),
    );

    Logger.success('Screen "$snake" created in lib/features/$featureSnake/');
    Logger.dim('  Register the route in lib/core/router/app_router.dart');
  }

  // ----------------------------------------------------------------- MVVM

  void _generateMvvmFeature(ProjectContext ctx, String snake) {
    final libRoot = p.join(ctx.projectRoot, 'lib');
    final modelPath = p.join(libRoot, 'models', '${snake}_model.dart');
    _ensureFileNotExists(modelPath, 'Feature model');

    final name = ctx.projectName;
    final designDir = designDirFor(ctx.architecture);

    Logger.info('Generating MVVM feature: $snake');

    _write(modelPath, MvvmFeatureTemplates.model(name, snake));
    _write(p.join(libRoot, 'services', '${snake}_service.dart'),
        MvvmFeatureTemplates.service(name, snake));
    _write(p.join(libRoot, 'viewmodels', '${snake}_viewmodel.dart'),
        MvvmFeatureTemplates.viewmodel(name, snake));
    _write(p.join(libRoot, 'views', '${snake}_view.dart'),
        MvvmFeatureTemplates.view(name, snake, designDir));

    Logger.success('Feature "$snake" created (model + service + viewmodel + view).');
    Logger.dim('  Register the route in lib/core/router/app_router.dart');
  }

  void _generateMvvmScreen(ProjectContext ctx, String snake) {
    final libRoot = p.join(ctx.projectRoot, 'lib');
    final viewPath = p.join(libRoot, 'views', '${snake}_view.dart');
    _ensureFileNotExists(viewPath, 'View');

    final name = ctx.projectName;
    final designDir = designDirFor(ctx.architecture);

    Logger.info('Generating MVVM view: $snake');
    _write(viewPath, MvvmFeatureTemplates.screen(name, snake, designDir));

    Logger.success('View "$snake" created in lib/views/');
    Logger.dim('  Register the route in lib/core/router/app_router.dart');
  }

  // ----------------------------------------------------------- Feature-first

  void _generateFeatureFirstFeature(ProjectContext ctx, String snake) {
    final featureRoot = p.join(ctx.projectRoot, 'lib', 'features', snake);
    _ensureNotExists(featureRoot, 'Feature', 'lib/features/$snake');

    final name = ctx.projectName;
    final designDir = designDirFor(ctx.architecture);

    Logger.info('Generating feature-first feature: $snake');

    _write(p.join(featureRoot, '${snake}_model.dart'),
        FeatureFirstAddTemplates.model(name, snake));
    _write(p.join(featureRoot, '${snake}_service.dart'),
        FeatureFirstAddTemplates.service(name, snake));
    _write(p.join(featureRoot, '${snake}_controller.dart'),
        FeatureFirstAddTemplates.controller(name, snake));
    _write(p.join(featureRoot, '${snake}_screen.dart'),
        FeatureFirstAddTemplates.screen(name, snake, designDir));

    Logger.success('Feature "$snake" created at lib/features/$snake/');
    Logger.dim('  Register the route in lib/shared/router/app_router.dart');
  }

  void _generateFeatureFirstScreen(
    ProjectContext ctx,
    String snake, {
    required String feature,
  }) {
    final featureSnake = StringUtils.toSnakeCase(feature);
    final featureRoot =
        p.join(ctx.projectRoot, 'lib', 'features', featureSnake);
    if (!Directory(featureRoot).existsSync()) {
      throw StateError(
        'Feature "$featureSnake" does not exist. '
        'Run `srik add feature $featureSnake` first.',
      );
    }

    final screenPath = p.join(featureRoot, '${snake}_screen.dart');
    _ensureFileNotExists(screenPath, 'Screen');

    final name = ctx.projectName;
    final designDir = designDirFor(ctx.architecture);

    Logger.info('Generating screen: $snake in feature $featureSnake');
    _write(
      screenPath,
      FeatureFirstAddTemplates.simpleScreen(name, featureSnake, snake, designDir),
    );

    Logger.success('Screen "$snake" created in lib/features/$featureSnake/');
    Logger.dim('  Register the route in lib/shared/router/app_router.dart');
  }

  // --------------------------------------------------------------- Simple

  void _generateSimpleFeature(ProjectContext ctx, String snake) {
    // For simple projects, a "feature" is just a screen + model.
    final libRoot = p.join(ctx.projectRoot, 'lib');
    final screenPath = p.join(libRoot, 'screens', '${snake}_screen.dart');
    _ensureFileNotExists(screenPath, 'Screen');

    final name = ctx.projectName;
    final designDir = designDirFor(ctx.architecture);

    Logger.info('Generating screen + model: $snake');
    _write(p.join(libRoot, 'models', '${snake}_model.dart'),
        SimpleAddTemplates.model(name, snake));
    _write(screenPath, SimpleAddTemplates.screen(name, snake, designDir));

    Logger.success('Screen "$snake" created in lib/screens/');
    Logger.dim('  Register the route in lib/router/app_router.dart');
  }

  void _generateSimpleScreen(ProjectContext ctx, String snake) {
    final libRoot = p.join(ctx.projectRoot, 'lib');
    final screenPath = p.join(libRoot, 'screens', '${snake}_screen.dart');
    _ensureFileNotExists(screenPath, 'Screen');

    final name = ctx.projectName;
    final designDir = designDirFor(ctx.architecture);

    Logger.info('Generating screen: $snake');
    _write(screenPath, SimpleAddTemplates.screen(name, snake, designDir));

    Logger.success('Screen "$snake" created in lib/screens/');
    Logger.dim('  Register the route in lib/router/app_router.dart');
  }

  // ------------------------------------------------------------- Helpers

  void _ensureNotExists(String dir, String label, String displayPath) {
    if (Directory(dir).existsSync()) {
      throw StateError('$label already exists: $displayPath');
    }
  }

  void _ensureFileNotExists(String path, String label) {
    if (File(path).existsSync()) {
      throw StateError('$label already exists: ${p.relative(path)}');
    }
  }

  void _write(String path, String contents) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(contents);
  }
}
