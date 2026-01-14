#!/usr/bin/env bash
set -euo pipefail

# CI-friendly Android build script
flutter pub get
flutter build apk --release
echo "Built Android APK: build/app/outputs/flutter-apk/app-release.apk"
