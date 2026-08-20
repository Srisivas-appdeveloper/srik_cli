/// Architecture options the CLI can scaffold.
enum AppArchitecture {
  clean,
  mvvm,
  featureFirst,
  simple;

  /// Parse a user-supplied value. Throws [FormatException] on unknown input.
  static AppArchitecture parse(String value) {
    final v = value.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    switch (v) {
      case 'clean':
      case 'cleanarchitecture':
        return AppArchitecture.clean;
      case 'mvvm':
        return AppArchitecture.mvvm;
      case 'featurefirst':
      case 'feature':
        return AppArchitecture.featureFirst;
      case 'simple':
      case 'none':
        return AppArchitecture.simple;
      default:
        throw FormatException(
          'Unknown architecture "$value". '
          'Valid: clean, mvvm, feature-first, simple.',
        );
    }
  }

  /// Tries to parse but returns null on unknown values.
  static AppArchitecture? tryParse(String value) {
    try {
      return parse(value);
    } on FormatException {
      return null;
    }
  }

  String get id {
    switch (this) {
      case AppArchitecture.clean:
        return 'clean';
      case AppArchitecture.mvvm:
        return 'mvvm';
      case AppArchitecture.featureFirst:
        return 'feature-first';
      case AppArchitecture.simple:
        return 'simple';
    }
  }

  String get label {
    switch (this) {
      case AppArchitecture.clean:
        return 'Clean Architecture';
      case AppArchitecture.mvvm:
        return 'MVVM';
      case AppArchitecture.featureFirst:
        return 'Feature-first';
      case AppArchitecture.simple:
        return 'Simple (no architecture)';
    }
  }
}

/// Canonical generated visual styles.
///
/// [DesignPreset] is a compatibility typedef for this enum.
enum DesignStyle {
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

  /// Values accepted by `--design` (canonical ids plus aliases).
  static const List<String> cliValues = [
    'material',
    'vibrant',
    'minimalism',
    'minimal',
    'neomorphism',
    'neoorphism',
    'neuomorphism',
    'skeuomorphism',
    'glassmorphism',
    'claymorphism',
    'maximalism',
    'brutalism',
    'liquid_glass',
    'liquidglass',
    'liquid-glass',
    'spatial_ui',
    'spatialui',
    'spatial-ui',
  ];

