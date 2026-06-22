import 'package:srik_cli/utils/string_utils.dart';

/// Templates for adding a screen (and optional model) to a Simple project.
/// Layout (under lib/):
///   `models/<name>_model.dart`
///   `screens/<name>_screen.dart`
class SimpleAddTemplates {
  static String model(String projectName, String name) {
    final pascal = StringUtils.toPascalCase(name);
    return '''
import 'package:equatable/equatable.dart';

class ${pascal}Model extends Equatable {
  final String id;

  const ${pascal}Model({required this.id});

  @override
  List<Object?> get props => [id];
}
''';
  }

  static String screen(String projectName, String name, String designDir) {
    final pascal = StringUtils.toPascalCase(name);
    final title = StringUtils.toTitleCase(name);
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$projectName/$designDir/app_spacing.dart';
import 'package:$projectName/$designDir/app_text_styles.dart';

class ${pascal}Screen extends ConsumerWidget {
  const ${pascal}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('$title')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Text('$title screen', style: AppTextStyles.h2),
          ),
        ),
      ),
    );
  }
}
''';
  }
}
