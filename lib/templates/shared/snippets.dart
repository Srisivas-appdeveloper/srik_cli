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
  ///
  /// When [configImport] is provided (flavors enabled), the app title is driven
  /// by `AppConfig.current.appName` instead of a hard-coded string. When it is
  /// null the output is byte-for-byte identical to the single-flavor form.
  static String appWidget({
    required String name,
    required String title,
    required String themeImport,
    required String routerImport,
    String? configImport,
  }) {
    if (configImport != null) {
      return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$name/$configImport';
import 'package:$name/$themeImport';
import 'package:$name/$routerImport';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: AppConfig.current.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
''';
    }
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
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
''';
  }

  /// The Dio HTTP client provider.
  ///
  /// When [configImport] is provided (flavors enabled), the base URL is driven
  /// by `AppConfig.current.apiBaseUrl`; [name] must also be supplied so the
  /// config can be imported. When [configImport] is null the output is
  /// byte-for-byte identical to the single-flavor form.
  static String dioClient({String? name, String? configImport}) {
    if (configImport != null) {
      return '''
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$name/$configImport';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.current.apiBaseUrl,
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
import 'package:$name/$designDir/design_system.dart';${providerImportLines.isEmpty ? '' : '\n$providerImportLines'}
$inlineBlock
class $className extends ConsumerWidget {
  const $className({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch($providerName);

    return Scaffold(
      appBar: AppBar(title: const Text('$title')),
      body: AppSurface(
        depth: AppSurfaceDepth.flat,
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Error: \$e',
                  style: AppTypography.body.copyWith(color: AppColors.error),
                ),
              ),
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(data.title, style: AppTypography.display),
                        const SizedBox(height: AppSpacing.sm),
                        Text(data.subtitle, style: AppTypography.body),
                        const SizedBox(height: AppSpacing.md),
                        AppChip(label: AppStyleConfig.style.label),
                      ],
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Refresh',
                    onPressed: () => ref.invalidate($providerName),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Secondary',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Secondary action')),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Center(
                    child: Text(
                      'Generated by srik_cli',
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
''';
  }

  /// `app_config.dart` — the `Flavor` enum + `AppConfig` value object holding
  /// per-flavor settings (app name, API base URL, bundle suffix), plus the
  /// active [AppConfig.current] set at startup by the entry point.
  ///
  /// [flavors] are the chosen flavor names (already validated). [title] is the
  /// base app title (Title Case) used to derive each flavor's app name.
  static String appConfig({
    required String title,
    required List<String> flavors,
  }) {
    final enumValues = flavors.join(', ');

    String appNameFor(String flavor) =>
        flavor == 'prod' ? title : '$title ${_flavorLabel(flavor)}';

    String apiBaseUrlFor(String flavor) {
      if (flavor == 'prod') return 'https://api.example.com';
      final host = flavor.replaceAll('_', '-');
      return 'https://$host-api.example.com';
    }

    String bundleSuffixFor(String flavor) => flavor == 'prod' ? '' : '.$flavor';

    final entries = flavors.map((f) => '''
    Flavor.$f: AppConfig(
      flavor: Flavor.$f,
      appName: '${appNameFor(f)}',
      apiBaseUrl: '${apiBaseUrlFor(f)}',
      bundleSuffix: '${bundleSuffixFor(f)}',
    ),''').join('\n');

    return '''
/// Build flavors for this app.
enum Flavor { $enumValues }

/// Per-flavor configuration. The active config is selected in the flavored
/// entry point (`lib/main_<flavor>.dart`) and assigned to [AppConfig.current]
/// before `runApp`.
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.bundleSuffix,
  });

  final Flavor flavor;
  final String appName;
  final String apiBaseUrl;
  final String bundleSuffix;

  /// The configuration for the running flavor. Set once at startup.
  static late AppConfig current;

  static const Map<Flavor, AppConfig> _values = {
$entries
  };

  /// Returns the configuration for [flavor].
  static AppConfig of(Flavor flavor) => _values[flavor]!;
}
''';
  }

  /// A flavored entry point — `lib/main_<flavor>.dart`. Selects the flavor's
  /// config via `AppConfig.current`, then runs the shared [MyApp].
  ///
  /// When [storageImport] is provided (Clean), it initializes SharedPreferences
  /// and overrides `sharedPreferencesProvider`, mirroring the single-flavor
  /// `main.dart`. [configImport] is the path (relative to `package:$name/`) of
  /// the generated `app_config.dart`.
  static String flavorEntryPoint({
    required String name,
    required String flavor,
    required String configImport,
    String? storageImport,
  }) {
    if (storageImport != null) {
      return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:$name/app.dart';
import 'package:$name/$configImport';
import 'package:$name/$storageImport';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.current = AppConfig.of(Flavor.$flavor);

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

import 'package:$name/app.dart';
import 'package:$name/$configImport';

void main() {
  AppConfig.current = AppConfig.of(Flavor.$flavor);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
''';
  }

  /// The extra files a flavored project adds on top of the base architecture
  /// files: the shared `app_config.dart` plus one entry point per flavor. Keyed
  /// by path relative to the project root, matching the architecture maps.
  ///
  /// [configDir] is the config folder relative to lib/ (per architecture).
  /// [storageImport] is forwarded to each entry point (Clean only).
  static Map<String, String> flavorFiles({
    required String name,
    required String title,
    required String configDir,
    required List<String> flavors,
    String? storageImport,
  }) {
    final configImport = '$configDir/app_config.dart';
    final files = <String, String>{
      'lib/$configDir/app_config.dart':
          appConfig(title: title, flavors: flavors),
    };
    for (final flavor in flavors) {
      files['lib/main_$flavor.dart'] = flavorEntryPoint(
        name: name,
        flavor: flavor,
        configImport: configImport,
        storageImport: storageImport,
      );
    }
    return files;
  }

  /// `Dev` from `dev`, `Staging` from `staging` — for human-facing app names.
  static String _flavorLabel(String flavor) => flavor
      .split('_')
      .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
      .join(' ');

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
