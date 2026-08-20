import 'package:srik_cli/design/color_math.dart';
import 'package:srik_cli/design/style_recipe.dart';
import 'package:srik_cli/models/enums.dart';
import 'package:srik_cli/models/project_config.dart';

/// Fully computed token values for one generated project.
class DesignTokens {
  final StyleRecipe recipe;
  final ArgbPalette light;
  final ArgbPalette dark;
  final List<double> spacing;
  final Argb gradientEnd;

  const DesignTokens({
    required this.recipe,
    required this.light,
    required this.dark,
    required this.spacing,
    required this.gradientEnd,
  });

  factory DesignTokens.fromConfig(ProjectConfig config) {
    return TokenBuilder.build(config);
  }
}

class ArgbPalette {
  final Argb primary;
  final Argb onPrimary;
  final Argb secondary;
  final Argb onSecondary;
  final Argb background;
  final Argb surface;
  final Argb surfaceVariant;
  final Argb surfaceElevated;
  final Argb surfaceTranslucent;
  final Argb outline;
  final Argb outlineVariant;
  final Argb textPrimary;
  final Argb textSecondary;
  final Argb textDisabled;
  final Argb success;
  final Argb warning;
  final Argb error;
  final Argb info;
  final Argb shadowLight;
  final Argb shadowDark;
  final Argb highlight;
  final Argb scrim;
  final List<Argb> neutrals;

  const ArgbPalette({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceElevated,
    required this.surfaceTranslucent,
    required this.outline,
    required this.outlineVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.shadowLight,
    required this.shadowDark,
    required this.highlight,
    required this.scrim,
    required this.neutrals,
  });
}

/// Style-aware brand → token derivation.
class TokenBuilder {
  TokenBuilder._();

  static DesignTokens build(ProjectConfig config) {
    final recipe = StyleRecipe.of(config.designStyle);
    final brand = Argb.parse(config.brandColor);
    final light = _palette(
      brand: brand,
      recipe: recipe,
      dark: false,
    );
    final dark = _palette(
      brand: brand,
      recipe: recipe,
      dark: true,
    );
    return DesignTokens(
      recipe: recipe,
      light: light,
      dark: dark,
      spacing: config.spacingScale.scale,
      gradientEnd: _gradientEnd(brand, recipe.style),
    );
  }

  static Argb _gradientEnd(Argb brand, DesignStyle style) {
    switch (style) {
      case DesignStyle.material:
        return ColorMath.rotateHue(brand, 160);
      case DesignStyle.vibrant:
      case DesignStyle.maximalism:
        return ColorMath.rotateHue(ColorMath.saturate(brand, 0.2), 40);
      case DesignStyle.liquidGlass:
        return ColorMath.rotateHue(ColorMath.lighten(brand, 0.12), 24);
      case DesignStyle.glassmorphism:
        return ColorMath.rotateHue(brand, 28);
      default:
        return ColorMath.rotateHue(brand, 32);
    }
  }

