# camara_moviles2

Flutter project (single package). Default counter app scaffold.

## Commands

```bash
# Analyze (lint)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Run the app (pick device/emulator)
flutter run
```

## Entrypoint

- `lib/main.dart` — app entry, `main()` calls `runApp(MyApp())`.
- `test/widget_test.dart` — smoke test for counter widget.

## Analysis

Lint rules come from `package:flutter_lints/flutter.yaml`. Configured in `analysis_options.yaml`.

## Targets

Android (`android/`), Web (`web/`). iOS and desktop targets may be added later.
