import 'dart:io';

import 'package:interact/interact.dart';
import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/prompts/validators.dart';

class ProjectPrompts {
  /// Collects config interactively. Uses provided values when given.
  static ProjectConfig collect({
    String? providedName,
    String? providedDescription,
    String? providedOrg,
    String? providedBrand,
    required String outputDirectory,
    bool interactive = true,
  }) {
    final name = providedName ??
        (interactive
            ? Input(
                prompt: 'Project name',
                validator: (v) {
                  final err = Validators.projectName(v);
                  if (err != null) throw ValidationError(err);
                  return true;
                },
              ).interact()
            : (throw ArgumentError('Project name is required.')));

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

    return ProjectConfig(
      projectName: name.trim(),
      description: description.trim(),
      organization: org.trim(),
      brandColor: brand.trim(),
      outputDirectory: outputDirectory,
    );
  }

  /// Confirm an action.
  static bool confirm(String question, {bool defaultValue = true}) {
    if (!stdin.hasTerminal) return defaultValue;
    return Confirm(prompt: question, defaultValue: defaultValue).interact();
  }
}
