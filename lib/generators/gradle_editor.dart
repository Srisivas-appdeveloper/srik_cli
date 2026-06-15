import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/utils/logger.dart';
import 'package:srik_cli/utils/string_utils.dart';

/// Gradle settings for a single product flavor.
class FlavorGradle {
  final String name;
  final String applicationIdSuffix;
  final String versionNameSuffix;
  final String appLabel;

  const FlavorGradle({
    required this.name,
    required this.applicationIdSuffix,
    required this.versionNameSuffix,
    required this.appLabel,
  });

  /// Derive gradle settings from a flavor name and the base app title.
  /// `prod` is treated as the release flavor: no id/version suffix and the
  /// bare app title. Every other flavor gets `.<flavor>` / `-<flavor>` suffixes
  /// and a "<Title> <Flavor>" label.
  factory FlavorGradle.from(String flavor, String title) {
    if (flavor == 'prod') {
      return FlavorGradle(
        name: flavor,
        applicationIdSuffix: '',
        versionNameSuffix: '',
        appLabel: title,
      );
    }
    final label = flavor
        .split('_')
        .map((s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1))
        .join(' ');
    return FlavorGradle(
      name: flavor,
      applicationIdSuffix: '.$flavor',
      versionNameSuffix: '-$flavor',
      appLabel: '$title $label',
    );
  }
}

/// Inserts a `flavorDimensions` + `productFlavors` block into a Flutter-
/// generated Android app gradle file. Handles both the Kotlin DSL
/// (`build.gradle.kts`) and the legacy Groovy DSL (`build.gradle`).
class GradleEditor {
  GradleEditor._();

  static const String _dimension = 'flavor';

  /// Edits `android/app/build.gradle{.kts}` in [config]'s project to add the
  /// product flavors. No-op (with a warning) when there are no flavors, no
  /// gradle file (e.g. `flutter create` was skipped), or the block already
  /// exists. Throws [StateError] if the file exists but has no `android { }`
  /// block to edit.
  static void apply(ProjectConfig config) {
    if (!config.hasFlavors) return;

    final appDir = p.join(config.projectPath, 'android', 'app');
    final kts = File(p.join(appDir, 'build.gradle.kts'));
    final groovy = File(p.join(appDir, 'build.gradle'));

    final File target;
    final bool isKts;
    if (kts.existsSync()) {
      target = kts;
      isKts = true;
    } else if (groovy.existsSync()) {
      target = groovy;
      isKts = false;
    } else {
      Logger.warn(
        'No android/app/build.gradle{.kts} found — skipping Android flavor '
        'setup. Run `flutter create .` then re-run, or add flavors manually.',
      );
      return;
    }

    final original = target.readAsStringSync();
    if (original.contains('productFlavors')) {
      Logger.warn(
        'android/app/${p.basename(target.path)} already defines '
        'productFlavors — leaving it untouched.',
      );
      return;
    }

    final title = StringUtils.toTitleCase(config.projectName);
    final flavors =
        config.flavors.map((f) => FlavorGradle.from(f, title)).toList();

    final updated = injectProductFlavors(
      original,
      isKts: isKts,
      flavors: flavors,
    );
    target.writeAsStringSync(updated);
    Logger.info('Added Android product flavors to ${p.basename(target.path)}');
  }

  /// Rewrites `android/app/src/main/AndroidManifest.xml` so the app label
  /// reads from the per-flavor `app_name` string resource (defined via
  /// `resValue` in [apply]) instead of a hard-coded value. Without this, the
  /// `resValue` entries are inert and every flavor shows the same name.
  ///
  /// No-op (with a warning) when there are no flavors or the manifest is
  /// missing. Idempotent. Throws [StateError] if the manifest exists but has
  /// no `android:label` attribute to edit.
  static void applyManifest(ProjectConfig config) {
    if (!config.hasFlavors) return;

    final manifest = File(p.join(config.projectPath, 'android', 'app', 'src',
        'main', 'AndroidManifest.xml'));
    if (!manifest.existsSync()) {
      Logger.warn(
        'No AndroidManifest.xml found — skipping per-flavor app label wiring.',
      );
      return;
    }

    final original = manifest.readAsStringSync();
    final updated = setAppLabelToResource(original);
    if (updated == original) return; // already wired
    manifest.writeAsStringSync(updated);
    Logger.info('Wired AndroidManifest.xml label to @string/app_name');
  }

