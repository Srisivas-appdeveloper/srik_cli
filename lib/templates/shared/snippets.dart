/// Reusable code snippets shared across architecture templates.
///
/// Anything that is identical or near-identical between the clean / mvvm /
/// feature-first / simple template sets lives here, parameterized by the
/// pieces that actually differ (folder paths, import locations, class and
/// provider names). Architecture templates compose these instead of
/// copy-pasting the same Dart source.
class Snippets {
  Snippets._();

  /// `lib/main.dart`.
  ///
  /// When [storageImport] is provided (Clean), generates a `main` that
  /// initializes SharedPreferences and overrides `sharedPreferencesProvider`
  /// in the ProviderScope. Otherwise generates the minimal ProviderScope
  /// bootstrap used by the other architectures.
  static String mainDart(String name, {String? storageImport}) {
    if (storageImport != null) {
      return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'package:$name/$storageImport';

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
''';
    }
    return '''
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
''';
  }

  /// `lib/app.dart` — the MaterialApp.router wrapper.
  static String appWidget({
    required String name,
    required String title,
    required String themeImport,
    required String routerImport,
  }) {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$name/$themeImport';
import 'package:$name/$routerImport';

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
''';
  }

  /// The Dio HTTP client provider.
  static String dioClient() {
    return '''
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
''';
  }

  /// The go_router config with a single home route.
  ///
  /// [homeImport] is relative to `package:$name/`, [homeWidget] is the widget
  /// class to build for `/` (e.g. `HomeScreen` or `HomeView`).
  static String appRouter({
    required String name,
    required String homeImport,
    required String homeWidget,
  }) {
    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:$name/$homeImport';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const $homeWidget(),
      ),
    ],
  );
});
''';
  }

  /// The home screen / view — a ConsumerWidget rendering an AsyncValue.when
  /// body. The watched provider must expose an object with `title` and
  /// `subtitle` String fields.
  ///
  /// - [className]      widget class name (HomeScreen / HomeView)
  /// - [designDir]      design-system folder relative to lib/
  /// - [providerName]   the FutureProvider being watched
  /// - [providerImports] import lines for the provider (empty if inline)
  /// - [inlineProvider] optional provider definition placed in this file
  static String homeScreen({
    required String name,
    required String title,
    required String designDir,
    required String className,
    required String providerName,
    List<String> providerImports = const [],
    String inlineProvider = '',
  }) {
    final providerImportLines = providerImports
        .map((path) => "import 'package:$name/$path';")
        .join('\n');
    final inlineBlock = inlineProvider.isEmpty ? '' : '\n$inlineProvider\n';

    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$name/$designDir/app_colors.dart';
import 'package:$name/$designDir/app_spacing.dart';
import 'package:$name/$designDir/app_text_styles.dart';${providerImportLines.isEmpty ? '' : '\n$providerImportLines'}
$inlineBlock
class $className extends ConsumerWidget {
  const $className({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch($providerName);

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
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.sm),
                Text(data.subtitle, style: AppTextStyles.body),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () => ref.invalidate($providerName),
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
''';
  }

  /// A plain Equatable data model with `title` + `subtitle`.
  static String welcomeModel(String className) {
    return '''
import 'package:equatable/equatable.dart';

class $className extends Equatable {
  final String title;
  final String subtitle;

  const $className({required this.title, required this.subtitle});

  @override
  List<Object?> get props => [title, subtitle];
}
''';
  }
}
