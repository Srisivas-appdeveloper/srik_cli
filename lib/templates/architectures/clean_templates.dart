import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/utils/string_utils.dart';

/// Clean Architecture template set.
/// Design files live in lib/core/constants/ (written separately).
class CleanTemplates {
  /// Folder (relative to lib/) where design system files are placed.
  static const String designDir = 'core/constants';

  static Map<String, String> files(ProjectConfig c) {
    final name = c.projectName;
    final title = StringUtils.toTitleCase(name);

    return {
      'lib/main.dart': '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'package:$name/core/storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}
''',
      'lib/app.dart': '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$name/core/constants/app_theme.dart';
import 'package:$name/core/router/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: '$title',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
''',
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
      'lib/core/network/dio_client.dart': '''
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  dio.interceptors.add(LogInterceptor(responseBody: true));
  return dio;
});
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
      'lib/core/router/app_router.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:$name/features/home/presentation/screens/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
''',
      'lib/features/home/domain/entities/home_entity.dart': '''
import 'package:equatable/equatable.dart';

class HomeEntity extends Equatable {
  final String title;
  final String subtitle;

  const HomeEntity({required this.title, required this.subtitle});

  @override
  List<Object?> get props => [title, subtitle];
}
''',
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
    try {
      await Future.delayed(const Duration(milliseconds: 300));
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
      'lib/features/home/presentation/screens/home_screen.dart': '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$name/core/constants/app_colors.dart';
import 'package:$name/core/constants/app_spacing.dart';
import 'package:$name/core/constants/app_text_styles.dart';
import 'package:$name/features/home/presentation/providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final welcomeAsync = ref.watch(homeWelcomeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('$title')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: welcomeAsync.when(
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
                Text(entity.title, style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.sm),
                Text(entity.subtitle, style: AppTextStyles.body),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () => ref.invalidate(homeWelcomeProvider),
                    child: const Text('Refresh'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Center(
                  child: Text(
                    'Generated by srik_cli',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
''',
    };
  }
}
