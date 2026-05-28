import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/templates/shared/snippets.dart';
import 'package:srik_cli/utils/string_utils.dart';

/// MVVM template set.
/// Design files live in lib/core/constants/.
class MvvmTemplates {
  static const String designDir = 'core/constants';

  static Map<String, String> files(ProjectConfig c) {
    final name = c.projectName;
    final title = StringUtils.toTitleCase(name);

    return {
      'lib/main.dart': Snippets.mainDart(name),
      'lib/app.dart': Snippets.appWidget(
        name: name,
        title: title,
        themeImport: 'core/constants/app_theme.dart',
        routerImport: 'core/router/app_router.dart',
      ),
      'lib/core/network/dio_client.dart': Snippets.dioClient(),
      'lib/core/router/app_router.dart': Snippets.appRouter(
        name: name,
        homeImport: 'views/home_view.dart',
        homeWidget: 'HomeView',
      ),
      'lib/views/home_view.dart': Snippets.homeScreen(
        name: name,
        title: title,
        designDir: designDir,
        className: 'HomeView',
        providerName: 'homeViewModelProvider',
        providerImports: const ['viewmodels/home_viewmodel.dart'],
      ),
      'lib/models/home_model.dart': Snippets.welcomeModel('HomeModel'),
      'lib/services/home_service.dart': '''
import 'package:$name/models/home_model.dart';

/// Service layer — talks to APIs / storage.
class HomeService {
  // TODO: replace this stub with a real data source.
  Future<HomeModel> fetchWelcome() async {
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
    };
  }
}
