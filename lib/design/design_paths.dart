import 'package:srik_cli/models/enums.dart';

/// Architecture → design-system folder (relative to `lib/`).
class DesignPaths {
  DesignPaths._();

  static String systemDir(AppArchitecture arch) {
    switch (arch) {
      case AppArchitecture.clean:
      case AppArchitecture.mvvm:
        return 'core/design';
      case AppArchitecture.featureFirst:
        return 'shared/design';
      case AppArchitecture.simple:
        return 'design';
    }
  }

  /// v0.3 token folder. Used for shims and for `srik add` on old projects.
  static String legacyTokenDir(AppArchitecture arch) {
    switch (arch) {
      case AppArchitecture.clean:
      case AppArchitecture.mvvm:
        return 'core/constants';
      case AppArchitecture.featureFirst:
        return 'shared/theme';
      case AppArchitecture.simple:
        return 'theme';
    }
  }

  static String systemDirFromId(String architecture) {
    final arch = AppArchitecture.parse(architecture);
    return systemDir(arch);
  }

  static String legacyTokenDirFromId(String architecture) {
    final arch = AppArchitecture.parse(architecture);
    return legacyTokenDir(arch);
  }
}
