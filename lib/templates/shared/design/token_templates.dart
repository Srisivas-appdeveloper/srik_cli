import 'package:srik_cli/design/color_math.dart';
import 'package:srik_cli/design/token_builder.dart';
import 'package:srik_cli/models/project_config.dart';

/// Generated token source files (identical API across styles; values differ).
class TokenTemplates {
  TokenTemplates._();

  static String _c(Argb c) => 'Color(${c.dartLiteral})';

  static String colors(ProjectConfig config, DesignTokens tokens) {
    String paletteBlock(String className, ArgbPalette p) {
      const steps = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
      final neutrals = <String>[];
      for (var i = 0; i < steps.length; i++) {
        neutrals.add(
          '  static const Color neutral${steps[i]} = ${_c(p.neutrals[i])};',
        );
      }
      return '''
class $className {
  $className._();

  static const Color primary = ${_c(p.primary)};
  static const Color onPrimary = ${_c(p.onPrimary)};
  static const Color secondary = ${_c(p.secondary)};
  static const Color onSecondary = ${_c(p.onSecondary)};
  static const Color background = ${_c(p.background)};
  static const Color surface = ${_c(p.surface)};
  static const Color surfaceVariant = ${_c(p.surfaceVariant)};
  static const Color surfaceElevated = ${_c(p.surfaceElevated)};
  static const Color surfaceTranslucent = ${_c(p.surfaceTranslucent)};
  static const Color outline = ${_c(p.outline)};
  static const Color outlineVariant = ${_c(p.outlineVariant)};
  static const Color textPrimary = ${_c(p.textPrimary)};
  static const Color textSecondary = ${_c(p.textSecondary)};
  static const Color textDisabled = ${_c(p.textDisabled)};
  static const Color textOnPrimary = ${_c(p.onPrimary)};
  static const Color success = ${_c(p.success)};
  static const Color warning = ${_c(p.warning)};
  static const Color error = ${_c(p.error)};
  static const Color info = ${_c(p.info)};
  static const Color shadowLight = ${_c(p.shadowLight)};
  static const Color shadowDark = ${_c(p.shadowDark)};
  static const Color highlight = ${_c(p.highlight)};
  static const Color scrim = ${_c(p.scrim)};
  static const Color overlay = Color(0x80000000);

${neutrals.join('\n')}
}
''';
    }

    return '''
import 'package:flutter/material.dart';

/// Semantic color tokens.
/// Style: ${config.designStyle.id}. Brand: ${config.brandColor}.
${paletteBlock('AppColors', tokens.light)}
/// Dark-mode semantic color tokens.
${paletteBlock('AppColorsDark', tokens.dark)}
''';
  }

