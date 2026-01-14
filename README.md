# Mobile Cross-platform App

Production-ready scaffold using Flutter for iOS and Android.

## Overview

This workspace uses Flutter (stable) to maintain a single codebase for iOS and Android with a clean, modular architecture and CI/CD readiness.

## Getting started

Prerequisites:
- Flutter SDK (>=3.0)
- Xcode (for iOS builds)
- Android SDK & Android Studio (for Android builds)

1. Install dependencies
```bash
flutter pub get
```

2. Run app
```bash
flutter run
```

3. Run tests
```bash
flutter test
```

4. Lint & format
```bash
dart analyze
dart format .
```
## Environments
Three environments are prepared: `development`, `staging`, `production`.
Use `.env.development`, `.env.staging`, `.env.production` locally (not checked into git).

CI systems should inject secrets via secure variables.

Configuration is managed in `lib/core/config/app_config.dart`.

## CI/CD
- GitHub Actions for build and tests
- Fastlane configured for iOS and Android lane stubs

## Hooks & Quality
Pre-commit hooks are configured to run format, analyze and tests. Use Husky or `pre-commit` to install locally (see `.gitattributes` and project scripts).

## Scripts
- `scripts/build_android.sh` - build Android APK
- `scripts/build_ios.sh` - build iOS IPA

## Environments & Secrets
- Never commit `.env` files with real secrets. Use CI/CD secure variables or platform secret stores.
- Example env file: `.env.example`

> Tip: For production secrets use your CI secret store and platform keychain (Google Play/App Store Connect). Keep only non-sensitive config in `.env` files.
## Project structure
- `lib/` - app source
- `test/` - tests
- `ios/`, `android/` - native platforms

## Scripts
- `scripts/build_ios.sh` - iOS build (CI-friendly)
- `scripts/build_android.sh` - Android build (CI-friendly)

## Notes
This is an initial scaffold. Add your features, auth, API integration, and notifications as needed.

## Architecture Overview

```
lib/
├── core/          # Shared: widgets, config, app setup
├── features/      # Feature modules (example/)
│   └── example/
│       ├── presentation/  (UI/screens)
│       ├── domain/        (business logic, repositories)
│       └── data/          (API/data sources)
└── main.dart

test/
├── widget_test.dart       (example test)
└── unit/                  (add unit tests)

scripts/
├── build_android.sh
├── build_ios.sh
└── (CI scripts)

.github/workflows/
├── ci.yml              (test, analyze, build)
├── lint_format.yml     (pre-PR checks)
├── release.yml         (tag-based releases)
└── secret-scan.yml     (prevent secret leaks)
```

## Next Steps
1. Clone/fork this repo
2. Add authentication (Firebase, custom)
3. Implement API client (http, dio)
4. Build features
5. Add push notifications (Firebase Cloud Messaging)
6. Configure code signing & provisioning profiles
7. Set up App Store Connect & Google Play Console secrets in CI
