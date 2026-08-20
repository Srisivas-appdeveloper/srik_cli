import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:srik_cli/generators/feature_generator.dart';
import 'package:srik_cli/models/project_context.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempProject;

  setUp(() {
    tempProject = Directory.systemTemp.createTempSync('srik_add_test_');

    // Minimal fake project structure
    final srikYaml = File(p.join(tempProject.path, 'srik.yaml'));
    srikYaml.writeAsStringSync('''
version: 0.2.0
project_name: test_app
architecture: clean
state_management: riverpod
routing: go_router
storage: shared_preferences
network: dio
design_system:
  preset: material
  brand_color: "#6200EE"
features:
  - home
''');

    Directory(p.join(tempProject.path, 'lib', 'features', 'home'))
        .createSync(recursive: true);
  });

  tearDown(() {
    if (tempProject.existsSync()) {
      tempProject.deleteSync(recursive: true);
    }
  });

  group('ProjectContext.load', () {
    test('loads srik.yaml from project root', () {
      final ctx = ProjectContext.load(tempProject.path);
      expect(ctx, isNotNull);
      expect(ctx!.projectName, 'test_app');
      expect(ctx.architecture, 'clean');
      expect(ctx.stateManagement, 'riverpod');
      expect(ctx.features, contains('home'));
    });

    test('walks up from subdirectory', () {
      final sub = Directory(p.join(tempProject.path, 'lib', 'features'));
      final ctx = ProjectContext.load(sub.path);
      expect(ctx, isNotNull);
      expect(ctx!.projectName, 'test_app');
    });

    test('returns null when no srik.yaml found', () {
      final orphan = Directory.systemTemp.createTempSync('srik_orphan_');
      try {
        final ctx = ProjectContext.load(orphan.path);
        expect(ctx, isNull);
      } finally {
        orphan.deleteSync(recursive: true);
      }
    });
  });

  group('FeatureGenerator.generateFeature', () {
    test('creates all expected files', () {
      final ctx = ProjectContext.load(tempProject.path)!;
      FeatureGenerator().generateFeature(ctx, 'profile');

      final base = p.join(tempProject.path, 'lib', 'features', 'profile');
      expect(
          File(p.join(base, 'domain', 'entities', 'profile_entity.dart'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(
                  base, 'domain', 'repositories', 'profile_repository.dart'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(
                  base, 'data', 'repositories', 'profile_repository_impl.dart'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(
                  base, 'presentation', 'providers', 'profile_provider.dart'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(base, 'presentation', 'screens', 'profile_screen.dart'))
              .existsSync(),
          isTrue);
    });

    test('updates srik.yaml features list', () {
      final ctx = ProjectContext.load(tempProject.path)!;
      FeatureGenerator().generateFeature(ctx, 'profile');

      final reloaded = ProjectContext.load(tempProject.path)!;
      expect(reloaded.features, contains('home'));
      expect(reloaded.features, contains('profile'));
    });

    test('rejects duplicate feature name', () {
      final ctx = ProjectContext.load(tempProject.path)!;
      FeatureGenerator().generateFeature(ctx, 'profile');

      expect(
        () => FeatureGenerator().generateFeature(ctx, 'profile'),
        throwsStateError,
      );
    });

    test('converts CamelCase input to snake_case folder', () {
      final ctx = ProjectContext.load(tempProject.path)!;
      FeatureGenerator().generateFeature(ctx, 'UserProfile');

      expect(
        Directory(p.join(tempProject.path, 'lib', 'features', 'user_profile'))
            .existsSync(),
        isTrue,
      );
    });
  });

  group('FeatureGenerator.generateScreen', () {
    test('creates screen + provider inside existing feature', () {
      final ctx = ProjectContext.load(tempProject.path)!;
      FeatureGenerator().generateScreen(ctx, 'settings', feature: 'home');

      final featureRoot = p.join(tempProject.path, 'lib', 'features', 'home');
      expect(
          File(p.join(featureRoot, 'presentation', 'screens',
                  'settings_screen.dart'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(featureRoot, 'presentation', 'providers',
                  'settings_provider.dart'))
              .existsSync(),
          isTrue);
    });

    test('underscored screen names use camelCase providers', () {
      final ctx = ProjectContext.load(tempProject.path)!;
      FeatureGenerator()
          .generateScreen(ctx, 'edit_profile', feature: 'home');

      final provider = File(
        p.join(tempProject.path, 'lib', 'features', 'home', 'presentation',
            'providers', 'edit_profile_provider.dart'),
      ).readAsStringSync();
      expect(provider, contains('editProfileStateProvider'));
      expect(provider, isNot(contains('edit_profileStateProvider')));
    });

    test('rejects screen in non-existent feature', () {
      final ctx = ProjectContext.load(tempProject.path)!;
      expect(
        () => FeatureGenerator()
            .generateScreen(ctx, 'settings', feature: 'nonexistent'),
        throwsStateError,
      );
    });
  });
}
