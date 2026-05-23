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

/// Design system presets — each defines a base color palette.
enum DesignPreset {
  material,
  vibrant,
  minimal;

  /// Parse a user-supplied value. Throws [FormatException] on unknown input.
  static DesignPreset parse(String value) {
    switch (value.toLowerCase().trim()) {
      case 'vibrant':
        return DesignPreset.vibrant;
      case 'minimal':
        return DesignPreset.minimal;
      case 'material':
        return DesignPreset.material;
      default:
        throw FormatException(
          'Unknown design preset "$value". '
          'Valid: material, vibrant, minimal.',
        );
    }
  }

  /// Tries to parse but returns null on unknown values.
  static DesignPreset? tryParse(String value) {
    try {
      return parse(value);
    } on FormatException {
      return null;
    }
  }

  String get id {
    switch (this) {
      case DesignPreset.material:
        return 'material';
      case DesignPreset.vibrant:
        return 'vibrant';
      case DesignPreset.minimal:
        return 'minimal';
    }
  }

  String get label {
    switch (this) {
      case DesignPreset.material:
        return 'Material (Google defaults)';
      case DesignPreset.vibrant:
        return 'Vibrant (saturated, startup style)';
      case DesignPreset.minimal:
        return 'Minimal (low contrast, neutral)';
    }
  }
}

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
