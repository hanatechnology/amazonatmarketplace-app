import 'package:get/get.dart';
import 'package:marketplace/core/localization/locale_keys.dart';

/// Formats a timestamp as a short localized relative label ("3 h ago").
/// Mirrors the web client's `formatRelativeTime`, using the app's own
/// translation keys so it stays consistent in Arabic.
String formatRelativeTime(DateTime timestamp) {
  final seconds = DateTime.now().difference(timestamp).inSeconds;

  // Clock skew or a future-dated notification — treat as brand new.
  if (seconds < 60) return LocaleKeys.timeJustNow.tr;

  final minutes = seconds ~/ 60;
  if (minutes < 60) return _plural(LocaleKeys.timeMinutesAgo, minutes);

  final hours = minutes ~/ 60;
  if (hours < 24) return _plural(LocaleKeys.timeHoursAgo, hours);

  final days = hours ~/ 24;
  if (days < 7) return _plural(LocaleKeys.timeDaysAgo, days);

  final weeks = days ~/ 7;
  if (days < 30) return _plural(LocaleKeys.timeWeeksAgo, weeks);

  final months = days ~/ 30;
  if (days < 365) return _plural(LocaleKeys.timeMonthsAgo, months);

  return _plural(LocaleKeys.timeYearsAgo, days ~/ 365);
}

String _plural(String key, int count) =>
    key.trParams({'count': count.toString()});
