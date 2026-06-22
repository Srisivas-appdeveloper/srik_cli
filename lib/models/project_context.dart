import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Loaded from srik.yaml in an existing project root.
/// Used by `srik add` commands to know how to generate code.
class ProjectContext {
  final String projectName;
  final String architecture;
  final String stateManagement;
  final String routing;
  final String storage;
  final String network;
  final String brandColor;
  final String designPreset;
  final bool useGradient;
  final String spacingScale;
  final List<String> flavors;
  final List<String> features;
  final String projectRoot;

  ProjectContext({
    required this.projectName,
    required this.architecture,
    required this.stateManagement,
    required this.routing,
    required this.storage,
    required this.network,
    required this.brandColor,
    required this.designPreset,
    required this.useGradient,
    required this.spacingScale,
    required this.flavors,
    required this.features,
    required this.projectRoot,
  });

  /// Search up from [startDir] for a `srik.yaml` and load it.
  /// Returns null if no config is found.
  static ProjectContext? load(String startDir) {
    var current = Directory(startDir).absolute;
    while (true) {
      final yamlFile = File(p.join(current.path, 'srik.yaml'));
      if (yamlFile.existsSync()) {
        return _parse(yamlFile, current.path);
      }
      final parent = current.parent;
      if (parent.path == current.path) {
        return null;
      }
      current = parent;
    }
  }

  static ProjectContext _parse(File file, String projectRoot) {
    final doc = loadYaml(file.readAsStringSync()) as YamlMap;

    final designSystem = doc['design_system'] as YamlMap?;
    final featuresRaw = doc['features'] as YamlList?;
    final features = featuresRaw == null
        ? <String>[]
        : featuresRaw.map((e) => e.toString()).toList();
    final flavorsRaw = doc['flavors'] as YamlList?;
    final flavors = flavorsRaw == null
        ? <String>[]
        : flavorsRaw.map((e) => e.toString()).toList();

    return ProjectContext(
      projectName: doc['project_name']?.toString() ?? 'app',
      architecture: doc['architecture']?.toString() ?? 'clean',
      stateManagement: doc['state_management']?.toString() ?? 'riverpod',
      routing: doc['routing']?.toString() ?? 'go_router',
      storage: doc['storage']?.toString() ?? 'shared_preferences',
      network: doc['network']?.toString() ?? 'dio',
      brandColor: designSystem?['brand_color']?.toString() ?? '#6200EE',
      designPreset: designSystem?['preset']?.toString() ?? 'material',
      useGradient: designSystem?['gradient'] == true,
      spacingScale: designSystem?['spacing']?.toString() ?? 'normal',
      flavors: flavors,
      features: features,
      projectRoot: projectRoot,
    );
  }

  /// Persist an updated features list back to srik.yaml.
  ///
  /// Strategy: parse the YAML, mutate the in-memory model, and rewrite the
  /// file using the same template format we emit on `create`. We do not try
  /// to preserve user-added comments — srik.yaml is a managed config file.
  void appendFeature(String featureName) {
    if (features.contains(featureName)) return;
    features.add(featureName);
    save();
  }

  /// Rewrite srik.yaml from this context's current state.
  void save() {
    final file = File(p.join(projectRoot, 'srik.yaml'));
    file.writeAsStringSync(_render());
  }

  String _render() {
    final buf = StringBuffer()
      ..writeln('# srik_cli configuration. Used by `srik add` commands.')
      ..writeln('# This file is managed by srik. Edit the fields below;')
      ..writeln('# user-added comments will not be preserved on regeneration.')
      ..writeln('version: 0.3.0')
      ..writeln('project_name: $projectName')
      ..writeln('architecture: $architecture')
      ..writeln('state_management: $stateManagement')
      ..writeln('routing: $routing')
      ..writeln('storage: $storage')
      ..writeln('network: $network')
      ..writeln('design_system:')
      ..writeln('  preset: $designPreset')
      ..writeln('  gradient: $useGradient')
      ..writeln('  spacing: $spacingScale')
      ..writeln('  brand_color: "$brandColor"');
    if (flavors.isNotEmpty) {
      buf.writeln('flavors:');
      for (final flavor in flavors) {
        buf.writeln('  - $flavor');
      }
    }
    buf.writeln('features:');
    for (final f in features) {
      buf.writeln('  - $f');
    }
    return buf.toString();
  }
}