  static ArgbPalette _palette({
    required Argb brand,
    required StyleRecipe recipe,
    required bool dark,
  }) {
    final style = recipe.style;
    final primary = _primary(brand, style, dark);
    final onPrimary = ColorMath.contrastingForeground(primary);
    final secondary = _secondary(brand, style, dark);
    final onSecondary = ColorMath.contrastingForeground(secondary);

    late Argb background;
    late Argb surface;
    late Argb surfaceVariant;
    late Argb surfaceElevated;

    switch (style) {
      case DesignStyle.neomorphism:
        background = dark
            ? ColorMath.withLightness(ColorMath.desaturate(brand, 0.45), 0.16)
            : ColorMath.withLightness(ColorMath.desaturate(brand, 0.5), 0.90);
        surface = dark
            ? ColorMath.lighten(background, 0.04)
            : ColorMath.darken(background, 0.03);
        surfaceVariant = dark
            ? ColorMath.lighten(background, 0.07)
            : ColorMath.darken(background, 0.06);
        surfaceElevated = surface;
        break;
      case DesignStyle.minimalism:
        background = dark ? Argb.parse('FF0A0A0A') : Argb.parse('FFFFFFFF');
        surface = dark ? Argb.parse('FF141414') : Argb.parse('FFFAFAFA');
        surfaceVariant = dark ? Argb.parse('FF1F1F1F') : Argb.parse('FFF5F5F5');
        surfaceElevated = dark ? Argb.parse('FF1A1A1A') : Argb.white;
        break;
      case DesignStyle.brutalism:
        background = dark ? Argb.parse('FF111111') : Argb.parse('FFFFFFF4');
        surface = dark ? Argb.parse('FF1A1A1A') : Argb.white;
        surfaceVariant = ColorMath.mix(surface, primary, dark ? 0.18 : 0.08);
        surfaceElevated = surface;
        break;
      case DesignStyle.glassmorphism:
      case DesignStyle.liquidGlass:
        background = dark
            ? ColorMath.withLightness(ColorMath.saturate(brand, 0.1), 0.10)
            : ColorMath.withLightness(ColorMath.saturate(brand, 0.05), 0.92);
        surface = dark
            ? ColorMath.withLightness(brand, 0.18).withAlpha(0x99)
            : ColorMath.mix(Argb.white, brand, 0.12).withAlpha(0x99);
        surfaceVariant = dark
            ? ColorMath.withLightness(brand, 0.22).withAlpha(0xB3)
            : ColorMath.mix(Argb.white, brand, 0.08).withAlpha(0xB3);
        surfaceElevated = dark
            ? ColorMath.lighten(ColorMath.withLightness(brand, 0.22), 0.04)
                .withAlpha(0xCC)
            : ColorMath.mix(Argb.white, brand, 0.06).withAlpha(0xCC);
        break;
      case DesignStyle.claymorphism:
        background = dark
            ? ColorMath.withLightness(ColorMath.desaturate(brand, 0.2), 0.14)
            : ColorMath.withLightness(ColorMath.desaturate(brand, 0.15), 0.93);
        surface = dark
            ? ColorMath.lighten(background, 0.08)
            : ColorMath.mix(Argb.white, brand, 0.12);
        surfaceVariant = ColorMath.mix(surface, brand, 0.08);
        surfaceElevated = ColorMath.lighten(surface, 0.04);
        break;
      case DesignStyle.spatialUi:
        background = dark
            ? ColorMath.withLightness(brand, 0.08)
            : ColorMath.withLightness(ColorMath.desaturate(brand, 0.35), 0.94);
        surface = dark ? ColorMath.withLightness(brand, 0.16) : Argb.white;
        surfaceVariant = dark
            ? ColorMath.withLightness(brand, 0.12)
            : ColorMath.mix(Argb.white, brand, 0.06);
        surfaceElevated = dark ? ColorMath.lighten(surface, 0.06) : Argb.white;
        break;
      case DesignStyle.maximalism:
        background = dark
            ? ColorMath.withLightness(ColorMath.saturate(brand, 0.2), 0.10)
            : ColorMath.withLightness(ColorMath.saturate(brand, 0.15), 0.96);
        surface = dark ? ColorMath.withLightness(brand, 0.16) : Argb.white;
        surfaceVariant = ColorMath.mix(surface, secondary, dark ? 0.25 : 0.12);
        surfaceElevated = ColorMath.mix(surface, primary, dark ? 0.2 : 0.08);
        break;
      case DesignStyle.vibrant:
        background = dark ? Argb.parse('FF0F1115') : Argb.parse('FFFAFAFA');
        surface = dark ? Argb.parse('FF171A21') : Argb.white;
        surfaceVariant = dark ? Argb.parse('FF22262F') : Argb.parse('FFF3F4F6');
        surfaceElevated = dark ? Argb.parse('FF1D222B') : Argb.white;
        break;
      case DesignStyle.skeuomorphism:
        background = dark
            ? ColorMath.withLightness(ColorMath.desaturate(brand, 0.3), 0.12)
            : ColorMath.withLightness(ColorMath.desaturate(brand, 0.4), 0.88);
        surface = dark
            ? ColorMath.lighten(background, 0.08)
            : ColorMath.lighten(background, 0.06);
        surfaceVariant = ColorMath.darken(surface, 0.05);
        surfaceElevated = ColorMath.lighten(surface, 0.04);
        break;
      case DesignStyle.material:
        background = dark ? Argb.parse('FF121212') : Argb.parse('FFFAFAFA');
        surface = dark ? Argb.parse('FF1E1E1E') : Argb.white;
        surfaceVariant = dark ? Argb.parse('FF2C2C2C') : Argb.parse('FFF5F5F5');
        surfaceElevated = dark ? Argb.parse('FF2A2A2A') : Argb.white;
        break;
    }

    final glassAlpha = (recipe.opacity[3] * 255).round().clamp(0, 255);
    final surfaceTranslucent =
        style == DesignStyle.glassmorphism || style == DesignStyle.liquidGlass
            ? surface.withAlpha(glassAlpha)
            : surface.withAlpha(dark ? 0xE6 : 0xF2);

    final bgOpaque = background.opaque;
    final textPrimary = ColorMath.ensureContrast(
      dark ? Argb.parse('FFF5F5F5') : Argb.parse('FF121212'),
      bgOpaque,
    );
    final textSecondary = ColorMath.ensureContrast(
      dark ? Argb.parse('FFB0B0B0') : Argb.parse('FF5C5C5C'),
      bgOpaque,
      min: 3.0,
    );
    final textDisabled = ColorMath.mix(textPrimary, bgOpaque, 0.55);

    final outline = style == DesignStyle.brutalism
        ? (dark ? Argb.white : Argb.black)
        : ColorMath.mix(textPrimary, bgOpaque, dark ? 0.55 : 0.65);
    final outlineVariant = ColorMath.mix(outline, bgOpaque, 0.5);

    final success = dark ? Argb.parse('FF4ADE80') : Argb.parse('FF166534');
    final warning = dark ? Argb.parse('FFFBBF24') : Argb.parse('FF92400E');
    final error = dark ? Argb.parse('FFF87171') : Argb.parse('FFB91C1C');
    final info = dark ? Argb.parse('FF60A5FA') : Argb.parse('FF1D4ED8');

    // Guarantee readable semantic colors on the background.
    final successFg = ColorMath.ensureContrast(success, bgOpaque, min: 3.0);
    final warningFg = ColorMath.ensureContrast(warning, bgOpaque, min: 3.0);
    final errorFg = ColorMath.ensureContrast(error, bgOpaque, min: 3.0);
    final infoFg = ColorMath.ensureContrast(info, bgOpaque, min: 3.0);

    final shadowLight =
        dark ? Argb.white.withAlpha(0x28) : Argb.white.withAlpha(0xCC);
    final shadowDark =
        dark ? Argb.black.withAlpha(0x99) : Argb.black.withAlpha(0x33);
    final highlight = Argb.white.withAlpha(dark ? 0x33 : 0x88);
    final scrim = Argb.black.withAlpha(dark ? 0x99 : 0x66);

    final neutrals = ColorMath.neutralScale(
      lightest: dark ? Argb.parse('FF1A1A1A') : Argb.parse('FFFAFAFA'),
      darkest: dark ? Argb.parse('FFF5F5F5') : Argb.parse('FF171717'),
    );

    return ArgbPalette(
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      background: background.opaque,
      surface: surface.opaque,
      surfaceVariant: surfaceVariant.opaque,
      surfaceElevated: surfaceElevated.opaque,
      surfaceTranslucent: surfaceTranslucent,
      outline: outline,
      outlineVariant: outlineVariant,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textDisabled: textDisabled,
      success: successFg,
      warning: warningFg,
      error: errorFg,
      info: infoFg,
      shadowLight: shadowLight,
      shadowDark: shadowDark,
      highlight: highlight,
      scrim: scrim,
      neutrals: neutrals,
    );
  }

