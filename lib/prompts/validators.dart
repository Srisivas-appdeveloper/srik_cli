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

  /// Validates a single flavor name. Must be lowercase, alphanumeric +
  /// underscores, start with a letter, and not be a reserved word
  /// (`main`, `test`, or a Dart keyword) — flavor names become Dart enum
  /// constants and Gradle product flavors.
  static String? flavorName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Flavor name cannot be empty.';
    if (!StringUtils.isValidPackageName(trimmed) || trimmed == 'main') {
      return 'Invalid flavor "$input". '
          'Use lowercase letters, numbers, and underscores; '
          'must start with a letter; not a reserved word (main, test). '
          'Example: dev';
    }
    return null;
  }

  /// Splits a comma-separated flavors string into a trimmed, non-empty list.
  static List<String> parseFlavors(String input) => input
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  /// Validates a comma-separated flavors string (e.g. `dev,staging,prod`).
  /// Returns null when valid, or an error message describing the first
  /// problem found (invalid name, duplicate, or reserved word).
  static String? flavors(String input) {
    final parts = parseFlavors(input);
    if (parts.isEmpty) {
      return 'Provide at least one flavor, e.g. dev,staging,prod.';
    }
    final seen = <String>{};
    for (final part in parts) {
      final err = flavorName(part);
      if (err != null) return err;
      if (!seen.add(part)) return 'Duplicate flavor "$part".';
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
