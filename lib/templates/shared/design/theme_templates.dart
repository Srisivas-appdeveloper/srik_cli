/// ThemeData + ThemeExtension source.
class ThemeTemplates {
  ThemeTemplates._();

  static String extensions() {
    return r'''
import 'package:flutter/material.dart';

import '../tokens/app_blur.dart';
import '../tokens/app_borders.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_elevation.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_shadows.dart';

@immutable
class AppSurfaceTheme extends ThemeExtension<AppSurfaceTheme> {
  const AppSurfaceTheme({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceElevated,
    required this.surfaceTranslucent,
    required this.highlight,
    required this.scrim,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceElevated;
  final Color surfaceTranslucent;
  final Color highlight;
  final Color scrim;

  static const AppSurfaceTheme light = AppSurfaceTheme(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceVariant: AppColors.surfaceVariant,
    surfaceElevated: AppColors.surfaceElevated,
    surfaceTranslucent: AppColors.surfaceTranslucent,
    highlight: AppColors.highlight,
    scrim: AppColors.scrim,
  );

  static const AppSurfaceTheme dark = AppSurfaceTheme(
    background: AppColorsDark.background,
    surface: AppColorsDark.surface,
    surfaceVariant: AppColorsDark.surfaceVariant,
    surfaceElevated: AppColorsDark.surfaceElevated,
    surfaceTranslucent: AppColorsDark.surfaceTranslucent,
    highlight: AppColorsDark.highlight,
    scrim: AppColorsDark.scrim,
  );

  @override
  AppSurfaceTheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? surfaceElevated,
    Color? surfaceTranslucent,
    Color? highlight,
    Color? scrim,
  }) {
    return AppSurfaceTheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceTranslucent: surfaceTranslucent ?? this.surfaceTranslucent,
      highlight: highlight ?? this.highlight,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  AppSurfaceTheme lerp(ThemeExtension<AppSurfaceTheme>? other, double t) {
    if (other is! AppSurfaceTheme) return this;
    return AppSurfaceTheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceTranslucent:
          Color.lerp(surfaceTranslucent, other.surfaceTranslucent, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

@immutable
class AppShadowTheme extends ThemeExtension<AppShadowTheme> {
  const AppShadowTheme({
    required this.flat,
    required this.low,
    required this.medium,
    required this.high,
    required this.floating,
    required this.neoRaised,
    required this.neoInset,
    required this.hardOffset,
    required this.clay,
  });

  final List<BoxShadow> flat;
  final List<BoxShadow> low;
  final List<BoxShadow> medium;
  final List<BoxShadow> high;
  final List<BoxShadow> floating;
  final List<BoxShadow> neoRaised;
  final List<BoxShadow> neoInset;
  final List<BoxShadow> hardOffset;
  final List<BoxShadow> clay;

  static AppShadowTheme get light => AppShadowTheme(
        flat: AppShadows.flat,
        low: AppShadows.low,
        medium: AppShadows.medium,
        high: AppShadows.high,
        floating: AppShadows.floating,
        neoRaised: AppShadows.neoRaised,
        neoInset: AppShadows.neoInset,
        hardOffset: AppShadows.hardOffset,
        clay: AppShadows.clay,
      );

  static AppShadowTheme get dark => light;

  @override
  AppShadowTheme copyWith({
    List<BoxShadow>? flat,
    List<BoxShadow>? low,
    List<BoxShadow>? medium,
    List<BoxShadow>? high,
    List<BoxShadow>? floating,
    List<BoxShadow>? neoRaised,
    List<BoxShadow>? neoInset,
    List<BoxShadow>? hardOffset,
    List<BoxShadow>? clay,
  }) {
    return AppShadowTheme(
      flat: flat ?? this.flat,
      low: low ?? this.low,
      medium: medium ?? this.medium,
      high: high ?? this.high,
      floating: floating ?? this.floating,
      neoRaised: neoRaised ?? this.neoRaised,
      neoInset: neoInset ?? this.neoInset,
      hardOffset: hardOffset ?? this.hardOffset,
      clay: clay ?? this.clay,
    );
  }

  @override
  AppShadowTheme lerp(ThemeExtension<AppShadowTheme>? other, double t) {
    if (other is! AppShadowTheme) return this;
    return t < 0.5 ? this : other;
  }
}

@immutable
class AppBlurTheme extends ThemeExtension<AppBlurTheme> {
  const AppBlurTheme({
    required this.none,
    required this.subtle,
    required this.small,
    required this.medium,
    required this.large,
    required this.intense,
  });

  final double none;
  final double subtle;
  final double small;
  final double medium;
  final double large;
  final double intense;

  static const AppBlurTheme tokens = AppBlurTheme(
    none: AppBlur.none,
    subtle: AppBlur.subtle,
    small: AppBlur.small,
    medium: AppBlur.medium,
    large: AppBlur.large,
    intense: AppBlur.intense,
  );

  @override
  AppBlurTheme copyWith({
    double? none,
    double? subtle,
    double? small,
    double? medium,
    double? large,
    double? intense,
  }) {
    return AppBlurTheme(
      none: none ?? this.none,
      subtle: subtle ?? this.subtle,
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      intense: intense ?? this.intense,
    );
  }

  @override
  AppBlurTheme lerp(ThemeExtension<AppBlurTheme>? other, double t) {
    if (other is! AppBlurTheme) return this;
    return AppBlurTheme(
      none: lerpDouble(none, other.none, t),
      subtle: lerpDouble(subtle, other.subtle, t),
      small: lerpDouble(small, other.small, t),
      medium: lerpDouble(medium, other.medium, t),
      large: lerpDouble(large, other.large, t),
      intense: lerpDouble(intense, other.intense, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

@immutable
class AppBorderTheme extends ThemeExtension<AppBorderTheme> {
  const AppBorderTheme({
    required this.thin,
    required this.regular,
    required this.bold,
    required this.color,
    required this.variant,
  });

  final double thin;
  final double regular;
  final double bold;
  final Color color;
  final Color variant;

  static const AppBorderTheme light = AppBorderTheme(
    thin: AppBorders.thin,
    regular: AppBorders.regular,
    bold: AppBorders.bold,
    color: AppColors.outline,
    variant: AppColors.outlineVariant,
  );

  static const AppBorderTheme dark = AppBorderTheme(
    thin: AppBorders.thin,
    regular: AppBorders.regular,
    bold: AppBorders.bold,
    color: AppColorsDark.outline,
    variant: AppColorsDark.outlineVariant,
  );

  @override
  AppBorderTheme copyWith({
    double? thin,
    double? regular,
    double? bold,
    Color? color,
    Color? variant,
  }) {
    return AppBorderTheme(
      thin: thin ?? this.thin,
      regular: regular ?? this.regular,
      bold: bold ?? this.bold,
      color: color ?? this.color,
      variant: variant ?? this.variant,
    );
  }

  @override
  AppBorderTheme lerp(ThemeExtension<AppBorderTheme>? other, double t) {
    if (other is! AppBorderTheme) return this;
    return AppBorderTheme(
      thin: AppBlurTheme.lerpDouble(thin, other.thin, t),
      regular: AppBlurTheme.lerpDouble(regular, other.regular, t),
      bold: AppBlurTheme.lerpDouble(bold, other.bold, t),
      color: Color.lerp(color, other.color, t)!,
      variant: Color.lerp(variant, other.variant, t)!,
    );
  }
}

@immutable
class AppMotionTheme extends ThemeExtension<AppMotionTheme> {
  const AppMotionTheme({
    required this.fast,
    required this.normal,
    required this.slow,
    required this.emphasized,
    required this.standardCurve,
    required this.entranceCurve,
    required this.exitCurve,
  });

  final Duration fast;
  final Duration normal;
  final Duration slow;
  final Duration emphasized;
  final Curve standardCurve;
  final Curve entranceCurve;
  final Curve exitCurve;

  static const AppMotionTheme tokens = AppMotionTheme(
    fast: AppMotion.fast,
    normal: AppMotion.normal,
    slow: AppMotion.slow,
    emphasized: AppMotion.emphasized,
    standardCurve: AppMotion.standardCurve,
    entranceCurve: AppMotion.entranceCurve,
    exitCurve: AppMotion.exitCurve,
  );

  @override
  AppMotionTheme copyWith({
    Duration? fast,
    Duration? normal,
    Duration? slow,
    Duration? emphasized,
    Curve? standardCurve,
    Curve? entranceCurve,
    Curve? exitCurve,
  }) {
    return AppMotionTheme(
      fast: fast ?? this.fast,
      normal: normal ?? this.normal,
      slow: slow ?? this.slow,
      emphasized: emphasized ?? this.emphasized,
      standardCurve: standardCurve ?? this.standardCurve,
      entranceCurve: entranceCurve ?? this.entranceCurve,
      exitCurve: exitCurve ?? this.exitCurve,
    );
  }

  @override
  AppMotionTheme lerp(ThemeExtension<AppMotionTheme>? other, double t) {
    if (other is! AppMotionTheme) return this;
    return t < 0.5 ? this : other;
  }
}

@immutable
class AppComponentTheme extends ThemeExtension<AppComponentTheme> {
  const AppComponentTheme({
    required this.controlRadius,
    required this.cardRadius,
    required this.minTapTarget,
    required this.elevation,
  });

  final double controlRadius;
  final double cardRadius;
  final double minTapTarget;
  final double elevation;

  static const AppComponentTheme tokens = AppComponentTheme(
    controlRadius: AppRadius.md,
    cardRadius: AppRadius.lg,
    minTapTarget: 48,
    elevation: AppElevation.low,
  );

  @override
  AppComponentTheme copyWith({
    double? controlRadius,
    double? cardRadius,
    double? minTapTarget,
    double? elevation,
  }) {
    return AppComponentTheme(
      controlRadius: controlRadius ?? this.controlRadius,
      cardRadius: cardRadius ?? this.cardRadius,
      minTapTarget: minTapTarget ?? this.minTapTarget,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  AppComponentTheme lerp(ThemeExtension<AppComponentTheme>? other, double t) {
    if (other is! AppComponentTheme) return this;
    return AppComponentTheme(
      controlRadius:
          AppBlurTheme.lerpDouble(controlRadius, other.controlRadius, t),
      cardRadius: AppBlurTheme.lerpDouble(cardRadius, other.cardRadius, t),
      minTapTarget:
          AppBlurTheme.lerpDouble(minTapTarget, other.minTapTarget, t),
      elevation: AppBlurTheme.lerpDouble(elevation, other.elevation, t),
    );
  }
}
''';
  }

