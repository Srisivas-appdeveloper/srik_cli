import 'package:srik_cli/utils/string_utils.dart';

/// Templates for a feature added to a Feature-first project.
/// Each feature lives in lib/features/<name>/ with these files:
///   <name>_model.dart, <name>_service.dart, <name>_controller.dart,
///   <name>_screen.dart
class FeatureFirstAddTemplates {
  static String model(String projectName, String feature) {
    final pascal = StringUtils.toPascalCase(feature);
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

  static String service(String projectName, String feature) {
    final pascal = StringUtils.toPascalCase(feature);
    return '''
import 'package:$projectName/features/$feature/${feature}_model.dart';

class ${pascal}Service {
  // TODO: replace this stub with a real data source.
  Future<${pascal}Model> fetch() async {
    return const ${pascal}Model(id: 'placeholder');
  }
}
''';
  }

  static String controller(String projectName, String feature) {
    final pascal = StringUtils.toPascalCase(feature);
    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$projectName/features/$feature/${feature}_model.dart';
import 'package:$projectName/features/$feature/${feature}_service.dart';

final ${feature}ServiceProvider =
    Provider<${pascal}Service>((ref) => ${pascal}Service());

final ${feature}ControllerProvider =
    FutureProvider<${pascal}Model>((ref) async {
  final service = ref.watch(${feature}ServiceProvider);
  return service.fetch();
});
''';
  }

  static String screen(String projectName, String feature, String designDir) {
    final pascal = StringUtils.toPascalCase(feature);
    final title = StringUtils.toTitleCase(feature);
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$projectName/$designDir/app_colors.dart';
import 'package:$projectName/$designDir/app_spacing.dart';
import 'package:$projectName/$designDir/app_text_styles.dart';
import 'package:$projectName/features/$feature/${feature}_controller.dart';

class ${pascal}Screen extends ConsumerWidget {
  const ${pascal}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${feature}ControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('$title')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: state.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Error: \$e',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
            ),
            data: (model) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('$title', style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.sm),
                Text('id: \${model.id}', style: AppTextStyles.body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
''';
  }

  /// A simple screen added inside an existing feature folder.
  static String simpleScreen(
    String projectName,
    String feature,
    String screen,
    String designDir,
  ) {
    final pascal = StringUtils.toPascalCase(screen);
    final title = StringUtils.toTitleCase(screen);
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
