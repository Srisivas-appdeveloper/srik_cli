import 'package:srik_cli/design/style_recipe.dart';
import 'package:srik_cli/models/project_config.dart';

class StyleTemplates {
  StyleTemplates._();

  static String designStyle(ProjectConfig config) {
    final current = config.designStyle.dartName;
    return '''
/// Visual styles supported by the generated design system.
enum AppDesignStyle {
  material,
  vibrant,
  minimalism,
  neomorphism,
  skeuomorphism,
  glassmorphism,
  claymorphism,
  maximalism,
  brutalism,
  liquidGlass,
  spatialUi;

  /// The style this app was generated with.
  static const AppDesignStyle current = AppDesignStyle.$current;

  String get label {
    switch (this) {
      case AppDesignStyle.material:
        return 'Material';
      case AppDesignStyle.vibrant:
        return 'Vibrant';
      case AppDesignStyle.minimalism:
        return 'Minimalism';
      case AppDesignStyle.neomorphism:
        return 'Neomorphism';
      case AppDesignStyle.skeuomorphism:
        return 'Skeuomorphism';
      case AppDesignStyle.glassmorphism:
        return 'Glassmorphism';
      case AppDesignStyle.claymorphism:
        return 'Claymorphism';
      case AppDesignStyle.maximalism:
        return 'Maximalism';
      case AppDesignStyle.brutalism:
        return 'Brutalism';
      case AppDesignStyle.liquidGlass:
        return 'Liquid Glass';
      case AppDesignStyle.spatialUi:
        return 'Spatial UI';
    }
  }
}
''';
  }

  static String designStyleConfig(ProjectConfig config, StyleRecipe recipe) {
    String b(bool v) => v ? 'true' : 'false';
    final useGradients = (!recipe.avoidGradients) &&
        (recipe.prefersGradientButtons || config.useGradient);
    return '''
import 'design_style.dart';

/// Baked recipe for [AppDesignStyle.current].
///
/// Components read these flags instead of switching on the style name in
/// feature screens. Adding a future style should not require screen changes.
class AppStyleConfig {
  AppStyleConfig._();

  static const AppDesignStyle style = AppDesignStyle.current;

  static const bool usesBlur = ${b(recipe.usesBlur)};
  static const bool usesNeoShadows = ${b(recipe.usesNeoShadows)};
  static const bool usesHardOffsetShadow = ${b(recipe.usesHardOffsetShadow)};
  static const bool usesInsetPress = ${b(recipe.usesInsetPress)};
  static const bool usesClayInflation = ${b(recipe.usesClayInflation)};
  static const bool usesSkeuoGradient = ${b(recipe.usesSkeuoGradient)};
  static const bool usesLiquidHighlight = ${b(recipe.usesLiquidHighlight)};
  static const bool usesSpatialDepth = ${b(recipe.usesSpatialDepth)};
  static const bool prefersGradientButtons = ${b(useGradients)};
  static const bool avoidGradients = ${b(recipe.avoidGradients)};
  static const bool reducedTransparencyFallback =
      ${b(recipe.reducedTransparencyFallback)};
}
''';
  }
}
