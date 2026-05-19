import 'package:path/path.dart' as p;

/// Configuration collected from user input or flags before generation.
class ProjectConfig {
  final String projectName;
  final String description;
  final String organization;
  final String brandColor;
  final String outputDirectory;

  ProjectConfig({
    required this.projectName,
    required this.description,
    required this.organization,
    required this.brandColor,
    required this.outputDirectory,
  });

  String get projectPath => p.join(outputDirectory, projectName);
}
