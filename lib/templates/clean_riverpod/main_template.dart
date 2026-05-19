import 'package:srik_cli/models/project_config.dart';

String mainDartTemplate(ProjectConfig c) => '''
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
