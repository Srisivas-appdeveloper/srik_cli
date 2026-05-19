/// String case conversion helpers used in template substitution.
class StringUtils {
  /// `my_app` from `my_app`, `MyApp`, `my-app`, or `my app`.
  static String toSnakeCase(String input) {
    return input
        .replaceAllMapped(
            RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'[\s\-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '')
        .toLowerCase();
  }

  /// `MyApp` from `my_app`.
  static String toPascalCase(String input) {
    final parts = toSnakeCase(input).split('_');
    return parts.map((p) {
      if (p.isEmpty) return '';
      return p[0].toUpperCase() + p.substring(1);
    }).join();
  }

  /// `myApp` from `my_app`.
  static String toCamelCase(String input) {
    final pascal = toPascalCase(input);
    if (pascal.isEmpty) return '';
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  /// `My App` from `my_app`.
  static String toTitleCase(String input) {
    return toSnakeCase(input)
        .split('_')
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }

  /// Checks if a string is a valid Dart package name.
  /// Must be lowercase, alphanumeric + underscores, start with letter,
  /// not a Dart reserved word.
  static bool isValidPackageName(String input) {
    if (input.isEmpty) return false;
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(input)) return false;
    return !_reservedWords.contains(input);
  }

  static const _reservedWords = {
    'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch',
    'class', 'const', 'continue', 'covariant', 'default', 'deferred', 'do',
    'dynamic', 'else', 'enum', 'export', 'extends', 'extension', 'external',
    'factory', 'false', 'final', 'finally', 'for', 'function', 'get', 'hide',
    'if', 'implements', 'import', 'in', 'interface', 'is', 'late', 'library',
    'mixin', 'new', 'null', 'of', 'on', 'operator', 'part', 'rethrow',
    'return', 'set', 'show', 'static', 'super', 'switch', 'sync', 'this',
    'throw', 'true', 'try', 'typedef', 'var', 'void', 'while', 'with',
    'yield', 'test', 'flutter', 'dart',
  };
}
