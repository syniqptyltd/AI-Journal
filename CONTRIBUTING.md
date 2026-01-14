## Contributing

1. Clone the repo
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit with clear messages: `git commit -m "feat: add my feature"`
4. Pre-commit checks run automatically (format, analyze)
5. Open a PR; CI runs all checks
6. Once approved and passing, merge and CI auto-builds

## Code Style

- Format with `dart format .`
- Lint with `flutter analyze`
- Follow Dart conventions (lowercase_with_underscores for files, PascalCase for classes)

## Testing

- Unit tests in `test/`
- Widget tests in `test/`
- Run: `flutter test`

## Release

Tag a release: `git tag v0.2.0 && git push --tags`
GitHub Actions `release.yml` automatically builds APK and IPA.
