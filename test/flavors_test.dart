import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:srik_cli/generators/project_generator.dart';
import 'package:srik_cli/models/enums.dart';
import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/prompts/validators.dart';
import 'package:srik_cli/templates/architectures/clean_templates.dart';
import 'package:srik_cli/templates/architectures/feature_first_templates.dart';
import 'package:srik_cli/templates/architectures/mvvm_templates.dart';
import 'package:srik_cli/templates/architectures/simple_templates.dart';
import 'package:srik_cli/templates/shared/common_templates.dart';
import 'package:test/test.dart';

ProjectConfig _config(
  AppArchitecture arch, {
  List<String> flavors = const [],
  String name = 'test_app',
}) =>
    ProjectConfig(
      projectName: name,
      description: 'A test app',
      organization: 'com.example',
      outputDirectory: '.',
      architecture: arch,
      designPreset: DesignPreset.material,
      useGradient: false,
      spacingScale: SpacingScale.normal,
      brandColor: '#6200EE',
      flavors: flavors,
    );

Map<String, String> _files(AppArchitecture arch, List<String> flavors) {
  final c = _config(arch, flavors: flavors);
  switch (arch) {
    case AppArchitecture.clean:
      return CleanTemplates.files(c);
    case AppArchitecture.mvvm:
      return MvvmTemplates.files(c);
    case AppArchitecture.featureFirst:
      return FeatureFirstTemplates.files(c);
    case AppArchitecture.simple:
      return SimpleTemplates.files(c);
  }
}

/// Config folder (relative to lib/) expected per architecture.
String _configDir(AppArchitecture arch) {
  switch (arch) {
    case AppArchitecture.clean:
      return 'core/config';
    case AppArchitecture.mvvm:
      return 'core/config';
    case AppArchitecture.featureFirst:
      return 'shared/config';
    case AppArchitecture.simple:
      return 'config';
  }
}

