# Changelog

## 0.4.0

Generated design-system engine. `--design` now selects among 11 visual styles
that drive tokens, theme extensions, and reusable components — not only a
color palette. Existing Material / Vibrant / Minimal projects and the
`minimal` alias remain supported.

### New

- Design styles: `material`, `vibrant`, `minimalism`, `neomorphism`,
  `skeuomorphism`, `glassmorphism`, `claymorphism`, `maximalism`,
  `brutalism`, `liquid_glass`, `spatial_ui`.
- Aliases: `minimal` → `minimalism`, `liquidglass` / `liquid-glass`,
  `spatialui` / `spatial-ui`, `neoorphism` / `neuomorphism`.
- Nested design system (`tokens/`, `themes/`, `components/`, `styles/`)
  under `lib/core/design`, `lib/shared/design`, or `lib/design`.
- Reusable widgets: `AppSurface`, `AppCard`, `AppButton`, `AppIconButton`,
  `AppTextField`, `AppChip`, `AppBadge`, `AppDialog`, `AppBottomSheet`,
  `AppNavigationBar`.
- Theme extensions for surface, shadow, blur, border, motion, and components.
- Light and dark `ThemeData` with `themeMode: ThemeMode.system`.
- Brand-aware, style-specific color derivation.
- `srik.yaml` `schema_version: 2` and a `design:` block. v0.3 files still
  load; `srik add` keeps using the old token folders for those projects.

### Compatibility

- `--design=material|vibrant|minimal` continues to work.
- Legacy token shims are written to `core/constants`, `shared/theme`, or
  `theme` so older imports keep resolving.
- `--gradient` still controls the legacy `app_gradients.dart` shim. Gradient
  token files are always generated in the new design system.

## 0.3.1

Pub.dev score fixes — no functional changes.

### Docs

- Wrapped `<name>` / `<flavor>` placeholders in doc comments in backticks so
  they are no longer parsed as HTML (`unintended_html_in_doc_comment`).

### Metadata

- Fixed the `homepage`, `repository`, and `issue_tracker` URLs in
  `pubspec.yaml` to point at the actual GitHub repository
  (`Srisivas-appdeveloper/srik_cli`).

## 0.3.0

Build flavors. `srik create --flavors=dev,staging,prod` (or the interactive
prompt) scaffolds a project with separate build variants — each with its own
app name, bundle ID suffix, API base URL, and entry point. Without `--flavors`,
output is unchanged from 0.2.x. Verified on all four architectures: generated
projects pass `flutter analyze` with zero issues, and `flutter build apk
--flavor dev` produces a working APK.

### New

- `--flavors` option on `srik create` (comma-separated, e.g. `dev,staging,prod`)
  plus an interactive prompt. Flavor names are validated (lowercase, start with
  a letter; duplicates and reserved words like `main`/`test` are rejected).
- **Dart:** one entry point per flavor (`lib/main_<flavor>.dart`); `main.dart`
  defaults to the first flavor. A generated `app_config.dart` exposes a `Flavor`
  enum and an `AppConfig` (app name, API base URL, bundle suffix) selected at
  startup via `AppConfig.current`. The app title and Dio base URL are driven by
  the active flavor. Config file location follows the chosen architecture
  (`core/config`, `shared/config`, or `config`).
- **Android:** a `productFlavors` block is inserted into
  `android/app/build.gradle{.kts}` (Kotlin and Groovy DSL both supported),
  parsed and inserted inside the `android { }` block rather than appended.
  `AndroidManifest.xml` is wired to `@string/app_name` so per-flavor names
  show on device.
- **iOS:** a `FLAVORS_IOS_SETUP.md` with step-by-step Xcode instructions (the
  `.pbxproj` is intentionally not edited programmatically).
- **VS Code:** `.vscode/launch.json` with one launch configuration per flavor.
- **README:** a "Flavors" section with per-flavor run/build commands.
- `srik.yaml` records the chosen flavors under a `flavors:` list.

## 0.2.1

Internal optimizations — no user-facing behavior changes. Generated output is
identical (and still passes `flutter analyze` with zero issues on all four
architectures).

### Performance

- `srik create` runs `flutter pub get` and `git init` concurrently, then
  commits — shaving time off project creation.
- Uses `flutter create --empty` when the installed Flutter supports it
  (3.6+), skipping the throwaway counter-app boilerplate.

### Internal

- Deduplicated architecture templates: shared `main.dart`, `app.dart`, the
  Dio client, the go_router config, and the home screen body now live in
  `lib/templates/shared/snippets.dart`. Each architecture composes these
  snippets instead of copy-pasting source, so a change is made in one place.

### Docs

- README: added an optional "Faster startup" (AOT compile) section.
- README: corrected `add feature` / `add screen` docs — they support all four
  architectures (since 0.2.0), not just Clean.

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
