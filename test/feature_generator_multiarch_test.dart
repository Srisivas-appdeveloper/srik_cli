import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:srik_cli/generators/feature_generator.dart';
import 'package:srik_cli/models/project_context.dart';
import 'package:test/test.dart';

/// Tests `srik add feature` and `srik add screen` for non-clean architectures.
void main() {
  late Directory tempRoot;

  setUp(() {
    tempRoot = Directory.systemTemp.createTempSync('srik_multiarch_test_');
  });

  tearDown(() {
    if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
  });

  void writeSrikYaml(String arch) {
    File(p.join(tempRoot.path, 'srik.yaml')).writeAsStringSync('''
version: 0.3.0
project_name: test_app
architecture: $arch
state_management: riverpod
routing: go_router
storage: shared_preferences
network: dio
design_system:
  preset: material
  gradient: false
  spacing: normal
  brand_color: "#6200EE"
features:
  - home
''');
  }

  group('MVVM', () {
    setUp(() => writeSrikYaml('mvvm'));

    test('add feature creates model + service + viewmodel + view', () {
      final ctx = ProjectContext.load(tempRoot.path)!;
      FeatureGenerator().generateFeature(ctx, 'profile');

      final lib = p.join(tempRoot.path, 'lib');
      expect(File(p.join(lib, 'models', 'profile_model.dart')).existsSync(),
          isTrue);
      expect(File(p.join(lib, 'services', 'profile_service.dart')).existsSync(),
          isTrue);
      expect(
          File(p.join(lib, 'viewmodels', 'profile_viewmodel.dart'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(lib, 'views', 'profile_view.dart')).existsSync(), isTrue);
    });

    test('add screen creates a single view file', () {
      final ctx = ProjectContext.load(tempRoot.path)!;
      FeatureGenerator().generateScreen(ctx, 'settings', feature: 'home');
      expect(
        File(p.join(tempRoot.path, 'lib', 'views', 'settings_view.dart'))
            .existsSync(),
        isTrue,
      );
    });

    test('add feature updates srik.yaml', () {
      final ctx = ProjectContext.load(tempRoot.path)!;
      FeatureGenerator().generateFeature(ctx, 'profile');
      final reloaded = ProjectContext.load(tempRoot.path)!;
      expect(reloaded.features, containsAll(['home', 'profile']));
    });
  });

  group('Feature-first', () {
    setUp(() => writeSrikYaml('feature-first'));

    test(
        'add feature creates model/service/controller/screen under features/<name>/',
        () {
      // Pre-seed an existing home feature (so duplicate check is realistic).
      Directory(p.join(tempRoot.path, 'lib', 'features', 'home'))
          .createSync(recursive: true);

      final ctx = ProjectContext.load(tempRoot.path)!;
      FeatureGenerator().generateFeature(ctx, 'orders');

      final base = p.join(tempRoot.path, 'lib', 'features', 'orders');
      expect(File(p.join(base, 'orders_model.dart')).existsSync(), isTrue);
      expect(File(p.join(base, 'orders_service.dart')).existsSync(), isTrue);
      expect(File(p.join(base, 'orders_controller.dart')).existsSync(), isTrue);
      expect(File(p.join(base, 'orders_screen.dart')).existsSync(), isTrue);
    });

    test('add screen creates flat <name>_screen.dart inside feature folder',
        () {
      Directory(p.join(tempRoot.path, 'lib', 'features', 'home'))
          .createSync(recursive: true);

      final ctx = ProjectContext.load(tempRoot.path)!;
      FeatureGenerator().generateScreen(ctx, 'about', feature: 'home');

      expect(
        File(p.join(
                tempRoot.path, 'lib', 'features', 'home', 'about_screen.dart'))
            .existsSync(),
        isTrue,
      );
    });
  });

  group('Simple', () {
    setUp(() => writeSrikYaml('simple'));

    test('add feature creates screen + model in flat dirs', () {
      final ctx = ProjectContext.load(tempRoot.path)!;
      FeatureGenerator().generateFeature(ctx, 'profile');

      final lib = p.join(tempRoot.path, 'lib');
      expect(File(p.join(lib, 'screens', 'profile_screen.dart')).existsSync(),
          isTrue);
      expect(File(p.join(lib, 'models', 'profile_model.dart')).existsSync(),
          isTrue);
    });

    test('add screen creates a single screen file', () {
      final ctx = ProjectContext.load(tempRoot.path)!;
      FeatureGenerator().generateScreen(ctx, 'settings', feature: 'home');
      expect(
        File(p.join(tempRoot.path, 'lib', 'screens', 'settings_screen.dart'))
            .existsSync(),
        isTrue,
      );
    });

    test('rejects duplicate screen', () {
      final ctx = ProjectContext.load(tempRoot.path)!;
      FeatureGenerator().generateFeature(ctx, 'profile');
      expect(
        () => FeatureGenerator().generateFeature(ctx, 'profile'),
        throwsStateError,
      );
    });
  });

  group('Unknown architecture', () {
    test('throws for unrecognized arch in srik.yaml', () {
      writeSrikYaml('exotic');
      final ctx = ProjectContext.load(tempRoot.path)!;
      expect(
        () => FeatureGenerator().generateFeature(ctx, 'profile'),
        throwsStateError,
      );
    });
  });
}