  /// Parse a user-supplied value. Aliases are normalized.
  /// Throws [FormatException] on unknown input.
  static DesignStyle parse(String value) {
    final compact = value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\s-]'), '_')
        .replaceAll('_', '');
    switch (compact) {
      case 'material':
        return DesignStyle.material;
      case 'vibrant':
        return DesignStyle.vibrant;
      case 'minimal':
      case 'minimalism':
        return DesignStyle.minimalism;
      case 'neomorphism':
      case 'neoorphism':
      case 'neuomorphism':
        return DesignStyle.neomorphism;
      case 'skeuomorphism':
        return DesignStyle.skeuomorphism;
      case 'glassmorphism':
        return DesignStyle.glassmorphism;
      case 'claymorphism':
        return DesignStyle.claymorphism;
      case 'maximalism':
        return DesignStyle.maximalism;
      case 'brutalism':
        return DesignStyle.brutalism;
      case 'liquidglass':
        return DesignStyle.liquidGlass;
      case 'spatialui':
        return DesignStyle.spatialUi;
      default:
        throw FormatException(
          'Unknown design style "$value". '
          'Valid: material, vibrant, minimalism, neomorphism, '
          'skeuomorphism, glassmorphism, claymorphism, maximalism, '
          'brutalism, liquid_glass, spatial_ui. '
          'Aliases: minimal, liquidglass, spatialui, neoorphism.',
        );
    }
  }

  /// Tries to parse but returns null on unknown values.
  static DesignStyle? tryParse(String value) {
    try {
      return parse(value);
    } on FormatException {
      return null;
    }
  }

  /// Canonical id persisted in srik.yaml and generated code.
  String get id {
    switch (this) {
      case DesignStyle.material:
        return 'material';
      case DesignStyle.vibrant:
        return 'vibrant';
      case DesignStyle.minimalism:
        return 'minimalism';
      case DesignStyle.neomorphism:
        return 'neomorphism';
      case DesignStyle.skeuomorphism:
        return 'skeuomorphism';
      case DesignStyle.glassmorphism:
        return 'glassmorphism';
      case DesignStyle.claymorphism:
        return 'claymorphism';
      case DesignStyle.maximalism:
        return 'maximalism';
      case DesignStyle.brutalism:
        return 'brutalism';
      case DesignStyle.liquidGlass:
        return 'liquid_glass';
      case DesignStyle.spatialUi:
        return 'spatial_ui';
    }
  }

  /// Generated Dart enum member name (`AppDesignStyle.liquidGlass`).
  String get dartName {
    switch (this) {
      case DesignStyle.liquidGlass:
        return 'liquidGlass';
      case DesignStyle.spatialUi:
        return 'spatialUi';
      default:
        return id.replaceAll('_', '');
    }
  }

  String get label {
    switch (this) {
      case DesignStyle.material:
        return 'Material';
      case DesignStyle.vibrant:
        return 'Vibrant';
      case DesignStyle.minimalism:
        return 'Minimalism';
      case DesignStyle.neomorphism:
        return 'Neomorphism';
      case DesignStyle.skeuomorphism:
        return 'Skeuomorphism';
      case DesignStyle.glassmorphism:
        return 'Glassmorphism';
      case DesignStyle.claymorphism:
        return 'Claymorphism';
      case DesignStyle.maximalism:
        return 'Maximalism';
      case DesignStyle.brutalism:
        return 'Brutalism';
      case DesignStyle.liquidGlass:
        return 'Liquid Glass';
      case DesignStyle.spatialUi:
        return 'Spatial UI';
    }
  }

  String get description {
    switch (this) {
      case DesignStyle.material:
        return 'Modern Material 3 appearance with standard Flutter Material behavior.';
      case DesignStyle.vibrant:
        return 'Bright startup-style visual language with stronger color and gradients.';
      case DesignStyle.minimalism:
        return 'Clean, restrained, typography-focused interface with generous whitespace.';
      case DesignStyle.neomorphism:
        return 'Soft extruded and inset surfaces created with paired light and dark shadows.';
      case DesignStyle.skeuomorphism:
        return 'Physical-object cues using depth, highlights, and tactile controls.';
      case DesignStyle.glassmorphism:
        return 'Translucent layered surfaces using blur, tint, borders, and highlights.';
      case DesignStyle.claymorphism:
        return 'Soft inflated shapes, large radii, and playful tactile depth.';
      case DesignStyle.maximalism:
        return 'Expressive typography, bold colors, decorative layering, and energetic hierarchy.';
      case DesignStyle.brutalism:
        return 'Hard borders, strong contrast, blocky type, and offset shadows.';
      case DesignStyle.liquidGlass:
        return 'Fluid translucent surfaces with layered blur, luminous edges, and smooth motion.';
      case DesignStyle.spatialUi:
        return 'Depth-oriented floating surfaces with layered hierarchy and spatial transitions.';
    }
  }
}

/// Legacy name for [DesignStyle]. Existing call sites keep compiling.
typedef DesignPreset = DesignStyle;

/// Spacing scale density.
enum SpacingScale {
  compact,
  normal,
  spacious;

  /// Parse a user-supplied value. Throws [FormatException] on unknown input.
  static SpacingScale parse(String value) {
    switch (value.toLowerCase().trim()) {
      case 'compact':
        return SpacingScale.compact;
      case 'spacious':
        return SpacingScale.spacious;
      case 'normal':
        return SpacingScale.normal;
      default:
        throw FormatException(
          'Unknown spacing scale "$value". '
          'Valid: compact, normal, spacious.',
        );
    }
  }

  /// Tries to parse but returns null on unknown values.
  static SpacingScale? tryParse(String value) {
    try {
      return parse(value);
    } on FormatException {
      return null;
    }
  }

  String get id {
    switch (this) {
      case SpacingScale.compact:
        return 'compact';
      case SpacingScale.normal:
        return 'normal';
      case SpacingScale.spacious:
        return 'spacious';
    }
  }

  String get label {
    switch (this) {
      case SpacingScale.compact:
        return 'Compact (tight spacing)';
      case SpacingScale.normal:
        return 'Normal (balanced)';
      case SpacingScale.spacious:
        return 'Spacious (airy, generous)';
    }
  }

  /// xs, sm, md, lg, xl, xxl values.
  List<double> get scale {
    switch (this) {
      case SpacingScale.compact:
        return [2, 4, 8, 12, 20, 32];
      case SpacingScale.normal:
        return [4, 8, 16, 24, 32, 48];
      case SpacingScale.spacious:
        return [6, 12, 20, 32, 48, 64];
    }
  }
}