void main() {
  group('Flavor name validation', () {
    test('accepts valid names', () {
      expect(Validators.flavorName('dev'), isNull);
      expect(Validators.flavorName('staging'), isNull);
      expect(Validators.flavorName('prod'), isNull);
      expect(Validators.flavorName('qa_2'), isNull);
    });

    test('rejects invalid names', () {
      expect(Validators.flavorName(''), isNotNull); // empty
      expect(Validators.flavorName('Dev'), isNotNull); // uppercase
      expect(Validators.flavorName('2dev'), isNotNull); // starts with digit
      expect(Validators.flavorName('dev-1'), isNotNull); // hyphen
    });

    test('rejects reserved words', () {
      expect(Validators.flavorName('main'), isNotNull);
      expect(Validators.flavorName('test'), isNotNull);
      expect(Validators.flavorName('class'), isNotNull); // Dart keyword
    });
  });

  group('Flavor list validation', () {
    test('accepts a valid comma-separated list', () {
      expect(Validators.flavors('dev,staging,prod'), isNull);
      expect(Validators.flavors(' dev , staging '), isNull);
    });

    test('rejects an empty list', () {
      expect(Validators.flavors(''), isNotNull);
      expect(Validators.flavors('  ,  '), isNotNull);
    });

    test('rejects duplicates', () {
      final err = Validators.flavors('dev,prod,dev');
      expect(err, isNotNull);
      expect(err, contains('Duplicate'));
    });

    test('rejects a reserved word anywhere in the list', () {
      expect(Validators.flavors('dev,main'), isNotNull);
    });

    test('parseFlavors trims and drops blanks', () {
      expect(Validators.parseFlavors(' dev , , staging ,prod '),
          ['dev', 'staging', 'prod']);
    });
  });

  group('app_config.dart generation', () {
    for (final arch in AppArchitecture.values) {
      test('placed in correct folder for ${arch.id}', () {
        final files = _files(arch, ['dev', 'staging', 'prod']);
        final expectedPath = 'lib/${_configDir(arch)}/app_config.dart';
        expect(files.containsKey(expectedPath), isTrue,
            reason: 'expected $expectedPath');
      });
    }

    test('contains the Flavor enum with only chosen flavors', () {
      final files = _files(AppArchitecture.clean, ['dev', 'prod']);
      final config = files['lib/core/config/app_config.dart']!;
      expect(config, contains('enum Flavor { dev, prod }'));
      expect(config, isNot(contains('staging')));
    });

    test('embeds per-flavor URLs, app names, and bundle suffixes', () {
      final files = _files(AppArchitecture.clean, ['dev', 'staging', 'prod']);
      final config = files['lib/core/config/app_config.dart']!;
      expect(config, contains('static late AppConfig current'));
      // dev
      expect(config, contains("apiBaseUrl: 'https://dev-api.example.com'"));
      expect(config, contains("appName: 'Test App Dev'"));
      expect(config, contains("bundleSuffix: '.dev'"));
      // prod gets the bare values
      expect(config, contains("apiBaseUrl: 'https://api.example.com'"));
      expect(config, contains("appName: 'Test App'"));
      expect(config, contains("bundleSuffix: ''"));
    });
  });

  group('Flavored entry points', () {
    for (final arch in AppArchitecture.values) {
      test('one entry point per flavor for ${arch.id}', () {
        final flavors = ['dev', 'staging', 'prod'];
        final files = _files(arch, flavors);
        for (final f in flavors) {
          final path = 'lib/main_$f.dart';
          expect(files.containsKey(path), isTrue, reason: 'expected $path');
          expect(files[path]!,
              contains('AppConfig.current = AppConfig.of(Flavor.$f)'));
        }
      });
    }

    test('lib/main.dart defaults to the first flavor', () {
      final files = _files(AppArchitecture.mvvm, ['dev', 'staging']);
      expect(files['lib/main.dart']!,
          contains('AppConfig.current = AppConfig.of(Flavor.dev)'));
    });

    test('clean entry points still initialize SharedPreferences', () {
      final files = _files(AppArchitecture.clean, ['dev']);
      expect(files['lib/main_dev.dart']!,
          contains('SharedPreferences.getInstance()'));
    });
  });

  group('Flavors wire config into app and network', () {
    test('app.dart uses AppConfig.current.appName when flavored', () {
      final files = _files(AppArchitecture.clean, ['dev', 'prod']);
      final app = files['lib/app.dart']!;
      expect(app, contains('package:test_app/core/config/app_config.dart'));
      expect(app, contains('title: AppConfig.current.appName'));
    });

    test('dio client uses AppConfig.current.apiBaseUrl when flavored', () {
      final files = _files(AppArchitecture.clean, ['dev', 'prod']);
      final dio = files['lib/core/network/dio_client.dart']!;
      expect(dio, contains('baseUrl: AppConfig.current.apiBaseUrl'));
    });
  });

  group('No-flavors path is unchanged (regression guard)', () {
    for (final arch in AppArchitecture.values) {
      test('${arch.id} produces no flavor artifacts without flavors', () {
        final files = _files(arch, const []);
        // No config file, no flavored entry points.
        expect(
          files.keys.any((k) => k.contains('app_config.dart')),
          isFalse,
        );
        expect(files.keys.any((k) => k.startsWith('lib/main_')), isFalse);
        // app.dart keeps the hard-coded title, no AppConfig reference.
        expect(files['lib/app.dart']!, contains("title: 'Test App'"));
        expect(files['lib/app.dart']!, isNot(contains('AppConfig')));
      });
    }
  });

  group('srik.yaml records flavors', () {
    test('includes a flavors block when flavors are set', () {
      final yaml = CommonTemplates.srikYaml(
        _config(AppArchitecture.clean, flavors: ['dev', 'staging', 'prod']),
      );
      expect(yaml, contains('flavors:'));
      expect(yaml, contains('  - dev'));
      expect(yaml, contains('  - staging'));
      expect(yaml, contains('  - prod'));
    });

    test('omits the flavors block when there are none', () {
      final yaml = CommonTemplates.srikYaml(_config(AppArchitecture.clean));
      expect(yaml, isNot(contains('flavors:')));
    });
  });

  group('VS Code launch.json', () {
    test('has one configuration per flavor', () {
      final json = CommonTemplates.vscodeLaunchJson(
        _config(AppArchitecture.clean, flavors: ['dev', 'staging', 'prod']),
      );
      expect('"name": "dev"'.allMatches(json).length, 1);
      expect('"name": "staging"'.allMatches(json).length, 1);
      expect('"name": "prod"'.allMatches(json).length, 1);
      expect(json, contains('"program": "lib/main_dev.dart"'));
      expect(json, contains('"args": ["--flavor", "dev"]'));
      // One config object per flavor.
      expect('"type": "dart"'.allMatches(json).length, 3);
    });
  });

  group('FLAVORS_IOS_SETUP.md', () {
    test('references the flavors and the official Flutter docs', () {
      final md = CommonTemplates.flavorsIosSetup(
        _config(AppArchitecture.clean, flavors: ['dev', 'prod']),
      );
      expect(md, contains('# iOS Flavor Setup'));
      expect(md, contains('docs.flutter.dev/deployment/flavors-ios'));
      expect(md, contains('`dev`'));
      expect(md, contains('`prod`'));
      expect(md, contains('Runner.xcworkspace'));
    });
  });

  group('README flavors section', () {
    test('includes per-flavor run commands when flavored', () {
      final readme = CommonTemplates.readme(
        _config(AppArchitecture.clean, flavors: ['dev', 'prod']),
      );
      expect(readme, contains('## Flavors'));
      expect(readme, contains('flutter run --flavor dev -t lib/main_dev.dart'));
      expect(readme,
          contains('flutter build apk --flavor prod -t lib/main_prod.dart'));
      expect(readme, contains('FLAVORS_IOS_SETUP.md'));
    });

    test('omits the flavors section without flavors', () {
      final readme = CommonTemplates.readme(_config(AppArchitecture.clean));
      expect(readme, isNot(contains('## Flavors')));
    });
  });

  group('ProjectGenerator writes flavor files to disk', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('srik_flavor_test_');
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    for (final arch in AppArchitecture.values) {
      test('generates flavor files for ${arch.id}', () async {
        final config = ProjectConfig(
          projectName: 'flv_${arch.id.replaceAll('-', '_')}',
          description: 'Test',
          organization: 'com.example',
          outputDirectory: tempRoot.path,
          architecture: arch,
          designPreset: DesignPreset.material,
          useGradient: false,
          spacingScale: SpacingScale.normal,
          brandColor: '#6200EE',
          flavors: const ['dev', 'staging', 'prod'],
        );
        await ProjectGenerator().generate(config);
        final root = config.projectPath;

        expect(
          File(p.join(root, 'lib', _configDir(arch), 'app_config.dart'))
              .existsSync(),
          isTrue,
        );
        for (final f in ['dev', 'staging', 'prod']) {
          expect(File(p.join(root, 'lib', 'main_$f.dart')).existsSync(), isTrue,
              reason: 'main_$f.dart for ${arch.id}');
        }
        final yaml = File(p.join(root, 'srik.yaml')).readAsStringSync();
        expect(yaml, contains('flavors:'));

        expect(
          File(p.join(root, '.vscode', 'launch.json')).existsSync(),
          isTrue,
        );
        expect(
          File(p.join(root, 'FLAVORS_IOS_SETUP.md')).existsSync(),
          isTrue,
        );
      });
    }
  });
}