  static Argb _primary(Argb brand, DesignStyle style, bool dark) {
    switch (style) {
      case DesignStyle.vibrant:
      case DesignStyle.maximalism:
        final hot = ColorMath.saturate(brand, 0.18);
        return dark ? ColorMath.lighten(hot, 0.08) : hot;
      case DesignStyle.minimalism:
        final muted = ColorMath.desaturate(brand, 0.25);
        return dark ? ColorMath.lighten(muted, 0.12) : muted;
      case DesignStyle.brutalism:
        return dark
            ? ColorMath.lighten(brand, 0.1)
            : ColorMath.darken(brand, 0.05);
      case DesignStyle.neomorphism:
        return dark ? ColorMath.lighten(brand, 0.1) : brand;
      default:
        return dark ? ColorMath.lighten(brand, 0.08) : brand;
    }
  }

  static Argb _secondary(Argb brand, DesignStyle style, bool dark) {
    switch (style) {
      case DesignStyle.material:
        return dark
            ? ColorMath.rotateHue(ColorMath.lighten(brand, 0.2), 160)
            : Argb.parse('FF03DAC6');
      case DesignStyle.vibrant:
      case DesignStyle.maximalism:
        return ColorMath.rotateHue(ColorMath.saturate(brand, 0.15), 40);
      case DesignStyle.minimalism:
        return ColorMath.withLightness(
            ColorMath.desaturate(brand, 0.55), dark ? 0.55 : 0.35);
      case DesignStyle.claymorphism:
        return ColorMath.rotateHue(ColorMath.withSaturation(brand, 0.45), 25);
      default:
        return ColorMath.rotateHue(brand, 28);
    }
  }
}
