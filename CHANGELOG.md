# Changelog

## 0.1.0

Initial release.

### Features

- `srik create <name>` generates a Flutter project with:
  - Clean Architecture folder structure (domain / data / presentation)
  - Riverpod state management
  - go_router routing
  - Dio networking client with logging interceptor
  - shared_preferences local storage wrapper
  - Design tokens (colors, spacing, typography, radius, durations) from brand color
  - dartz functional error handling
  - One example `home` feature showing full data flow
- `srik doctor` checks environment for Flutter, Dart, git
- `--version` flag prints CLI version
- Interactive prompts via the `interact` package
- `--no-interactive` mode for CI use
- Validates project name, organization, and brand color hex
- Initializes git repo with first commit
- Runs `flutter pub get` automatically after generation