  static String componentTheme() {
    return '''
export 'app_theme_extensions.dart';
''';
  }

  static String theme({required bool useGradient}) {
    final gradientImport =
        useGradient ? "import '../tokens/app_gradients.dart';\n" : '';
    final gradientField = useGradient
        ? '\n  static const Gradient primaryGradient = AppGradients.primary;\n'
        : '';
    final gradientNote = useGradient
        ? '\n  /// Gradients available via AppGradients (see app_gradients.dart).'
        : '';
    return '''
import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
$gradientImport
import 'app_theme_extensions.dart';
/// App-wide ThemeData (light + dark).$gradientNote
class AppTheme {
  AppTheme._();
$gradientField
  static List<ThemeExtension<dynamic>> get _lightExtensions => <ThemeExtension<dynamic>>[
        AppSurfaceTheme.light,
        AppShadowTheme.light,
        AppBlurTheme.tokens,
        AppBorderTheme.light,
        AppMotionTheme.tokens,
        AppComponentTheme.tokens,
      ];

  static List<ThemeExtension<dynamic>> get _darkExtensions => <ThemeExtension<dynamic>>[
        AppSurfaceTheme.dark,
        AppShadowTheme.dark,
        AppBlurTheme.tokens,
        AppBorderTheme.dark,
        AppMotionTheme.tokens,
        AppComponentTheme.tokens,
      ];

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: AppColors.onPrimary,
          outline: AppColors.outline,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: const TextTheme(
          headlineLarge: AppTypography.display,
          headlineMedium: AppTypography.headline,
          headlineSmall: AppTypography.title,
          bodyMedium: AppTypography.body,
          bodySmall: AppTypography.caption,
          labelLarge: AppTypography.button,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle: AppTypography.button,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        extensions: _lightExtensions,
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColorsDark.primary,
          onPrimary: AppColorsDark.onPrimary,
          secondary: AppColorsDark.secondary,
          onSecondary: AppColorsDark.onSecondary,
          surface: AppColorsDark.surface,
          onSurface: AppColorsDark.textPrimary,
          error: AppColorsDark.error,
          onError: AppColorsDark.onPrimary,
          outline: AppColorsDark.outline,
        ),
        scaffoldBackgroundColor: AppColorsDark.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColorsDark.surface,
          foregroundColor: AppColorsDark.textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        extensions: _darkExtensions,
      );
}
''';
  }
}
