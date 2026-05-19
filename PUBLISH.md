# Publishing srik_cli to pub.dev

Step-by-step for tomorrow.

## Prerequisites

- Dart SDK 3.0+ installed
- Flutter SDK 3.16+ installed
- A Google account (any will do)
- Git installed

## Step 1: Get the code on your machine

Unzip the package to a location you'll keep, e.g. `~/dev/srik_cli/`.

```bash
cd ~/dev/srik_cli
```

## Step 2: Install dependencies

```bash
dart pub get
```

If this fails on any dependency version, run `dart pub upgrade` instead.

## Step 3: Run tests

```bash
dart test
```

You should see all tests passing in `test/utils_test.dart`.

## Step 4: Local smoke test

Before publishing, verify the CLI actually works from your machine.

```bash
# Activate it locally from the source folder
dart pub global activate --source path .

# Now try creating a project somewhere
cd /tmp
srik doctor
srik create test_app
cd test_app
flutter run
```

If `flutter run` launches and the app shows a welcome screen with a Refresh button, you're good.

Clean up:
```bash
cd ~/dev/srik_cli
dart pub global deactivate srik_cli
```

## Step 5: Verify pub.dev name availability

Open in browser:
```
https://pub.dev/packages/srik_cli
```

If you get a 404 (not found), the name is available. If you see a package page, pick another name and update `pubspec.yaml` + `bin/srik.dart`.

## Step 6: Update homepage / repository URLs

Edit `pubspec.yaml` and replace `srisivas` in the homepage/repository/issue_tracker URLs with your actual GitHub username (or wherever you'll host it).

If you don't have a GitHub repo yet, create one called `srik_cli` and push the code:

```bash
git init
git add .
git commit -m "Initial release v0.1.0"
git branch -M main
git remote add origin https://github.com/<your_username>/srik_cli.git
git push -u origin main
```

## Step 7: Dry-run publish

This validates everything without actually publishing:

```bash
dart pub publish --dry-run
```

Read the output carefully. It will show:
- Files that will be uploaded
- Any warnings (e.g., missing LICENSE, README too short, etc.)
- Suggestions to improve the package

Fix any warnings before continuing.

## Step 8: Authenticate with pub.dev

First-time only:

```bash
dart pub login
```

This opens a browser. Sign in with your Google account.

## Step 9: Publish

```bash
dart pub publish
```

It will show a summary and ask `y/N` to confirm. Type `y` and hit Enter.

If successful, you'll see:
```
Package has been published.
```

## Step 10: Verify it's live

Open:
```
https://pub.dev/packages/srik_cli
```

It may take a few minutes to appear. The package scoring may take an hour to compute.

## Step 11: Tag the release in git

```bash
git tag v0.1.0
git push --tags
```

## Step 12: Announce

Post in:
- r/FlutterDev on Reddit
- Flutter Discord (#sharing channel)
- Twitter/X with #FlutterDev
- LinkedIn

Example tweet:
> Just launched srik_cli — a Flutter project scaffolder that generates Clean Architecture + Riverpod apps with one command.
>
> `dart pub global activate srik_cli`
> `srik create my_app`
>
> https://pub.dev/packages/srik_cli #FlutterDev

## Common issues

### "Package validation failed"
Read the error. Usually a missing field in pubspec.yaml or an issue with the README.

### "You don't have permission to publish this package"
Someone already claimed the name. Pick another name in `pubspec.yaml`.

### "The package has 0 likes / 0 popularity"
Normal for day 1. Score builds over weeks. Focus on:
- A great README with GIFs / screenshots
- Quick responses to GitHub issues
- Writing a launch blog post

### "dart pub get fails"
Check `pubspec.yaml` constraints. Run `dart pub upgrade` to resolve to latest compatible versions.

## After launch

- Watch GitHub issues — early users will report bugs
- Plan v0.2 based on what people ask for (likely: more state mgmt options, Firebase)
- Add an animated GIF to the README showing the prompt flow
- Write a Dev.to article: "Why I built srik_cli and how to use it"

## Maintenance versioning

For minor fixes:
```bash
# Update version in pubspec.yaml: 0.1.0 → 0.1.1
# Add entry to CHANGELOG.md
dart pub publish --dry-run
dart pub publish
git tag v0.1.1 && git push --tags
```

For new features:
```bash
# 0.1.0 → 0.2.0
# Same flow
```

For breaking changes:
```bash
# 0.1.0 → 1.0.0
# Document migration in CHANGELOG
```
