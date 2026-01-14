# Mindful Path Setup Guide

Quick setup guide for developing Mindful Path.

## First-time setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Configure environment:
```bash
cp .env.example .env.development
```

3. Edit `.env.development` with your AI API key:
```
AI_API_BASE_URL=https://api.openai.com/v1
AI_API_KEY=your-openai-api-key
AI_MODEL=gpt-4o-mini
```

4. Run the app:
```bash
flutter run
```

## Environment Files

The app supports three environments:
- `.env.development` - Local development
- `.env.staging` - Testing builds
- `.env.production` - Release builds

Never commit actual API keys. Use CI/CD secrets for builds.

## AI Configuration

The app works without AI configuration but with reduced functionality:
- Journal entries won't receive AI insights
- No AI task suggestions
- No personalized breathing recommendations

To enable AI features, configure an OpenAI-compatible API in your `.env` file.

## Building

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

## Running Tests

```bash
flutter test
```

## Code Quality

### Lint and analyze:
```bash
flutter analyze
```

### Format code:
```bash
dart format lib/
```

## Pre-commit Hooks (Optional)

Install `pre-commit` framework:
```bash
pip install pre-commit
pre-commit install --config tooling/pre-commit-config.yaml
```

Or manually set up git hooks:
```bash
cp tooling/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## CI/CD

GitHub Actions workflows trigger on push and PR:
- `ci.yml` - Analyze, test, build
- `lint_format.yml` - Pre-PR checks
- `secret-scan.yml` - Prevent secret leaks
- `release.yml` - Tag-based releases

## Secrets in CI

Set in GitHub > Settings > Secrets:
- `AI_API_KEY` - OpenAI API key (for AI features)
- `SENTRY_DSN` - Error tracking (optional)
- `SIGNING_KEY_PASSWORD` - Android signing
- `APPSTORE_CONNECT_KEY` - iOS distribution

## Project Structure

```
lib/
├── core/
│   ├── models/        # JournalEntry, TodoItem, Mood, etc.
│   ├── providers/     # Riverpod providers
│   ├── services/      # StorageService, AIService
│   ├── theme/         # Colors, typography, spacing
│   ├── widgets/       # Shared components
│   └── navigation/    # go_router setup
├── features/
│   ├── home/          # Today overview
│   ├── journal/       # Journal entries
│   ├── todos/         # Task management
│   ├── breathing/     # Breathing exercises
│   └── insights/      # AI insights
└── main.dart
```

## Key Files

- `lib/core/services/ai_service.dart` - AI integration with wellbeing prompts
- `lib/core/services/storage_service.dart` - Hive local storage
- `lib/core/theme/app_theme.dart` - Material theme configuration
- `lib/core/models/` - Data models with Hive adapters

## Troubleshooting

### Hive issues
If you encounter Hive errors, try clearing the app data:
```bash
flutter clean
flutter pub get
```

### AI not working
1. Check `.env.development` has valid API key
2. Verify API endpoint is accessible
3. Check console for error messages

### Build failures
```bash
flutter clean
flutter pub get
flutter pub run build_runner build
```
