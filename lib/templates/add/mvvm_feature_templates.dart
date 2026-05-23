import 'package:srik_cli/utils/string_utils.dart';

/// Templates for a feature added to an MVVM project.
/// Layout (under lib/):
///   models/<name>_model.dart
///   services/<name>_service.dart
///   viewmodels/<name>_viewmodel.dart
///   views/<name>_view.dart
class MvvmFeatureTemplates {
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
import 'package:$projectName/models/${feature}_model.dart';

class ${pascal}Service {
  // TODO: replace this stub with a real data source (Dio, local DB, etc.).
  Future<${pascal}Model> fetch() async {
    return const ${pascal}Model(id: 'placeholder');
  }
}
''';
  }

  static String viewmodel(String projectName, String feature) {
    final pascal = StringUtils.toPascalCase(feature);
    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$projectName/models/${feature}_model.dart';
import 'package:$projectName/services/${feature}_service.dart';

final ${feature}ServiceProvider =
    Provider<${pascal}Service>((ref) => ${pascal}Service());

final ${feature}ViewModelProvider =
    FutureProvider<${pascal}Model>((ref) async {
  final service = ref.watch(${feature}ServiceProvider);
  return service.fetch();
});
''';
  }

  static String view(String projectName, String feature, String designDir) {
    final pascal = StringUtils.toPascalCase(feature);
    final title = StringUtils.toTitleCase(feature);
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$projectName/$designDir/app_colors.dart';
import 'package:$projectName/$designDir/app_spacing.dart';
import 'package:$projectName/$designDir/app_text_styles.dart';
import 'package:$projectName/viewmodels/${feature}_viewmodel.dart';

class ${pascal}View extends ConsumerWidget {
  const ${pascal}View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${feature}ViewModelProvider);

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

  /// Single-screen view (used by `srik add screen`).
  static String screen(
    String projectName,
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

class ${pascal}View extends ConsumerWidget {
  const ${pascal}View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('$title')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Text('$title view', style: AppTextStyles.h2),
          ),
        ),
      ),
    );
  }
}
''';
  }
}
