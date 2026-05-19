# srik_cli

> Flutter project scaffolder. Generates production-ready Clean Architecture + Riverpod projects with one command.

[![pub package](https://img.shields.io/pub/v/srik_cli.svg)](https://pub.dev/packages/srik_cli)

## What it does

Stop rebuilding the same folder structure for every new Flutter app. `srik` generates:

- **Clean Architecture** folder layout (domain → data → presentation)
- **Riverpod** state management wired up
- **go_router** routing configured
- **Dio** networking with logging interceptor
- **shared_preferences** local storage wrapper
- **Design tokens** (colors, spacing, typography, theme) from your brand color
- **dartz** for functional error handling (`Either<Failure, Result>`)
- One working example feature (`home`) showing the full data flow

Run one command, get a runnable app.

## Install

```bash
dart pub global activate srik_cli
```

Make sure `~/.pub-cache/bin` is on your PATH.

## Use

```bash
srik create my_app
cd my_app
flutter run
```

### With options

```bash
srik create my_app \
  --org=com.acme \
  --brand=#FF5733 \
  --description="A fitness tracker"
```

### Non-interactive (for CI)

```bash
srik create my_app --no-interactive --org=com.acme --brand=#6200EE
```

## What gets generated

```
my_app/
├── lib/
│   ├── core/
│   │   ├── constants/       # design tokens
│   │   ├── error/           # exceptions & failures
│   │   ├── network/         # Dio client provider
│   │   ├── router/          # go_router config
│   │   └── storage/         # shared_preferences wrapper
│   ├── features/
│   │   └── home/
│   │       ├── data/        # repository impls
│   │       ├── domain/      # entities, repo interfaces
│   │       └── presentation/# screens, providers
│   ├── app.dart
│   └── main.dart
├── srik.yaml                # CLI config for future commands
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

## Commands

```bash
srik create <name>    # Create new project
srik doctor           # Check your environment
srik --version        # Print version
```

## Roadmap

`v0.1.0` ships Clean Architecture + Riverpod. Coming next:

- **v0.2** — MVVM and Feature-first architectures
- **v0.3** — Bloc, Provider, GetX state management options
- **v0.4** — Firebase integration (Auth, Firestore, FCM)
- **v0.5** — `srik add feature` and `srik add screen` commands
- **v0.6** — Multiple design system presets (Vibrant, iOS, Minimal)

## Why not very_good_cli or mason?

- **`very_good_cli`** forces Bloc + their opinionated structure
- **`mason`** is a generic template engine — you write all the bricks yourself
- **`srik_cli`** ships ready-made templates that boot a working app immediately

## License

MIT — see [LICENSE](LICENSE) file.

## Contributing

Issues and PRs welcome at https://github.com/srisivas/srik_cli
