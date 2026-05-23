import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:srik_cli/generators/project_generator.dart';
import 'package:srik_cli/models/enums.dart';
import 'package:srik_cli/models/project_config.dart';
import 'package:test/test.dart';

/// Integration tests for ProjectGenerator that don't depend on `flutter` being
/// on PATH — the generator gracefully skips `flutter create` / `pub get` when
/// the binary is missing, so the Dart-only output (lib/, srik.yaml, pubspec)
/// is still produced and assertable.
void main() {
  late Directory tempRoot;

  setUp(() {
    tempRoot = Directory.systemTemp.createTempSync('srik_gen_test_');
  });

  tearDown(() {
    if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
  });

  ProjectConfig makeConfig(
    AppArchitecture arch, {
    bool gradient = false,
    DesignPreset preset = DesignPreset.material,
    SpacingScale spacing = SpacingScale.normal,
    String? name,
  }) =>
      ProjectConfig(
        projectName: name ?? 'gen_${arch.id.replaceAll('-', '_')}',
        description: 'Test project',
        organization: 'com.example',
        outputDirectory: tempRoot.path,
        architecture: arch,
        designPreset: preset,
        useGradient: gradient,
        spacingScale: spacing,
        brandColor: '#6200EE',
      );

  Future<Directory> runGen(ProjectConfig c) async {
    await ProjectGenerator().generate(c);
    return Directory(c.projectPath);
  }

  group('ProjectGenerator (all architectures)', () {
    for (final arch in AppArchitecture.values) {
      test('generates ${arch.id} project with expected files', () async {
        final config = makeConfig(arch);
        final dir = await runGen(config);
        expect(dir.existsSync(), isTrue);

        // Common files
        expect(File(p.join(dir.path, 'pubspec.yaml')).existsSync(), isTrue);
        expect(File(p.join(dir.path, 'srik.yaml')).existsSync(), isTrue);
        expect(File(p.join(dir.path, 'README.md')).existsSync(), isTrue);
        expect(File(p.join(dir.path, 'analysis_options.yaml')).existsSync(),
            isTrue);
        expect(File(p.join(dir.path, 'lib', 'main.dart')).existsSync(), isTrue);
        expect(File(p.join(dir.path, 'lib', 'app.dart')).existsSync(), isTrue);

        // Architecture-specific home screen
        final libRoot = p.join(dir.path, 'lib');
        switch (arch) {
          case AppArchitecture.clean:
            expect(
              File(p.join(libRoot, 'features', 'home', 'presentation',
                      'screens', 'home_screen.dart'))
                  .existsSync(),
              isTrue,
            );
            break;
          case AppArchitecture.mvvm:
            expect(File(p.join(libRoot, 'views', 'home_view.dart')).existsSync(),
                isTrue);
            expect(
                File(p.join(libRoot, 'viewmodels', 'home_viewmodel.dart'))
                    .existsSync(),
                isTrue);
            break;
          case AppArchitecture.featureFirst:
            expect(
                File(p.join(libRoot, 'features', 'home', 'home_screen.dart'))
                    .existsSync(),
                isTrue);
            break;
          case AppArchitecture.simple:
            expect(File(p.join(libRoot, 'screens', 'home_screen.dart'))
                .existsSync(), isTrue);
            break;
        }
      });
    }

    test('clean main.dart initializes SharedPreferences', () async {
      final dir = await runGen(makeConfig(AppArchitecture.clean));
      final mainContents =
          File(p.join(dir.path, 'lib', 'main.dart')).readAsStringSync();
      expect(mainContents, contains('SharedPreferences.getInstance()'));
      expect(mainContents, contains('sharedPreferencesProvider.overrideWithValue'));
    });

    test('gradient flag generates app_gradients.dart', () async {
      final dir = await runGen(makeConfig(
        AppArchitecture.clean,
        gradient: true,
      ));
      expect(
        File(p.join(dir.path, 'lib', 'core', 'constants',
                'app_gradients.dart'))
            .existsSync(),
        isTrue,
      );
    });

    test('no gradient flag skips app_gradients.dart', () async {
      final dir = await runGen(makeConfig(AppArchitecture.clean));
      expect(
        File(p.join(dir.path, 'lib', 'core', 'constants',
                'app_gradients.dart'))
            .existsSync(),
        isFalse,
      );
    });

    test('throws when output directory already contains the project',
        () async {
      final config = makeConfig(AppArchitecture.clean, name: 'collision_app');
      await runGen(config);
      // Second generation into the same path should fail.
      expect(
        () => ProjectGenerator().generate(config),
        throwsStateError,
      );
    });

    test('srik.yaml round-trips through ProjectContext', () async {
      final config = makeConfig(
        AppArchitecture.mvvm,
        preset: DesignPreset.vibrant,
        spacing: SpacingScale.spacious,
        gradient: true,
      );
      final dir = await runGen(config);

      // Load it back.
      final yaml =
          File(p.join(dir.path, 'srik.yaml')).readAsStringSync();
      expect(yaml, contains('architecture: mvvm'));
      expect(yaml, contains('preset: vibrant'));
      expect(yaml, contains('gradient: true'));
      expect(yaml, contains('spacing: spacious'));
    });
  });
}
