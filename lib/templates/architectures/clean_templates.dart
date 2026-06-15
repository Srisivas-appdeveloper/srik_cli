import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/templates/shared/snippets.dart';
import 'package:srik_cli/utils/string_utils.dart';

/// Clean Architecture template set.
/// Design files live in lib/core/constants/ (written separately).
class CleanTemplates {
  /// Folder (relative to lib/) where design system files are placed.
  static const String designDir = 'core/constants';

  /// Folder (relative to lib/) where flavor config is placed.
  static const String configDir = 'core/config';

  /// Storage import used by the entry point (Clean initializes prefs).
  static const String _storageImport = 'core/storage/local_storage.dart';

  static Map<String, String> files(ProjectConfig c) {
    final name = c.projectName;
    final title = StringUtils.toTitleCase(name);
    final configImport = c.hasFlavors ? '$configDir/app_config.dart' : null;

    final files = <String, String>{
      'lib/main.dart': c.hasFlavors
          ? Snippets.flavorEntryPoint(
              name: name,
              flavor: c.flavors.first,
              configImport: configImport!,
              storageImport: _storageImport,
            )
          : Snippets.mainDart(name, storageImport: _storageImport),
      'lib/app.dart': Snippets.appWidget(
        name: name,
        title: title,
        themeImport: 'core/constants/app_theme.dart',
        routerImport: 'core/router/app_router.dart',
        configImport: configImport,
      ),
      'lib/core/network/dio_client.dart':
          Snippets.dioClient(name: name, configImport: configImport),
      'lib/core/router/app_router.dart': Snippets.appRouter(
        name: name,
        homeImport: 'features/home/presentation/screens/home_screen.dart',
        homeWidget: 'HomeScreen',
      ),
      'lib/features/home/presentation/screens/home_screen.dart':
          Snippets.homeScreen(
        name: name,
        title: title,
        designDir: designDir,
        className: 'HomeScreen',
        providerName: 'homeWelcomeProvider',
        providerImports: const [
          'features/home/presentation/providers/home_provider.dart',
        ],
      ),
      'lib/core/error/exceptions.dart': '''
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}
''',
      'lib/core/error/failures.dart': '''
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
''',
      'lib/core/storage/local_storage.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope.');
});

class LocalStorage {
  final SharedPreferences _prefs;
  LocalStorage(this._prefs);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);
  Future<bool> remove(String key) => _prefs.remove(key);
}

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage(ref.watch(sharedPreferencesProvider));
});
''',
      'lib/features/home/domain/entities/home_entity.dart':
          Snippets.welcomeModel('HomeEntity'),
      'lib/features/home/domain/repositories/home_repository.dart': '''
import 'package:dartz/dartz.dart';
import 'package:$name/core/error/failures.dart';
import 'package:$name/features/home/domain/entities/home_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeEntity>> getWelcomeMessage();
}
''',
      'lib/features/home/data/repositories/home_repository_impl.dart': '''
import 'package:dartz/dartz.dart';
import 'package:$name/core/error/failures.dart';
import 'package:$name/features/home/domain/entities/home_entity.dart';
import 'package:$name/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<Either<Failure, HomeEntity>> getWelcomeMessage() async {
    // TODO: replace this stub with a real data source.
    try {
      return const Right(
        HomeEntity(
          title: 'Welcome',
          subtitle: 'Your app is ready. Start building!',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
''',
      'lib/features/home/presentation/providers/home_provider.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$name/features/home/data/repositories/home_repository_impl.dart';
import 'package:$name/features/home/domain/entities/home_entity.dart';
import 'package:$name/features/home/domain/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl();
});

final homeWelcomeProvider = FutureProvider<HomeEntity>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  final result = await repo.getWelcomeMessage();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (entity) => entity,
  );
});
''',
    };

    if (c.hasFlavors) {
      files.addAll(Snippets.flavorFiles(
        name: name,
        title: title,
        configDir: configDir,
        flavors: c.flavors,
        storageImport: _storageImport,
      ));
    }

    return files;
  }
}
