<!-- Copilot instructions for G11 Frontend Flutter project -->
# Project-specific Copilot Instructions

This file gives concise, actionable guidance for AI coding agents working on this Flutter app.

- Purpose: `smart_clearance_app` is a Flutter frontend (see `lib/`) split by role: `lib/screens/admin`, `lib/screens/faculty`, and `lib/screens/auth`.
- Entry point: `lib/main.dart` — routes are registered here (initialRoute is `/login`). When adding pages, register them in `main.dart`'s `routes` map.

- Dart/Flutter versions: `pubspec.yaml` specifies SDK `^3.9.2`. Keep code compatible with Dart 3.9.x and current Flutter stable.
- Lints: `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`. Run `flutter analyze` and follow lint rules.

- Assets: Declared in `pubspec.yaml` (`assets/sdca_logo.png`). Any added asset must be listed in `pubspec.yaml`.

- Project conventions (follow these exactly):
  - UI pages live under `lib/screens/<role>` (e.g. `admin`, `faculty`, `auth`).
  - Small, focused widgets go in the same folder as the page that uses them.
  - Use `const` constructors when possible (project currently favors const usage in `main.dart`).
  - Navigation is string-route based (e.g. `"/dashboard"`, `"/login"`); keep names stable when refactoring.

- Build & run (Windows PowerShell):
  - Install deps: `flutter pub get`
  - Analyze: `flutter analyze`
  - Run on device: `flutter run -d <device-id>` (use `flutter devices` to list)
  - Run tests: `flutter test`
  - Build APK: `flutter build apk`
  - Android gradle (CI or manual Windows): `cd android; .\gradlew.bat assembleRelease`
  - iOS: use Xcode / `flutter build ios` on macOS (not applicable on Windows).

- What to edit vs what to avoid:
  - Edit: `lib/` (UI, models, helpers), `assets/`, `pubspec.yaml` (when adding packages/assets).
  - Avoid changing: generated platform files under `build/`, `ios/Runner/*.xcodeproj` unless required for native changes, and Gradle wrapper files unless fixing build issues.

- Testing & verification:
  - After changes: run `flutter analyze`, `flutter test`, and `flutter run` locally.
  - If adding routes, manually open the app and navigate to the new route to verify UI and state.

- Patterns discovered in codebase (examples):
  - Route registration: `MaterialApp(routes: { "/login": (c)=> const LoginPage(), ... })` in `lib/main.dart`.
  - Screen grouping: faculty pages like `lib/screens/faculty/dashboard_page.dart` and `profile_page.dart` follow the page-per-file pattern.

- When adding dependencies:
  - Update `pubspec.yaml` and run `flutter pub get`.
  - Prefer well-maintained packages and keep transitive changes minimal.

- Commit & PR guidance for AI-generated changes:
  - Keep commits small and focused (one feature/fix per PR).
  - Include the device/Flutter version and test steps in the PR description.

If anything above is unclear or you want more specific rules (naming conventions, state management patterns, test coverage targets), tell me which area to expand.
