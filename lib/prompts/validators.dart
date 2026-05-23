import 'package:srik_cli/utils/string_utils.dart';

class Validators {
  static String? projectName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Project name cannot be empty.';
    if (!StringUtils.isValidPackageName(trimmed)) {
      return 'Invalid project name "$input". '
          'Use lowercase letters, numbers, and underscores; '
          'must start with a letter; no Dart reserved words. '
          'Example: my_app';
    }
    return null;
  }

  static String? featureName(String input) {
    final trimmed = StringUtils.toSnakeCase(input.trim());
    if (trimmed.isEmpty) return 'Feature name cannot be empty.';
    if (!StringUtils.isValidPackageName(trimmed)) {
      return 'Invalid feature name "$input". '
          'Use lowercase letters, numbers, and underscores. '
          'Example: user_profile';
    }
    return null;
  }

  static String? hexColor(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Color cannot be empty.';
    final pattern = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$');
    if (!pattern.hasMatch(trimmed)) {
      return 'Invalid hex color "$input". '
          'Use #RRGGBB or #AARRGGBB (e.g., #6200EE).';
    }
    return null;
  }

  static String? organization(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Organization cannot be empty.';
    if (!RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch(trimmed)) {
      return 'Invalid organization "$input". '
          'Use reverse domain format (e.g., com.example).';
    }
    return null;
  }
}