  static String spacing(ProjectConfig config, DesignTokens tokens) {
    final v = tokens.spacing;
    return '''
/// Spacing scale. Density: ${config.spacingScale.id}.
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

  static String radius(DesignTokens tokens) {
    final r = tokens.recipe.radius;
    return '''
/// Border radius scale.
class AppRadius {
  AppRadius._();

  static const double none = ${r[0]};
  static const double xs = ${r[1]};
  static const double sm = ${r[2]};
  static const double md = ${r[3]};
  static const double lg = ${r[4]};
  static const double xl = ${r[5]};
  static const double pill = ${r[6]};
}
''';
  }

  static String typography(DesignTokens tokens) {
    final r = tokens.recipe;
    final weight = r.boldHeadlines ? 'FontWeight.w700' : 'FontWeight.w500';
    return '''
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography scale. Prefer this over hard-coded font sizes.
class AppTypography {
  AppTypography._();

  static const TextStyle display = TextStyle(
    fontSize: ${r.displaySize},
    fontWeight: $weight,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headline = TextStyle(
    fontSize: ${r.headlineSize},
    fontWeight: $weight,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle title = TextStyle(
    fontSize: ${r.titleSize},
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: ${r.bodySize},
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: ${r.bodySize},
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontSize: ${r.labelSize},
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: ${r.captionSize},
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: ${r.labelSize},
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}

/// Legacy alias used by older generated screens.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle h1 = AppTypography.display;
  static const TextStyle h2 = AppTypography.headline;
  static const TextStyle h3 = AppTypography.title;
  static const TextStyle body = AppTypography.body;
  static const TextStyle bodyBold = AppTypography.bodyBold;
  static const TextStyle caption = AppTypography.caption;
  static const TextStyle button = AppTypography.button;
}
''';
  }

  static String shadows(DesignTokens tokens) {
    final r = tokens.recipe;
    return '''
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shadow recipes. Prefer [AppShadowTheme] from the current [ThemeData].
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get flat => const <BoxShadow>[];

  static const List<BoxShadow> low = <BoxShadow>[
        BoxShadow(
          color: AppColors.shadowDark,
          offset: Offset(0, ${r.shadowOffset}),
          blurRadius: ${r.shadowBlur},
          spreadRadius: ${r.shadowSpread},
        ),
      ];

  static const List<BoxShadow> medium = <BoxShadow>[
        BoxShadow(
          color: AppColors.shadowDark,
          offset: Offset(0, ${r.shadowOffset + 2}),
          blurRadius: ${r.shadowBlur + 4},
          spreadRadius: ${r.shadowSpread},
        ),
      ];

  static const List<BoxShadow> high = <BoxShadow>[
        BoxShadow(
          color: AppColors.shadowDark,
          offset: Offset(0, ${r.shadowOffset + 4}),
          blurRadius: ${r.shadowBlur + 10},
          spreadRadius: ${r.shadowSpread},
        ),
      ];

  static const List<BoxShadow> floating = high;

  static const List<BoxShadow> neoRaised = <BoxShadow>[
        BoxShadow(
          color: AppColors.shadowLight,
          offset: Offset(-${r.neoOffset}, -${r.neoOffset}),
          blurRadius: ${r.neoBlur},
        ),
        BoxShadow(
          color: AppColors.shadowDark,
          offset: Offset(${r.neoOffset}, ${r.neoOffset}),
          blurRadius: ${r.neoBlur},
        ),
      ];

  static const List<BoxShadow> neoInset = <BoxShadow>[
        BoxShadow(
          color: AppColors.shadowDark,
          offset: Offset(${r.neoOffset / 2}, ${r.neoOffset / 2}),
          blurRadius: ${r.neoBlur / 2},
        ),
        BoxShadow(
          color: AppColors.shadowLight,
          offset: Offset(-${r.neoOffset / 2}, -${r.neoOffset / 2}),
          blurRadius: ${r.neoBlur / 2},
        ),
      ];

  static const List<BoxShadow> hardOffset = <BoxShadow>[
        BoxShadow(
          color: AppColors.textPrimary,
          offset: Offset(${r.hardShadowOffset}, ${r.hardShadowOffset}),
          blurRadius: 0,
        ),
      ];

  static const List<BoxShadow> clay = <BoxShadow>[
        BoxShadow(
          color: AppColors.shadowDark,
          offset: Offset(0, ${r.shadowOffset}),
          blurRadius: ${r.shadowBlur},
          spreadRadius: ${r.shadowSpread},
        ),
        BoxShadow(
          color: AppColors.shadowLight,
          offset: Offset(0, -${r.shadowOffset / 2}),
          blurRadius: ${r.shadowBlur / 2},
        ),
      ];
}
''';
  }

  static String blur(DesignTokens tokens) {
    final b = tokens.recipe.blur;
    return '''
/// Blur sigma tokens. Apply only inside reusable primitives.
class AppBlur {
  AppBlur._();

  static const double none = ${b[0]};
  static const double subtle = ${b[1]};
  static const double small = ${b[2]};
  static const double medium = ${b[3]};
  static const double large = ${b[4]};
  static const double intense = ${b[5]};
}
''';
  }

  static String borders(DesignTokens tokens) {
    final r = tokens.recipe;
    return '''
/// Border-width tokens.
class AppBorders {
  AppBorders._();

  static const double none = 0;
  static const double thin = ${r.borderThin};
  static const double regular = ${r.borderRegular};
  static const double bold = ${r.borderBold};
}
''';
  }

  static String opacity(DesignTokens tokens) {
    final o = tokens.recipe.opacity;
    return '''
/// Opacity tokens.
class AppOpacity {
  AppOpacity._();

  static const double disabled = ${o[0]};
  static const double subtle = ${o[1]};
  static const double surface = ${o[2]};
  static const double glass = ${o[3]};
  static const double overlay = ${o[4]};
  static const double scrim = ${o[5]};
}
''';
  }

  static String elevation(DesignTokens tokens) {
    final e = tokens.recipe.elevation;
    return '''
/// Logical elevation tokens.
class AppElevation {
  AppElevation._();

  static const double flat = ${e[0]};
  static const double low = ${e[1]};
  static const double medium = ${e[2]};
  static const double high = ${e[3]};
  static const double floating = ${e[4]};
}
''';
  }

  static String motion(DesignTokens tokens) {
    final m = tokens.recipe.motionMs;
    return '''
import 'package:flutter/material.dart';

/// Motion tokens.
class AppMotion {
  AppMotion._();

  static const Duration instant = Duration(milliseconds: ${m[0]});
  static const Duration fast = Duration(milliseconds: ${m[1]});
  static const Duration normal = Duration(milliseconds: ${m[2]});
  static const Duration slow = Duration(milliseconds: ${m[3]});
  static const Duration emphasized = Duration(milliseconds: ${m[4]});

  static const Curve standardCurve = Curves.easeInOut;
  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
}

/// Legacy alias.
class AppDurations {
  AppDurations._();

  static const Duration fast = AppMotion.fast;
  static const Duration normal = AppMotion.normal;
  static const Duration slow = AppMotion.slow;
}
''';
  }

  static String sizes() {
    return '''
/// Sizing tokens, including accessible tap targets.
class AppSizes {
  AppSizes._();

  static const double minTapTarget = 48;
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double navBarHeight = 64;
  static const double badgeSize = 20;
}
''';
  }

  static String gradients(ProjectConfig config, DesignTokens tokens) {
    return '''
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brand-derived gradients.
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AppColors.primary,
      Color(${tokens.gradientEnd.dartLiteral}),
    ],
  );

  static const LinearGradient subtle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      AppColors.surface,
      AppColors.background,
    ],
  );

  static const LinearGradient skeuo = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      AppColors.highlight,
      AppColors.surface,
      AppColors.surfaceVariant,
    ],
  );

  static const LinearGradient liquid = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AppColors.highlight,
      AppColors.surfaceTranslucent,
      AppColors.primary,
    ],
  );

  static const RadialGradient glow = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.2,
    colors: <Color>[
      AppColors.primary,
      Color(${tokens.gradientEnd.dartLiteral}),
    ],
  );
}
''';
  }
}
