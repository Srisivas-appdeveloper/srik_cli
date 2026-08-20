# srik_cli

> Flutter project scaffolder. Choose your architecture, design preset, gradients, and spacing — generate a runnable app in seconds.

[![pub package](https://img.shields.io/pub/v/srik_cli.svg)](https://pub.dev/packages/srik_cli)

## What it does

Stop rebuilding the same folder structure for every new Flutter app. `srik` generates a fully wired project with the architecture and design system you choose.

## Install

```bash
dart pub global activate srik_cli
```

Make sure `~/.pub-cache/bin` is on your PATH.

## Faster startup (optional)

Compile to a native binary for instant startup:

```bash
dart compile exe bin/srik.dart -o srik
```

Then move the `srik` binary onto your PATH.

## Use

```bash
srik create my_app
cd my_app
flutter run
```

The interactive prompt lets you pick everything:

```
? Description           A new Flutter app
? Organization          com.example
? Architecture          Clean Architecture / MVVM / Feature-first / Simple
? Choose a design style Material / Vibrant / Minimalism / Neomorphism / …
? Add gradient theme?   y/N
? Spacing scale         Compact / Normal / Spacious
? Brand color (hex)     #6200EE
```

### Non-interactive

```bash
srik create my_app \
  --arch=mvvm \
  --design=vibrant \
  --gradient \
  --spacing=spacious \
  --brand=#FF5733 \
  --org=com.acme \
  --no-interactive
```

## Architectures

| Architecture | Structure |
|---|---|
| **Clean** | `core/` + `features/<name>/{data,domain,presentation}` |
| **MVVM** | `models/`, `views/`, `viewmodels/`, `services/` |
| **Feature-first** | `shared/` + `features/<name>/` (flat per feature) |
| **Simple** | `screens/`, `widgets/`, `models/`, `services/` |

All architectures come wired with Riverpod, go_router, and Dio.

## Design styles

`--design` selects a **generated design system**, not just a color palette. Screens use reusable components (`AppSurface`, `AppCard`, `AppButton`, `AppTextField`, …). The style decides how those components render.

| Style | Look |
|---|---|
| **material** | Material 3 defaults, native Flutter semantics |
| **vibrant** | Saturated startup look, stronger hierarchy, optional gradients |
| **minimalism** | Restrained type-first UI. Alias: `minimal` |
| **neomorphism** | Soft extruded / inset surfaces via paired light and dark shadows |
| **skeuomorphism** | Tactile depth using gradients, highlights, and borders (no raster textures) |
| **glassmorphism** | Translucent surfaces with blur, tint, and edge highlights |
| **claymorphism** | Large radii, inflated shapes, soft inner/outer shadows |
| **maximalism** | Bold type, high energy, decorative layering |
| **brutalism** | Hard borders, offset shadows, blocky geometry |
| **liquid_glass** | Layered blur, luminous edges, fluid motion. Aliases: `liquidglass`, `liquid-glass` |
| **spatial_ui** | Floating depth, scale, and layered hierarchy. Aliases: `spatialui`, `spatial-ui` |

Every style generates semantic tokens (color, spacing, radius, typography, shadow, blur, border, opacity, elevation, motion, size) plus light and dark `ThemeData` with `ThemeExtension`s. `--brand` is expanded per style rather than pasted through unchanged. `--gradient` still enables prominent brand gradients (legacy `app_gradients.dart` shim included).

Glassmorphism, Liquid Glass, and Spatial UI keep expensive blur inside `AppSurface`. If the device reports disabled animations, those primitives fall back to opaque elevated surfaces.

Spacing scale (`compact` / `normal` / `spacious`) controls token density.

```bash
srik create my_app --arch=clean --design=glassmorphism --brand=#6750A4
srik create finance_app --arch=mvvm --design=neomorphism --brand=#2457F5
srik create portfolio --design=brutalism --brand=#FF5A36
srik create spatial_demo --design=spatial_ui --brand=#7C5CFC
srik create premium_app --design=liquid_glass --gradient --brand=#0A84FF
srik create my_app --design=minimal
```

## Commands

```bash
srik create <name>                # Create new project
srik add feature <name>           # Add a feature module (all architectures)
srik add screen <name> -f <feat>  # Add a screen to a feature (all architectures)
srik doctor                       # Check your environment
srik --version                    # Print version
```

### Adding features

Keep scaffolding after creation — `add` adapts to your project's architecture:

```bash
cd my_app
srik add feature profile
srik add screen edit_profile --feature profile
```

Each `add feature` generates the structure appropriate to the project's
architecture and updates `srik.yaml`.

## Roadmap

`v0.2.0` ships architecture choice, design customization, and `add` support
for all four architectures. Coming next:

- **Firebase integration** (Auth, Firestore, FCM)
- **State management options** (Bloc, Provider, GetX)
- **`srik rename`** — rename a generated project in place

## Why not very_good_cli or mason?

- **`very_good_cli`** forces Bloc + their opinionated structure
- **`mason`** is a generic template engine — you write all bricks yourself
- **`srik_cli`** ships ready-made, architecture-aware templates that boot a working app immediately

## License

MIT — see [LICENSE](LICENSE).

## Contributing

Issues and PRs welcome at https://github.com/srisivas/srik_cli
