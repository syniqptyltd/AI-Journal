# Mindful Path

An AI-powered journaling and wellbeing app for mindful living. Built with Flutter for iOS and Android.

## Overview

Mindful Path combines traditional journaling with AI-driven insights to help users reflect, understand patterns, and take small actions to feel better. The AI acts as a supportive guide, never a therapist.

## Features

### Journal
- Create, edit, and delete daily journal entries
- Timestamped entries with optional mood selection
- AI-powered theme detection and gentle insights
- Free-text writing with a calm, distraction-free interface

### To-Do List
- Create and manage tasks
- AI-suggested tasks based on journal content
- Tasks can be linked to journal entries
- Priority levels and completion tracking

### AI Integration
- Analyzes journal entries for themes (stress, motivation, fatigue, etc.)
- Generates supportive, non-judgmental insights
- Suggests actionable items and breathing exercises
- Never provides medical or diagnostic advice

### Breathing & Grounding Exercises
- Guided breathing exercises (4-4-6, box breathing, 4-7-8)
- Beautiful animations and timers
- 5-4-3-2-1 grounding exercise
- AI can suggest exercises based on mood

### Insights Dashboard
- Weekly mood distribution
- Theme tracking over time
- Journaling streaks
- AI-generated weekly reflections

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0)
- Xcode (for iOS builds)
- Android SDK & Android Studio (for Android builds)

### Installation

1. Install dependencies
```bash
flutter pub get
```

2. Configure environment
```bash
cp .env.example .env.development
```

Edit `.env.development` with your settings:
```
AI_API_BASE_URL=https://api.openai.com/v1
AI_API_KEY=your-api-key-here
AI_MODEL=gpt-4o-mini
```

3. Run the app
```bash
flutter run
```

### Running Tests
```bash
flutter test
```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ipa
```

## Architecture

```
lib/
├── core/
│   ├── models/          # Data models (JournalEntry, TodoItem, Mood, etc.)
│   ├── providers/       # Riverpod providers
│   ├── services/        # Storage and AI services
│   ├── theme/           # Colors, typography, spacing
│   ├── widgets/         # Shared UI components
│   └── navigation/      # App routing
├── features/
│   ├── home/            # Home screen with today overview
│   ├── journal/         # Journal feature
│   ├── todos/           # To-do list feature
│   ├── breathing/       # Breathing exercises
│   └── insights/        # AI insights dashboard
└── main.dart            # App entry point
```

### Key Technologies
- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management
- **Hive** - Local-first data storage
- **go_router** - Navigation
- **flutter_animate** - Smooth animations

## AI Configuration

The app supports any OpenAI-compatible API. Configure in `.env.development`:

```env
AI_API_BASE_URL=https://api.openai.com/v1
AI_API_KEY=your-key-here
AI_MODEL=gpt-4o-mini
```

The AI service uses carefully crafted prompts to ensure:
- Supportive, non-judgmental language
- No medical or diagnostic advice
- Focus on gentle observations and small actions
- Encouragement of self-compassion

## Data & Privacy

- All journal data is stored locally using Hive
- AI requests only send necessary text for analysis
- No data is shared with third parties
- Prepared for future encryption support

## Design Philosophy

- **Calm & Minimal** - Soft colors, smooth transitions, no clutter
- **Emotionally Safe** - Supportive language throughout
- **Local-First** - Your data stays on your device
- **Progressive AI** - Works without AI, enhanced with it

## Color Palette

The app uses calming, accessible colors:
- Primary: Sage Green (#7BA38E)
- Secondary: Lavender (#B4A7D6)
- Background: Warm White (#F8F6F4)
- Mood colors are soft and non-jarring

## Extending the App

The modular architecture makes it easy to add:
- Push notifications for journaling reminders
- Streak tracking and achievements
- Cloud sync (Firebase, custom backend)
- Additional breathing exercises
- Meditation timers
- Export functionality

## Environment Configuration

Three environments are supported:
- `development` - Local development
- `staging` - Testing builds
- `production` - Release builds

Use `.env.development`, `.env.staging`, `.env.production` locally.
CI systems should inject secrets via secure variables.

## CI/CD

- GitHub Actions for automated builds and tests
- Fastlane configured for iOS and Android
- Secret scanning to prevent credential leaks
- Pre-commit hooks for code quality

## Scripts

- `scripts/build_android.sh` - Build Android APK
- `scripts/build_ios.sh` - Build iOS IPA

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

See [LICENSE](LICENSE) for details.
