# SETUP.md

Quick setup guide.

## First-time setup

```bash
cd mobile-crossplatform-app
flutter pub get
flutter run
```

## Environment files

Copy `.env.example` to `.env.development`:
```bash
cp .env.example .env.development
```

Edit with your settings:
```
API_BASE_URL=https://api.dev.example.com
```

## Pre-commit hooks (optional)

Install `pre-commit` framework (requires Python):
```bash
pip install pre-commit
pre-commit install --config tooling/pre-commit-config.yaml
```

Or manually setup git hooks:
```bash
cp tooling/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Build locally

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ipa
# Output: build/ios/ipa/*.ipa
```

## CI/CD

Workflows automatically trigger on push and PR:
- `ci.yml` - analyze, test, build
- `lint_format.yml` - pre-PR checks
- `secret-scan.yml` - prevent secret leaks
- `release.yml` - tag-based releases

## Secrets in CI

Set in GitHub > Settings > Secrets:
- `SENTRY_DSN`
- `SIGNING_KEY_PASSWORD`
- `APPSTORE_CONNECT_KEY` (base64)
- Platform-specific keys for Google Play, Apple

Reference in workflows:
```yaml
env:
  SENTRY_DSN: ${{ secrets.SENTRY_DSN }}
```
