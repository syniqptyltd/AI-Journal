## Architecture Decision Records

### 1. Flutter for Cross-Platform
- Single codebase for iOS and Android reduces maintenance.
- Strong ecosystem (Provider, GetX for state, Firebase, etc.).
- Proven for production apps.

### 2. Clean Architecture + Feature Modules
- Features isolated in `lib/features/`.
- Each feature has `presentation/`, `domain/`, `data/` layers.
- Clear separation of concerns, easier testing and scaling.

### 3. Provider for State Management
- Lightweight and production-ready.
- Can be extended to GetIt or Riverpod if needed later.

### 4. Environment Handling
- `.env` files (not in Git) for local development.
- CI injects secrets via secure variables.
- `lib/core/config/app_config.dart` centralizes config.

### 5. GitHub Actions for CI/CD
- Native to GitHub (no external setup).
- Clear workflows for test, build, release.
- Secret scanning built in.

### 6. Fastlane for Build Automation
- Standardizes iOS and Android builds.
- Integrates with TestFlight, Google Play.

### 7. Pre-commit Hooks
- `dart format`, `flutter analyze` run before each commit.
- Prevents poorly formatted or invalid code from being committed.

### Future Enhancements
- Add Firebase for auth, notifications, analytics.
- Use GetIt for more advanced DI.
- Add Riverpod or Bloc for complex state.
- Integration tests with `integration_test/`.
