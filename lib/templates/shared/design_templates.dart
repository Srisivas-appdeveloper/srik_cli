import 'package:srik_cli/models/design_palette.dart';
import 'package:srik_cli/models/enums.dart';
import 'package:srik_cli/models/project_config.dart';

/// Generates the design system files. These are identical regardless of
/// architecture — only the folder they land in differs.
class DesignTemplates {
  static String colors(ProjectConfig c) {
    final palette = DesignPalette.forPreset(c.designPreset);
    final neutralLines = <String>[];
    const steps = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
    for (var i = 0; i < steps.length; i++) {
      neutralLines.add(
          '  static const Color neutral${steps[i]} = Color(0x${palette.neutral[i]});');
    }

    return '''
import 'package:flutter/material.dart';

/// App color palette.
/// Preset: ${c.designPreset.id}. Brand color: ${c.brandColor}.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(${c.brandColorLiteral});
  static const Color secondary = Color(0x${palette.secondary});

  // Surface
  static const Color background = Color(0x${palette.background});
  static const Color surface = Color(0x${palette.surface});
  static const Color overlay = Color(0x80000000);

  // Semantic
  static const Color success = Color(0x${palette.success});
  static const Color warning = Color(0x${palette.warning});
  static const Color error = Color(0x${palette.error});
  static const Color info = Color(0x${palette.info});

  // Text
  static const Color textPrimary = Color(0x${palette.textPrimary});
  static const Color textSecondary = Color(0x${palette.textSecondary});
  static const Color textDisabled = Color(0x${palette.textDisabled});
  static const Color textOnPrimary = Color(0x${palette.textOnPrimary});

  // Neutral scale
${neutralLines.join('\n')}
}
''';
  }

  static String spacing(ProjectConfig c) {
    final v = c.spacingScale.scale;
    return '''
/// Spacing scale. Density: ${c.spacingScale.id}.
class AppSpacing {
  AppSpacing._();

  static const double xs = ${v[0]};
  static const double sm = ${v[1]};
  static const double md = ${v[2]};
  static const double lg = ${v[3]};
  static const double xl = ${v[4]};
  static const double xxl = ${v[5]};
}
''';
  }

  static String radius(ProjectConfig c) {
    // Minimal preset uses sharper corners.
    final isMinimal = c.designPreset == DesignPreset.minimal;
    return '''
/// Border radius scale.
class AppRadius {
  AppRadius._();

  static const double sm = ${isMinimal ? 2.0 : 4.0};
  static const double md = ${isMinimal ? 4.0 : 8.0};
  static const double lg = ${isMinimal ? 8.0 : 16.0};
  static const double xl = ${isMinimal ? 12.0 : 24.0};
  static const double pill = 999.0;
}
''';
  }

  static String textStyles(ProjectConfig c) {
    return '''
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography scale.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
''';
  }

  static String durations(ProjectConfig c) {
    return '''
/// Animation durations.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
''';
  }

  /// Only generated when useGradient is true.
  static String gradients(ProjectConfig c) {
    final palette = DesignPalette.forPreset(c.designPreset);
    return '''
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Reusable gradients built from the brand color.
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      Color(0x${palette.gradientEnd}),
    ],
  );

  static const LinearGradient subtle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.surface,
      AppColors.background,
    ],
  );

  static const RadialGradient glow = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.2,
    colors: [
      AppColors.primary,
      Color(0x${palette.gradientEnd}),
    ],
  );
}
''';
  }

  static String theme(ProjectConfig c) {
    final gradientImport =
        c.useGradient ? "import 'app_gradients.dart';\n" : '';
    // Note about gradient usage in a doc comment so it isn't an unused import.
    final gradientNote = c.useGradient
        ? '\n  /// Gradients available via AppGradients (see app_gradients.dart).'
        : '';

    return '''
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';
$gradientImport
/// App-wide ThemeData (light + dark).$gradientNote
class AppTheme {
  AppTheme._();
${c.useGradient ? '\n  /// The primary gradient, surfaced for convenience.\n  static const Gradient primaryGradient = AppGradients.primary;\n' : ''}
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: const TextTheme(
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          headlineSmall: AppTextStyles.h3,
          bodyMedium: AppTextStyles.body,
          bodySmall: AppTextStyles.caption,
          labelLarge: AppTextStyles.button,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle: AppTextStyles.button,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.neutral100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      );
}
''';
  }

  /// Returns map of filename -> contents for the design system.
  static Map<String, String> allFiles(ProjectConfig c) {
    final files = <String, String>{
      'app_colors.dart': colors(c),
      'app_spacing.dart': spacing(c),
      'app_radius.dart': radius(c),
      'app_text_styles.dart': textStyles(c),
      'app_durations.dart': durations(c),
      'app_theme.dart': theme(c),
    };
    if (c.useGradient) {
      files['app_gradients.dart'] = gradients(c);
    }
    return files;
  }
}
