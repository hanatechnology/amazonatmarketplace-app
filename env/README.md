# Build environments

`API_BASE_URL` and `ENV` are compile-time `String.fromEnvironment` values read by
`lib/core/config/app_config.dart`. Pick one with:

```
flutter run   --dart-define-from-file=env/staging.json
flutter build apk    --release --dart-define-from-file=env/staging.json
flutter build appbundle --release --dart-define-from-file=env/prod.json
```

The base URL already ends in `/client/api/v1`; repository paths stay relative.

Secrets do **not** belong here — these files are committed and a dart-define is
recoverable from the binary. The Google Maps key is a native lookup and is
supplied separately (`android/local.properties`, `ios/Flutter/Secrets.xcconfig`).
