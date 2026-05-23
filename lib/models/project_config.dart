import 'package:path/path.dart' as p;
import 'package:srik_cli/models/enums.dart';

/// Full configuration for a project being generated.
class ProjectConfig {
  final String projectName;
  final String description;
  final String organization;
  final String outputDirectory;

  final AppArchitecture architecture;
  final DesignPreset designPreset;
  final bool useGradient;
  final SpacingScale spacingScale;
  final String brandColor; // hex like #6200EE

  ProjectConfig({
    required this.projectName,
    required this.description,
    required this.organization,
    required this.outputDirectory,
    required this.architecture,
    required this.designPreset,
    required this.useGradient,
    required this.spacingScale,
    required this.brandColor,
  });

  String get projectPath => p.join(outputDirectory, projectName);

  /// Brand color as a Dart Color literal argument, e.g. 0xFF6200EE.
  /// Accepts #RRGGBB (assumes opaque) or #AARRGGBB (uses given alpha).
  String get brandColorLiteral {
    final hex = brandColor.replaceFirst('#', '').toUpperCase();
    if (hex.length == 6) return '0xFF$hex';
    if (hex.length == 8) return '0x$hex';
    throw FormatException(
      'Invalid brand color "$brandColor". Use #RRGGBB or #AARRGGBB.',
    );
  }
}
