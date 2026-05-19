import 'package:srik_cli/utils/string_utils.dart';

class Validators {
  static String? projectName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Project name cannot be empty.';
    if (!StringUtils.isValidPackageName(trimmed)) {
      return 'Invalid name. Use lowercase letters, numbers, and underscores. '
          'Must start with a letter. No Dart reserved words.';
    }
    return null;
  }

  static String? hexColor(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Color cannot be empty.';
    final pattern = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$');
    if (!pattern.hasMatch(trimmed)) {
      return 'Use format #RRGGBB or #AARRGGBB (e.g., #6200EE).';
    }
    return null;
  }

  static String? organization(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Organization cannot be empty.';
    if (!RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch(trimmed)) {
      return 'Use reverse domain format (e.g., com.example).';
    }
    return null;
  }
}
