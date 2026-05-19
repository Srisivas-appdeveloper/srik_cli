# Example

This folder demonstrates what `srik create` generates.

## Generate a new project

```bash
# Install globally
dart pub global activate srik_cli

# Create a new Flutter project
srik create my_app

# Or with options
srik create my_app \
  --org=com.acme \
  --brand=#FF5733 \
  --description="A fitness tracker"
```

## What you get

A complete Flutter project at `./my_app/` with:

- Clean Architecture folder layout
- Riverpod state management
- go_router for navigation
- Dio HTTP client
- shared_preferences local storage
- Design tokens generated from your brand color
- A working `home` feature demonstrating the full data flow

Run it:

```bash
cd my_app
flutter run
```

That's it.
