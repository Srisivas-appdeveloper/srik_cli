import 'package:srik_cli/design/design_paths.dart';
import 'package:srik_cli/design/token_builder.dart';
import 'package:srik_cli/models/enums.dart';
import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/models/project_context.dart';
import 'package:srik_cli/templates/architectures/clean_templates.dart';
import 'package:srik_cli/templates/architectures/feature_first_templates.dart';
import 'package:srik_cli/templates/architectures/mvvm_templates.dart';
import 'package:srik_cli/templates/architectures/simple_templates.dart';
import 'package:srik_cli/templates/shared/common_templates.dart';
import 'package:srik_cli/templates/shared/design_templates.dart';
import 'package:test/test.dart';

ProjectConfig _config({
  AppArchitecture arch = AppArchitecture.clean,
  DesignStyle style = DesignStyle.material,
  bool gradient = false,
  String brand = '#6200EE',
}) {
  return ProjectConfig(
    projectName: 'test_app',
    description: 'A test app',
    organization: 'com.example',
    outputDirectory: '.',
    architecture: arch,
    designPreset: style,
    useGradient: gradient,
    spacingScale: SpacingScale.normal,
    brandColor: brand,
  );
}

void main() {
  group('architecture design paths', () {
    test('maps each architecture to a design-system folder', () {
      expect(DesignPaths.systemDir(AppArchitecture.clean), 'core/design');
      expect(DesignPaths.systemDir(AppArchitecture.mvvm), 'core/design');
      expect(
        DesignPaths.systemDir(AppArchitecture.featureFirst),
        'shared/design',
      );
      expect(DesignPaths.systemDir(AppArchitecture.simple), 'design');
    });

    test('legacy token folders remain available', () {
      expect(
          DesignPaths.legacyTokenDir(AppArchitecture.clean), 'core/constants');
      expect(
        DesignPaths.legacyTokenDir(AppArchitecture.featureFirst),
        'shared/theme',
      );
      expect(DesignPaths.legacyTokenDir(AppArchitecture.simple), 'theme');
    });
  });

  group('token builder', () {
    test('material keeps the brand as light primary', () {
      final tokens = DesignTokens.fromConfig(_config());
      expect(tokens.light.primary.hex, 'FF6200EE');
    });

    test('every style derives an opaque primary from the brand', () {
      for (final style in DesignStyle.values) {
        final tokens = DesignTokens.fromConfig(_config(style: style));
        expect(tokens.light.primary.a, 255);
        expect(tokens.light.primary.hex, isNot(tokens.light.background.hex));
      }
    });

    test('derives different surfaces for neo vs brutal vs glass', () {
      final neo = DesignTokens.fromConfig(
        _config(style: DesignStyle.neomorphism),
      );
      final brutal = DesignTokens.fromConfig(
        _config(style: DesignStyle.brutalism),
      );
      final glass = DesignTokens.fromConfig(
        _config(style: DesignStyle.glassmorphism),
      );
      expect(neo.recipe.usesNeoShadows, isTrue);
      expect(brutal.recipe.usesHardOffsetShadow, isTrue);
      expect(glass.recipe.usesBlur, isTrue);
      expect(glass.light.surfaceTranslucent.a, lessThan(255));
    });

    test('different brands produce different primaries', () {
      final a = DesignTokens.fromConfig(_config(brand: '#FF0000'));
      final b = DesignTokens.fromConfig(_config(brand: '#00AAFF'));
      expect(a.light.primary.hex, isNot(b.light.primary.hex));
    });
  });

  group('design file matrix', () {
    const required = <String>[
      'tokens/app_colors.dart',
      'tokens/app_spacing.dart',
      'tokens/app_radius.dart',
      'tokens/app_typography.dart',
      'tokens/app_shadows.dart',
      'tokens/app_blur.dart',
      'tokens/app_borders.dart',
      'tokens/app_opacity.dart',
      'tokens/app_gradients.dart',
      'tokens/app_elevation.dart',
      'tokens/app_motion.dart',
      'tokens/app_sizes.dart',
      'themes/app_theme.dart',
      'themes/app_theme_extensions.dart',
      'components/app_surface.dart',
      'components/app_card.dart',
      'components/app_button.dart',
      'components/app_icon_button.dart',
      'components/app_text_field.dart',
      'components/app_chip.dart',
      'components/app_badge.dart',
      'components/app_dialog.dart',
      'components/app_bottom_sheet.dart',
      'components/app_navigation_bar.dart',
      'styles/design_style.dart',
      'styles/design_style_config.dart',
      'design_system.dart',
    ];

    for (final arch in AppArchitecture.values) {
      for (final style in DesignStyle.values) {
        test('${arch.id} + ${style.id} generates the design system', () {
          final files = DesignTemplates.allFiles(
            _config(arch: arch, style: style),
          );
          for (final name in required) {
            expect(files.containsKey(name), isTrue, reason: name);
          }
          final configFile = files['styles/design_style.dart']!;
          expect(configFile, contains('AppDesignStyle.${style.dartName}'));
          final home = _homeSource(arch, _config(arch: arch, style: style));
          expect(home, contains('design_system.dart'));
          expect(home, contains('AppCard'));
          expect(home, contains('AppButton'));
          expect(home, isNot(contains('glass_home_screen')));
        });
      }
    }
  });

  group('srik.yaml', () {
    test('persists normalized design metadata', () {
      final yaml = CommonTemplates.srikYaml(
        _config(style: DesignStyle.glassmorphism, gradient: true),
      );
      expect(yaml, contains('schema_version: 2'));
      expect(yaml, contains('style: glassmorphism'));
      expect(yaml, contains('preset: glassmorphism'));
      expect(yaml, contains('gradient: true'));
    });

    test('legacy yaml without design.style still loads', () {
      // ProjectContext.parse is private; load via a temp-like string is
      // covered in add_command_test. Here we only assert tryParse mapping.
      expect(DesignStyle.parse('minimal').id, 'minimalism');
    });
  });

  group('legacy project context', () {
    test('schema v1 does not use the nested design system', () {
      final ctx = ProjectContext(
        projectName: 'old',
        architecture: 'clean',
        stateManagement: 'riverpod',
        routing: 'go_router',
        storage: 'shared_preferences',
        network: 'dio',
        brandColor: '#6200EE',
        designPreset: 'material',
        useGradient: false,
        spacingScale: 'normal',
        flavors: const [],
        features: const ['home'],
        projectRoot: '.',
        schemaVersion: 1,
      );
      expect(ctx.usesDesignSystem, isFalse);
    });
  });
}

String _homeSource(AppArchitecture arch, ProjectConfig config) {
  switch (arch) {
    case AppArchitecture.clean:
      return CleanTemplates.files(
          config)['lib/features/home/presentation/screens/home_screen.dart']!;
    case AppArchitecture.mvvm:
      return MvvmTemplates.files(config)['lib/views/home_view.dart']!;
    case AppArchitecture.featureFirst:
      return FeatureFirstTemplates.files(
          config)['lib/features/home/home_screen.dart']!;
    case AppArchitecture.simple:
      return SimpleTemplates.files(config)['lib/screens/home_screen.dart']!;
  }
}