  /// Pure transform: replaces the `android:label="..."` attribute value with
  /// `@string/app_name`. Exposed for testing. Throws [StateError] when the
  /// attribute is absent. Idempotent — re-running on an already-wired manifest
  /// returns it unchanged.
  static String setAppLabelToResource(String manifest) {
    final re = RegExp(r'android:label="[^"]*"');
    if (!re.hasMatch(manifest)) {
      throw StateError(
        'Could not find an android:label attribute in AndroidManifest.xml.',
      );
    }
    return manifest.replaceFirst(re, 'android:label="@string/app_name"');
  }

  /// Pure transform: returns [content] with the flavors block inserted just
  /// before the closing brace of the `android { }` block. Exposed for testing.
  static String injectProductFlavors(
    String content, {
    required bool isKts,
    required List<FlavorGradle> flavors,
  }) {
    final match = RegExp(r'android\s*\{').firstMatch(content);
    if (match == null) {
      throw StateError(
        'Could not find an `android { }` block in the gradle file.',
      );
    }

    final openBrace = content.indexOf('{', match.start);
    final closeBrace = _matchingBrace(content, openBrace);
    if (closeBrace == -1) {
      throw StateError(
        'Unbalanced braces in `android { }` block — refusing to edit.',
      );
    }

    final block = isKts ? _ktsBlock(flavors) : _groovyBlock(flavors);
    // Insert before the android block's closing brace, with a blank line of
    // separation on each side.
    return '${content.substring(0, closeBrace)}\n$block\n${content.substring(closeBrace)}';
  }

  /// Returns the index of the `}` matching the `{` at [open], or -1.
  static int _matchingBrace(String content, int open) {
    var depth = 0;
    for (var i = open; i < content.length; i++) {
      final ch = content[i];
      if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return -1;
  }

  static String _ktsBlock(List<FlavorGradle> flavors) {
    final buf = StringBuffer()
      ..writeln('    // Build flavors (added by srik_cli).')
      ..writeln('    flavorDimensions += "$_dimension"')
      ..writeln()
      ..writeln('    productFlavors {');
    for (final f in flavors) {
      buf.writeln('        create("${f.name}") {');
      buf.writeln('            dimension = "$_dimension"');
      if (f.applicationIdSuffix.isNotEmpty) {
        buf.writeln('            applicationIdSuffix = "${f.applicationIdSuffix}"');
      }
      if (f.versionNameSuffix.isNotEmpty) {
        buf.writeln('            versionNameSuffix = "${f.versionNameSuffix}"');
      }
      buf.writeln('            resValue("string", "app_name", "${f.appLabel}")');
      buf.writeln('        }');
    }
    buf.write('    }');
    return buf.toString();
  }

  static String _groovyBlock(List<FlavorGradle> flavors) {
    final buf = StringBuffer()
      ..writeln('    // Build flavors (added by srik_cli).')
      ..writeln('    flavorDimensions "$_dimension"')
      ..writeln()
      ..writeln('    productFlavors {');
    for (final f in flavors) {
      buf.writeln('        ${f.name} {');
      buf.writeln('            dimension "$_dimension"');
      if (f.applicationIdSuffix.isNotEmpty) {
        buf.writeln('            applicationIdSuffix "${f.applicationIdSuffix}"');
      }
      if (f.versionNameSuffix.isNotEmpty) {
        buf.writeln('            versionNameSuffix "${f.versionNameSuffix}"');
      }
      buf.writeln('            resValue "string", "app_name", "${f.appLabel}"');
      buf.writeln('        }');
    }
    buf.write('    }');
    return buf.toString();
  }
}
