import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/templates/shared/snippets.dart';
import 'package:srik_cli/utils/string_utils.dart';

/// Simple template set — minimal structure, no architecture layering.
/// Design files live in lib/theme/.
class SimpleTemplates {
  static const String designDir = 'theme';

  /// Folder (relative to lib/) where flavor config is placed.
  static const String configDir = 'config';

  static Map<String, String> files(ProjectConfig c) {
    final name = c.projectName;
    final title = StringUtils.toTitleCase(name);
    final configImport = c.hasFlavors ? '$configDir/app_config.dart' : null;

    final inlineProvider = '''
import 'package:$name/models/welcome_model.dart';

final welcomeProvider = FutureProvider<WelcomeModel>((ref) async {
  return const WelcomeModel(
    title: 'Welcome',
    subtitle: 'Your app is ready. Start building!',
  );
});''';

    final files = <String, String>{
      'lib/main.dart': c.hasFlavors
          ? Snippets.flavorEntryPoint(
              name: name,
              flavor: c.flavors.first,
              configImport: configImport!,
            )
          : Snippets.mainDart(name),
      'lib/app.dart': Snippets.appWidget(
        name: name,
        title: title,
        themeImport: 'theme/app_theme.dart',
        routerImport: 'router/app_router.dart',
        configImport: configImport,
      ),
      'lib/services/api_service.dart':
          Snippets.dioClient(name: name, configImport: configImport),
      'lib/router/app_router.dart': Snippets.appRouter(
        name: name,
        homeImport: 'screens/home_screen.dart',
        homeWidget: 'HomeScreen',
      ),
      'lib/models/welcome_model.dart': Snippets.welcomeModel('WelcomeModel'),
      'lib/screens/home_screen.dart': Snippets.homeScreen(
        name: name,
        title: title,
        designDir: designDir,
        className: 'HomeScreen',
        providerName: 'welcomeProvider',
        inlineProvider: inlineProvider,
      ),
      'lib/widgets/.gitkeep': '',
    };

    if (c.hasFlavors) {
      files.addAll(Snippets.flavorFiles(
        name: name,
        title: title,
        configDir: configDir,
        flavors: c.flavors,
      ));
    }

    return files;
  }
}
