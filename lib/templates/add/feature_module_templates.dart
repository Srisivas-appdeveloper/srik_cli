import 'package:srik_cli/utils/string_utils.dart';

/// Templates for a feature module added via `srik add feature`
/// to a Clean Architecture project. Uses package imports.
class FeatureModuleTemplates {
  static String entity(String projectName, String feature) {
    final pascal = StringUtils.toPascalCase(feature);
    return '''
import 'package:equatable/equatable.dart';

/// Pure domain entity for the $feature feature.
class ${pascal}Entity extends Equatable {
  final String id;

  const ${pascal}Entity({required this.id});

  @override
  List<Object?> get props => [id];
}
''';
  }

  static String repository(String projectName, String feature) {
    final pascal = StringUtils.toPascalCase(feature);
    return '''
import 'package:dartz/dartz.dart';
import 'package:$projectName/core/error/failures.dart';
import 'package:$projectName/features/$feature/domain/entities/${feature}_entity.dart';

abstract class ${pascal}Repository {
  Future<Either<Failure, ${pascal}Entity>> get$pascal();
}
''';
  }

  static String repositoryImpl(String projectName, String feature) {
    final pascal = StringUtils.toPascalCase(feature);
    return '''
import 'package:dartz/dartz.dart';
import 'package:$projectName/core/error/failures.dart';
import 'package:$projectName/features/$feature/domain/entities/${feature}_entity.dart';
import 'package:$projectName/features/$feature/domain/repositories/${feature}_repository.dart';

class ${pascal}RepositoryImpl implements ${pascal}Repository {
  @override
  Future<Either<Failure, ${pascal}Entity>> get$pascal() async {
    // TODO: replace this stub with a real data source (Dio, local DB, etc.).
    try {
      return const Right(${pascal}Entity(id: 'placeholder'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
''';
  }

  static String provider(String projectName, String feature) {
    final pascal = StringUtils.toPascalCase(feature);
    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$projectName/features/$feature/data/repositories/${feature}_repository_impl.dart';
import 'package:$projectName/features/$feature/domain/entities/${feature}_entity.dart';
import 'package:$projectName/features/$feature/domain/repositories/${feature}_repository.dart';

final ${feature}RepositoryProvider = Provider<${pascal}Repository>((ref) {
  return ${pascal}RepositoryImpl();
});

final ${feature}Provider = FutureProvider<${pascal}Entity>((ref) async {
  final repo = ref.watch(${feature}RepositoryProvider);
  final result = await repo.get$pascal();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (entity) => entity,
  );
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
import 'package:$projectName/features/$feature/presentation/providers/${feature}_provider.dart';

class ${pascal}Screen extends ConsumerWidget {
  const ${pascal}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(${feature}Provider);

    return Scaffold(
      appBar: AppBar(title: const Text('$title')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: asyncValue.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Error: \$e',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
            ),
            data: (entity) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('$title', style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.sm),
                Text('id: \${entity.id}', style: AppTextStyles.body),
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
}
