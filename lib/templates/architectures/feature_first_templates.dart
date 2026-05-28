import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/templates/shared/snippets.dart';
import 'package:srik_cli/utils/string_utils.dart';

/// Feature-first template set.
/// Design files live in lib/shared/theme/.
class FeatureFirstTemplates {
  static const String designDir = 'shared/theme';

  static Map<String, String> files(ProjectConfig c) {
    final name = c.projectName;
    final title = StringUtils.toTitleCase(name);

    return {
      'lib/main.dart': Snippets.mainDart(name),
      'lib/app.dart': Snippets.appWidget(
        name: name,
        title: title,
        themeImport: 'shared/theme/app_theme.dart',
        routerImport: 'shared/router/app_router.dart',
      ),
      'lib/shared/network/dio_client.dart': Snippets.dioClient(),
      'lib/shared/router/app_router.dart': Snippets.appRouter(
        name: name,
        homeImport: 'features/home/home_screen.dart',
        homeWidget: 'HomeScreen',
      ),
      'lib/features/home/home_screen.dart': Snippets.homeScreen(
        name: name,
        title: title,
        designDir: designDir,
        className: 'HomeScreen',
        providerName: 'homeControllerProvider',
        providerImports: const ['features/home/home_controller.dart'],
      ),
      'lib/features/home/home_model.dart': Snippets.welcomeModel('HomeModel'),
      'lib/features/home/home_service.dart': '''
import 'package:$name/features/home/home_model.dart';

class HomeService {
  // TODO: replace this stub with a real data source.
  Future<HomeModel> fetchWelcome() async {
    return const HomeModel(
      title: 'Welcome',
      subtitle: 'Your feature-first app is ready. Start building!',
    );
  }
}
''',
      'lib/features/home/home_controller.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$name/features/home/home_model.dart';
import 'package:$name/features/home/home_service.dart';

final homeServiceProvider = Provider<HomeService>((ref) => HomeService());

final homeControllerProvider = FutureProvider<HomeModel>((ref) async {
  final service = ref.watch(homeServiceProvider);
  return service.fetchWelcome();
});
''',
    };
  }
}
