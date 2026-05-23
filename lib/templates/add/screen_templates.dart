import 'package:srik_cli/utils/string_utils.dart';

/// Templates for a single screen added via `srik add screen`.
class ScreenTemplates {
  static String screen(
    String projectName,
    String feature,
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

class ${pascal}Screen extends ConsumerWidget {
  const ${pascal}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('$title')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Text('$title screen', style: AppTextStyles.h2),
          ),
        ),
      ),
    );
  }
}
''';
  }

  static String provider(String screen) {
    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for the $screen screen.
final ${screen}StateProvider = StateProvider<int>((ref) => 0);
''';
  }
}
