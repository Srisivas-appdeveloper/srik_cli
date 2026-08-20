import 'package:srik_cli/models/enums.dart';
import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/templates/architectures/clean_templates.dart';
import 'package:srik_cli/templates/architectures/feature_first_templates.dart';
import 'package:srik_cli/templates/architectures/mvvm_templates.dart';
import 'package:srik_cli/templates/architectures/simple_templates.dart';
import 'package:srik_cli/templates/shared/design_templates.dart';
import 'package:test/test.dart';

ProjectConfig _config(AppArchitecture arch, {bool gradient = false}) {
  return ProjectConfig(
    projectName: 'test_app',
    description: 'A test app',
    organization: 'com.example',
    outputDirectory: '.',
    architecture: arch,
    designPreset: DesignPreset.vibrant,
    useGradient: gradient,
    spacingScale: SpacingScale.normal,
    brandColor: '#6200EE',
  );
}

void main() {
  group('Architecture templates produce key files', () {
    test('Clean has main, app, and home screen', () {
      final files = CleanTemplates.files(_config(AppArchitecture.clean));
      expect(files.containsKey('lib/main.dart'), isTrue);
      expect(files.containsKey('lib/app.dart'), isTrue);
      expect(
        files.containsKey(
            'lib/features/home/presentation/screens/home_screen.dart'),
        isTrue,
      );
    });

    test('MVVM has viewmodels and views', () {
      final files = MvvmTemplates.files(_config(AppArchitecture.mvvm));
      expect(files.containsKey('lib/viewmodels/home_viewmodel.dart'), isTrue);
      expect(files.containsKey('lib/views/home_view.dart'), isTrue);
      expect(files.containsKey('lib/models/home_model.dart'), isTrue);
    });

    test('Feature-first has shared and feature folders', () {
      final files =
          FeatureFirstTemplates.files(_config(AppArchitecture.featureFirst));
      expect(files.containsKey('lib/features/home/home_screen.dart'), isTrue);
      expect(files.containsKey('lib/shared/router/app_router.dart'), isTrue);
    });

    test('Simple has screens folder', () {
      final files = SimpleTemplates.files(_config(AppArchitecture.simple));
      expect(files.containsKey('lib/screens/home_screen.dart'), isTrue);
      expect(files.containsKey('lib/router/app_router.dart'), isTrue);
    });
  });

  group('Generated code uses package imports', () {
    test('Clean app.dart imports package paths', () {
      final files = CleanTemplates.files(_config(AppArchitecture.clean));
      final app = files['lib/app.dart']!;
      expect(
        app.contains('package:test_app/core/design/themes/app_theme.dart'),
        isTrue,
      );
    });

    test('MVVM view imports package paths', () {
      final files = MvvmTemplates.files(_config(AppArchitecture.mvvm));
      final view = files['lib/views/home_view.dart']!;
      expect(view.contains('package:test_app/'), isTrue);
    });
  });

  group('DesignTemplates', () {
    test('produces required token, theme, and component files', () {
      final files = DesignTemplates.allFiles(_config(AppArchitecture.clean));
      expect(files.containsKey('tokens/app_colors.dart'), isTrue);
      expect(files.containsKey('tokens/app_shadows.dart'), isTrue);
      expect(files.containsKey('tokens/app_blur.dart'), isTrue);
      expect(files.containsKey('components/app_surface.dart'), isTrue);
      expect(files.containsKey('components/app_button.dart'), isTrue);
      expect(files.containsKey('design_system.dart'), isTrue);
      expect(files.containsKey('tokens/app_gradients.dart'), isTrue);
    });

    test('legacy shims omit app_gradients without the flag', () {
      final shims = DesignTemplates.legacyShims(_config(AppArchitecture.clean));
      expect(shims.containsKey('app_gradients.dart'), isFalse);
      expect(shims.containsKey('app_theme.dart'), isTrue);
    });

    test('legacy shims include app_gradients with the flag', () {
      final shims = DesignTemplates.legacyShims(
        _config(AppArchitecture.clean, gradient: true),
      );
      expect(shims.containsKey('app_gradients.dart'), isTrue);
    });

    test('colors file embeds the brand color literal', () {
      final colors = DesignTemplates.colors(_config(AppArchitecture.clean));
      expect(colors.contains('0xFF6200EE'), isTrue);
    });

    test('spacing reflects the chosen scale', () {
      final compact = DesignTemplates.spacing(
        ProjectConfig(
          projectName: 'a',
          description: 'd',
          organization: 'com.e',
          outputDirectory: '.',
          architecture: AppArchitecture.clean,
          designPreset: DesignPreset.material,
          useGradient: false,
          spacingScale: SpacingScale.compact,
          brandColor: '#000000',
        ),
      );
      expect(compact.contains('Density: compact'), isTrue);
    });
  });
}
