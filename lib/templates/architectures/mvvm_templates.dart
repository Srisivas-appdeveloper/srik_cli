import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/utils/string_utils.dart';

/// MVVM template set.
/// Design files live in lib/core/constants/.
class MvvmTemplates {
  static const String designDir = 'core/constants';

  static Map<String, String> files(ProjectConfig c) {
    final name = c.projectName;
    final title = StringUtils.toTitleCase(name);

    return {
      'lib/main.dart': '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
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
      'lib/core/network/dio_client.dart': '''
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(LogInterceptor(responseBody: true));
  return dio;
});
''',
      'lib/core/router/app_router.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:$name/views/home_view.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeView(),
      ),
    ],
  );
});
''',
      'lib/models/home_model.dart': '''
import 'package:equatable/equatable.dart';

/// Data model for the home screen.
class HomeModel extends Equatable {
  final String title;
  final String subtitle;

  const HomeModel({required this.title, required this.subtitle});

  @override
  List<Object?> get props => [title, subtitle];
}
''',
      'lib/services/home_service.dart': '''
import 'package:$name/models/home_model.dart';

/// Service layer — talks to APIs / storage.
class HomeService {
  Future<HomeModel> fetchWelcome() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const HomeModel(
      title: 'Welcome',
      subtitle: 'Your MVVM app is ready. Start building!',
    );
  }
}
''',
      'lib/viewmodels/home_viewmodel.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$name/models/home_model.dart';
import 'package:$name/services/home_service.dart';

final homeServiceProvider = Provider<HomeService>((ref) => HomeService());

/// ViewModel — exposes state to the View, holds presentation logic.
final homeViewModelProvider =
    FutureProvider<HomeModel>((ref) async {
  final service = ref.watch(homeServiceProvider);
  return service.fetchWelcome();
});
''',
      'lib/views/home_view.dart': '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$name/core/constants/app_colors.dart';
import 'package:$name/core/constants/app_spacing.dart';
import 'package:$name/core/constants/app_text_styles.dart';
import 'package:$name/viewmodels/home_viewmodel.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);

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
                Text(model.title, style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.sm),
                Text(model.subtitle, style: AppTextStyles.body),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.invalidate(homeViewModelProvider),
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
