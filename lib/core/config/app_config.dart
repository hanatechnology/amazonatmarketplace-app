import 'package:flutter/foundation.dart';

/// Build-time configuration.
///
/// Every value is a compile-time constant supplied with `--dart-define` (or
/// `--dart-define-from-file=env/<flavor>.json`), so nothing environment-specific
/// is committed to Dart source and nothing readable ships inside the asset
/// bundle. The defaults below are the local development values, which keeps
/// `flutter run` working with no flags.
class AppConfig {
  const AppConfig._();

  /// Which environment this binary was built against: `dev`, `staging`, `prod`.
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  /// Root of the client API, already ending in `/client/api/v1` — repository
  /// paths stay relative (`'/products'`).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'http://localhost:3003/client/api/v1',
    defaultValue: 'https://api.marketplace.amazonatlibya.org/client/api/v1',
  );

  /// Installed version and build number, e.g. `1.0.0` and `1`. Filled once in
  /// `main()` from the platform package info — the values live in
  /// `pubspec.yaml`'s `version:` field, not in a dart-define, so they follow
  /// whatever was actually built and installed.
  static String appVersion = '';
  static String buildNumber = '';

  /// Sets [appVersion] and [buildNumber]. Called only from `main()`.
  static void setPackageInfo({
    required String version,
    required String build,
  }) {
    appVersion = version;
    buildNumber = build;
  }

  /// `1.0.0 (1)`, or `1.0.0 (1) · staging` off production so a tester can tell
  /// at a glance which backend the build points at. Empty until the platform
  /// read in `main()` completes.
  static String get versionLabel {
    if (appVersion.isEmpty) return '';
    final base = buildNumber.isEmpty
        ? appVersion
        : '$appVersion ($buildNumber)';
    return isProduction ? base : '$base · $environment';
  }

  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'prod';

  /// Explicit opt-in for a release build that needs the HTTP log, e.g. a
  /// staging APK handed to QA.
  static const bool _forceHttpLogs = bool.fromEnvironment('ENABLE_HTTP_LOGS');

  /// Request and response bodies carry the bearer token and customer data, so
  /// the log is off in release unless [_forceHttpLogs] turns it back on.
  static bool get enableHttpLogs => _forceHttpLogs || !kReleaseMode;
}
