# Changelog

## 0.2.0

First public release after 0.1.0. Massive expansion of architecture, design,
and code-generation capabilities.

### New

- **Architecture choice** — `srik create --arch=<arch>` picks one of:
  - `clean` — Clean Architecture (core + layered features/)
  - `mvvm` — Model-View-ViewModel (models/ services/ viewmodels/ views/)
  - `feature-first` — flat per-feature folders under features/
  - `simple` — minimal structure, no layering
- **Design presets** — `--design=material|vibrant|minimal`; each generates a
  full set of design tokens (colors, spacing, radius, typography) from your
  brand color.
- **Gradient themes** — `--gradient` flag generates `app_gradients.dart` with
  brand-derived linear and radial gradients.
- **Spacing scales** — `--spacing=compact|normal|spacious` picks the density
  of the spacing tokens.
- **`srik add feature <name>`** — generates a full feature module appropriate
  to the project's architecture (works for all four archs).
- **`srik add screen <name> --feature <feature>`** — adds a screen (and
  optional provider) to an existing feature; works for all four archs.
- **`srik create --verbose` / `-v`** for extra diagnostics.
- Spinner shown during `flutter create` and `flutter pub get`.
- `srik.yaml` is read automatically when running `srik add` from any
  subdirectory of a project.

### Generated-code quality

- Generated `main.dart` initializes `SharedPreferences` and wires it into
  `ProviderScope` — no more `UnimplementedError` at startup.
- Generated projects pass `flutter analyze` with zero issues across all four
  architectures, both after `create` and after `add feature` / `add screen`.
- Generated repo stubs use a clear `TODO` instead of fake `Future.delayed`.
- All generated code uses package imports (`package:app/...`) for robustness.

### Correctness

- `srik.yaml` mutation safely rewrites the file via a managed template (no
  more fragile line-based parsing).
- Enum parsers (`AppArchitecture`, `DesignPreset`, `SpacingScale`) throw
  `FormatException` on unknown input instead of silently defaulting.
- `Logger` honors `NO_COLOR`, non-TTY stdout, and Windows ANSI support.
- `srik create` validates that `--output` exists and is writable before
  starting generation.
- `srik doctor` tolerates empty/non-string version output.
- `FeatureGenerator.designDirFor` errors loudly on unknown architectures.

### UX

- Error messages echo the user's bad input and show a concrete example
  (e.g. "Invalid feature name 'Foo Bar'. ... Example: user_profile").
- Interactive prompts cover architecture, design preset, gradient, and
  spacing.
- `srik.yaml` now ships with a documented header explaining every field.

### Internal

- Unified `ProjectGenerator` dispatches to per-architecture template sets.
- Architecture templates split into `lib/templates/architectures/`.
- Per-arch add templates in `lib/templates/add/`.
- Shared design + common templates in `lib/templates/shared/`.
- Test suite expanded to **57 tests** (was 8 in 0.1.0): integration tests
  across all four architectures, multi-arch add tests, validators, enums,
  generators.

## 0.1.0

Initial release.

- `srik create <name>` generates a Clean Architecture + Riverpod project
  with go_router, Dio, shared_preferences, design tokens, and a sample
  feature.
- `srik doctor` checks the environment.
- `--version` flag.
- Interactive prompts, `--no-interactive` mode, input validation, git init.
