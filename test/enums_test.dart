import 'package:srik_cli/models/enums.dart';
import 'package:srik_cli/models/project_config.dart';
import 'package:test/test.dart';

void main() {
  group('AppArchitecture', () {
    test('parses common variants', () {
      expect(AppArchitecture.parse('clean'), AppArchitecture.clean);
      expect(AppArchitecture.parse('Clean Architecture'),
          AppArchitecture.clean);
      expect(AppArchitecture.parse('mvvm'), AppArchitecture.mvvm);
      expect(AppArchitecture.parse('MVVM'), AppArchitecture.mvvm);
      expect(AppArchitecture.parse('feature-first'),
          AppArchitecture.featureFirst);
      expect(AppArchitecture.parse('feature_first'),
          AppArchitecture.featureFirst);
      expect(AppArchitecture.parse('simple'), AppArchitecture.simple);
    });

    test('throws on unknown', () {
      expect(() => AppArchitecture.parse('garbage'),
          throwsA(isA<FormatException>()));
    });

    test('tryParse returns null on unknown', () {
      expect(AppArchitecture.tryParse('garbage'), isNull);
      expect(AppArchitecture.tryParse('clean'), AppArchitecture.clean);
    });

    test('id round-trips', () {
      for (final a in AppArchitecture.values) {
        expect(AppArchitecture.parse(a.id), a);
      }
    });
  });

  group('DesignPreset', () {
    test('parses variants', () {
      expect(DesignPreset.parse('material'), DesignPreset.material);
      expect(DesignPreset.parse('vibrant'), DesignPreset.vibrant);
      expect(DesignPreset.parse('minimal'), DesignPreset.minimal);
    });

    test('throws on unknown', () {
      expect(() => DesignPreset.parse('xyz'),
          throwsA(isA<FormatException>()));
    });
  });

  group('SpacingScale', () {
    test('parses variants', () {
      expect(SpacingScale.parse('compact'), SpacingScale.compact);
      expect(SpacingScale.parse('normal'), SpacingScale.normal);
      expect(SpacingScale.parse('spacious'), SpacingScale.spacious);
    });

    test('each scale has 6 values', () {
      for (final s in SpacingScale.values) {
        expect(s.scale.length, 6);
      }
    });

    test('compact values are smaller than spacious', () {
      expect(SpacingScale.compact.scale.last,
          lessThan(SpacingScale.spacious.scale.last));
    });
  });

  group('ProjectConfig', () {
    test('brandColorLiteral handles 6-digit hex', () {
      final config = ProjectConfig(
        projectName: 'app',
        description: 'desc',
        organization: 'com.example',
        outputDirectory: '.',
        architecture: AppArchitecture.clean,
        designPreset: DesignPreset.material,
        useGradient: false,
        spacingScale: SpacingScale.normal,
        brandColor: '#6200EE',
      );
      expect(config.brandColorLiteral, '0xFF6200EE');
    });

    test('brandColorLiteral handles 8-digit hex', () {
      final config = ProjectConfig(
        projectName: 'app',
        description: 'desc',
        organization: 'com.example',
        outputDirectory: '.',
        architecture: AppArchitecture.clean,
        designPreset: DesignPreset.material,
        useGradient: false,
        spacingScale: SpacingScale.normal,
        brandColor: '#FF6200EE',
      );
      expect(config.brandColorLiteral, '0xFF6200EE');
    });
  });
}
