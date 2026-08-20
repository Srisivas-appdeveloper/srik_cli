import 'dart:io';

import 'package:interact/interact.dart';
import 'package:srik_cli/models/enums.dart';
import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/prompts/validators.dart';

class ProjectPrompts {
  /// Collects full project configuration. Uses provided values where given,
  /// prompts interactively for the rest.
  static ProjectConfig collect({
    required String projectName,
    String? providedDescription,
    String? providedOrg,
    String? providedBrand,
    String? providedArch,
    String? providedDesign,
    bool? providedGradient,
    String? providedSpacing,
    String? providedFlavors,
    required String outputDirectory,
    bool interactive = true,
  }) {
    final description = providedDescription ??
        (interactive
            ? Input(
                prompt: 'Description',
                defaultValue: 'A new Flutter app',
              ).interact()
            : 'A new Flutter app');

    final org = providedOrg ??
        (interactive
            ? Input(
                prompt: 'Organization',
                defaultValue: 'com.example',
                validator: (v) {
                  final err = Validators.organization(v);
                  if (err != null) throw ValidationError(err);
                  return true;
                },
              ).interact()
            : 'com.example');

    // Architecture
    final AppArchitecture architecture;
    if (providedArch != null) {
      architecture = AppArchitecture.parse(providedArch);
    } else if (interactive) {
      final options = AppArchitecture.values;
      final index = Select(
        prompt: 'Architecture',
        options: options.map((a) => a.label).toList(),
      ).interact();
      architecture = options[index];
    } else {
      architecture = AppArchitecture.clean;
    }

    // Design style
    final DesignStyle designPreset;
    if (providedDesign != null) {
      designPreset = DesignStyle.parse(providedDesign);
    } else if (interactive) {
      final options = DesignStyle.values;
      final index = Select(
        prompt: 'Choose a design style',
        options: options.map((d) => d.label).toList(),
      ).interact();
      designPreset = options[index];
    } else {
      designPreset = DesignStyle.material;
    }

    // Gradient
    final useGradient = providedGradient ??
        (interactive
            ? Confirm(
                prompt: 'Add gradient theme support?',
                defaultValue: false,
              ).interact()
            : false);

    // Spacing scale
    final SpacingScale spacingScale;
    if (providedSpacing != null) {
      spacingScale = SpacingScale.parse(providedSpacing);
    } else if (interactive) {
      final options = SpacingScale.values;
      final index = Select(
        prompt: 'Spacing scale',
        options: options.map((s) => s.label).toList(),
      ).interact();
      spacingScale = options[index];
    } else {
      spacingScale = SpacingScale.normal;
    }

    // Brand color
    final brand = providedBrand ??
        (interactive
            ? Input(
                prompt: 'Brand color (hex)',
                defaultValue: '#6200EE',
                validator: (v) {
                  final err = Validators.hexColor(v);
                  if (err != null) throw ValidationError(err);
                  return true;
                },
              ).interact()
            : '#6200EE');

    // Flavors
    final List<String> flavors;
    if (providedFlavors != null && providedFlavors.trim().isNotEmpty) {
      flavors = Validators.parseFlavors(providedFlavors);
    } else if (interactive) {
      final answer = Input(
        prompt: 'Add build flavors? (dev,staging,prod / none)',
        defaultValue: 'none',
        validator: (v) {
          final t = v.trim();
          if (t.isEmpty || t.toLowerCase() == 'none') return true;
          final err = Validators.flavors(t);
          if (err != null) throw ValidationError(err);
          return true;
        },
      ).interact();
      final t = answer.trim();
      flavors = (t.isEmpty || t.toLowerCase() == 'none')
          ? const []
          : Validators.parseFlavors(t);
    } else {
      flavors = const [];
    }

    return ProjectConfig(
      projectName: projectName.trim(),
      description: description.trim(),
      organization: org.trim(),
      outputDirectory: outputDirectory,
      architecture: architecture,
      designPreset: designPreset,
      useGradient: useGradient,
      spacingScale: spacingScale,
      brandColor: brand.trim(),
      flavors: flavors,
    );
  }

  static bool confirm(String question, {bool defaultValue = true}) {
    if (!stdin.hasTerminal) return defaultValue;
    return Confirm(prompt: question, defaultValue: defaultValue).interact();
  }
}
