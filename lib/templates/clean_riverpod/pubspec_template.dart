import 'package:srik_cli/models/project_config.dart';

String pubspecTemplate(ProjectConfig c) => '''
name: ${c.projectName}
description: ${c.description}
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  
  # State management
  flutter_riverpod: ^2.5.1
  
  # Routing
  go_router: ^14.0.0
  
  # Networking
  dio: ^5.4.0
  
  # Local storage
  shared_preferences: ^2.2.0
  
  # Utilities
  equatable: ^2.0.5
  dartz: ^0.10.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
''';
