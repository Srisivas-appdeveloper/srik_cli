import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:srik_cli/generators/gradle_editor.dart';
import 'package:srik_cli/generators/project_generator.dart';
import 'package:srik_cli/models/enums.dart';
import 'package:srik_cli/models/project_config.dart';
import 'package:test/test.dart';

/// A minimal stand-in for a Flutter-generated Kotlin DSL app gradle file.
const _ktsSample = '''
plugins {
    id("com.android.application")
}

android {
    namespace = "com.example.demo"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.demo"
        minSdk = flutter.minSdkVersion
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
''';

/// A minimal stand-in for a legacy Groovy app gradle file.
const _groovySample = '''
android {
    namespace "com.example.demo"
    compileSdkVersion flutter.compileSdkVersion

    defaultConfig {
        applicationId "com.example.demo"
        minSdkVersion flutter.minSdkVersion
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}
''';

List<FlavorGradle> _flavors() => [
      FlavorGradle.from('dev', 'Demo'),
      FlavorGradle.from('staging', 'Demo'),
      FlavorGradle.from('prod', 'Demo'),
    ];

void main() {
  group('FlavorGradle.from', () {
    test('non-prod flavors get suffixes and a labelled name', () {
      final dev = FlavorGradle.from('dev', 'Demo');
      expect(dev.applicationIdSuffix, '.dev');
      expect(dev.versionNameSuffix, '-dev');
      expect(dev.appLabel, 'Demo Dev');
    });

    test('prod has no suffixes and the bare title', () {
      final prod = FlavorGradle.from('prod', 'Demo');
      expect(prod.applicationIdSuffix, '');
      expect(prod.versionNameSuffix, '');
      expect(prod.appLabel, 'Demo');
    });
  });

  group('injectProductFlavors (Kotlin DSL)', () {
    test('inserts inside the android block, not appended', () {
      final out = GradleEditor.injectProductFlavors(
        _ktsSample,
        isKts: true,
        flavors: _flavors(),
      );

      // The block exists.
      expect(out, contains('flavorDimensions += "flavor"'));
      expect(out, contains('productFlavors {'));
      expect(out, contains('create("dev") {'));
      expect(out, contains('applicationIdSuffix = ".dev"'));
      expect(out, contains('versionNameSuffix = "-dev"'));
      expect(out, contains('resValue("string", "app_name", "Demo Dev")'));
      // prod omits suffix lines but keeps the label.
      expect(out, contains('create("prod") {'));
      expect(out, contains('resValue("string", "app_name", "Demo")'));

      // It is INSIDE android { } — productFlavors appears before the
      // `flutter {` block that follows the android block.
      expect(out.indexOf('productFlavors'), lessThan(out.indexOf('flutter {')));

      // Braces still balance.
      final opens = '{'.allMatches(out).length;
      final closes = '}'.allMatches(out).length;
      expect(opens, closes);
    });

    test('prod flavor omits applicationIdSuffix line', () {
      final out = GradleEditor.injectProductFlavors(
        _ktsSample,
        isKts: true,
        flavors: [FlavorGradle.from('prod', 'Demo')],
      );
      expect(out, isNot(contains('applicationIdSuffix = ""')));
    });
  });

  group('injectProductFlavors (Groovy DSL)', () {
    test('uses Groovy syntax', () {
      final out = GradleEditor.injectProductFlavors(
        _groovySample,
        isKts: false,
        flavors: _flavors(),
      );
      expect(out, contains('flavorDimensions "flavor"'));
      expect(out, contains('dev {'));
      expect(out, contains('applicationIdSuffix ".dev"'));
      expect(out, contains('resValue "string", "app_name", "Demo Dev"'));
      expect(out, isNot(contains('create(')));

      final opens = '{'.allMatches(out).length;
      final closes = '}'.allMatches(out).length;
      expect(opens, closes);
    });
  });

  group('setAppLabelToResource (manifest)', () {
    const manifest = '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="man_probe"
        android:name="\${applicationName}"
        android:icon="@mipmap/ic_launcher">
    </application>
</manifest>
''';

    test('replaces the hard-coded label with the string resource', () {
      final out = GradleEditor.setAppLabelToResource(manifest);
      expect(out, contains('android:label="@string/app_name"'));
      expect(out, isNot(contains('android:label="man_probe"')));
      // Only the label changes — other attributes are preserved.
      expect(out, contains('android:icon="@mipmap/ic_launcher"'));
    });

    test('is idempotent', () {
      final once = GradleEditor.setAppLabelToResource(manifest);
      final twice = GradleEditor.setAppLabelToResource(once);
      expect(twice, once);
    });

    test('throws when there is no android:label', () {
      expect(
        () => GradleEditor.setAppLabelToResource('<manifest></manifest>'),
        throwsStateError,
      );
    });
  });

  test('throws when there is no android block', () {
    expect(
      () => GradleEditor.injectProductFlavors(
        'plugins { id("x") }',
        isKts: true,
        flavors: _flavors(),
      ),
      throwsStateError,
    );
  });

  group('GradleEditor.apply (file-level)', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('srik_gradle_test_');
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    ProjectConfig config(List<String> flavors) => ProjectConfig(
          projectName: 'demo',
          description: 'd',
          organization: 'com.example',
          outputDirectory: tempRoot.path,
          architecture: AppArchitecture.clean,
          designPreset: DesignPreset.material,
          useGradient: false,
          spacingScale: SpacingScale.normal,
          brandColor: '#6200EE',
          flavors: flavors,
        );

    void writeGradle(String projectName, String name, String content) {
      final f =
          File(p.join(tempRoot.path, projectName, 'android', 'app', name));
      f.parent.createSync(recursive: true);
      f.writeAsStringSync(content);
    }

    test('edits build.gradle.kts when present', () {
      writeGradle('demo', 'build.gradle.kts', _ktsSample);
      GradleEditor.apply(config(['dev', 'prod']));
      final out = File(p.join(
              tempRoot.path, 'demo', 'android', 'app', 'build.gradle.kts'))
          .readAsStringSync();
      expect(out, contains('productFlavors {'));
      expect(out, contains('create("dev")'));
    });

    test('edits Groovy build.gradle when no .kts exists', () {
      writeGradle('demo', 'build.gradle', _groovySample);
      GradleEditor.apply(config(['dev']));
      final out =
          File(p.join(tempRoot.path, 'demo', 'android', 'app', 'build.gradle'))
              .readAsStringSync();
      expect(out, contains('productFlavors {'));
      expect(out, contains('dev {'));
    });

    test('is idempotent — leaves an already-flavored file untouched', () {
      writeGradle('demo', 'build.gradle.kts', _ktsSample);
      GradleEditor.apply(config(['dev']));
      final once = File(p.join(
              tempRoot.path, 'demo', 'android', 'app', 'build.gradle.kts'))
          .readAsStringSync();
      GradleEditor.apply(config(['dev']));
      final twice = File(p.join(
              tempRoot.path, 'demo', 'android', 'app', 'build.gradle.kts'))
          .readAsStringSync();
      expect(twice, once);
    });

    test('no-op without flavors', () {
      writeGradle('demo', 'build.gradle.kts', _ktsSample);
      GradleEditor.apply(config(const []));
      final out = File(p.join(
              tempRoot.path, 'demo', 'android', 'app', 'build.gradle.kts'))
          .readAsStringSync();
      expect(out, isNot(contains('productFlavors')));
    });

    test('applyManifest wires the label to @string/app_name', () {
      final manifest = File(p.join(tempRoot.path, 'demo', 'android', 'app',
          'src', 'main', 'AndroidManifest.xml'));
      manifest.parent.createSync(recursive: true);
      manifest.writeAsStringSync(
        '<manifest><application android:label="demo" /></manifest>',
      );
      GradleEditor.applyManifest(config(['dev']));
      expect(manifest.readAsStringSync(),
          contains('android:label="@string/app_name"'));
    });
  });

  group('ProjectGenerator integration', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('srik_gradle_gen_');
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('generated project with flavors has productFlavors in gradle',
        () async {
      final config = ProjectConfig(
        projectName: 'flavor_gen',
        description: 'd',
        organization: 'com.example',
        outputDirectory: tempRoot.path,
        architecture: AppArchitecture.clean,
        designPreset: DesignPreset.material,
        useGradient: false,
        spacingScale: SpacingScale.normal,
        brandColor: '#6200EE',
        flavors: const ['dev', 'staging', 'prod'],
      );
      await ProjectGenerator().generate(config);

      final kts = File(
          p.join(config.projectPath, 'android', 'app', 'build.gradle.kts'));
      final groovy =
          File(p.join(config.projectPath, 'android', 'app', 'build.gradle'));

      // Only assert when flutter create actually produced a gradle file.
      if (kts.existsSync()) {
        final out = kts.readAsStringSync();
        expect(out, contains('productFlavors {'));
        expect(out, contains('create("dev")'));
        expect(out, contains('create("staging")'));
        expect(out, contains('create("prod")'));
      } else if (groovy.existsSync()) {
        final out = groovy.readAsStringSync();
        expect(out, contains('productFlavors {'));
        expect(out, contains('dev {'));
      }

      final manifest = File(p.join(config.projectPath, 'android', 'app', 'src',
          'main', 'AndroidManifest.xml'));
      if (manifest.existsSync()) {
        expect(manifest.readAsStringSync(),
            contains('android:label="@string/app_name"'));
      }
    });
  });
}
