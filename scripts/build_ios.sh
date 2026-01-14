#!/usr/bin/env bash
set -euo pipefail

# CI-friendly iOS build script
flutter pub get
flutter build ipa --export-options-plist=ios/ExportOptions.plist
echo "Built iOS IPA: build/ios/ipa/*.ipa"
