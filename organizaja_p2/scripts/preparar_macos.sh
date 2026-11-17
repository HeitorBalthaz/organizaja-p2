#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter create --project-name organizaja --platforms=android,ios,web .
if [ -f android/app/src/main/AndroidManifest.xml ]; then
  perl -0pi -e 's/<application(?![^>]*android:allowBackup=)/<application android:allowBackup="false"/' android/app/src/main/AndroidManifest.xml
fi
flutter pub get
dart run sqflite_common_ffi_web:setup
printf '\nProjeto preparado. Chrome: flutter run -d chrome --web-port 8080\n'
