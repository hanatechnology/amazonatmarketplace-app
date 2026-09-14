import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// Date rendering for order history and similar lists.
///
/// Written by hand rather than via `intl`, which this app does not depend on.
/// Month names are carried for both locales so a date reads natively in either.
abstract class DateFormatter {
  DateFormatter._();

  static const List<String> _monthsEn = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _monthsAr = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  /// `12 Mar 2026` / `12 مارس 2026`
  static String mediumDate(DateTime date) {
    final local = date.toLocal();
    final months =
        Get.locale?.languageCode == 'ar' ? _monthsAr : _monthsEn;
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  /// `10:51 AM` / `10:51 ص` from a wire time like `10:51:00`.
  ///
  /// The API sends pickup windows as bare `HH:mm:ss` strings — no date, no
  /// zone — so there is nothing to convert here, only to re-render. Input that
  /// does not parse is returned untouched rather than shown as a wrong time.
  ///
  /// The figure stays Latin in both languages; only the meridiem is localised
  /// (`ص` before noon, `م` after), and the caller renders the whole token LTR
  /// so the range does not reverse inside Arabic.
  static String? timeOfDay(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;

    final parts = value.split(':');
    if (parts.length < 2) return value;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return value;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return value;

    final isArabic = Get.locale?.languageCode == 'ar';
    final isMorning = hour < 12;
    final meridiem = isMorning ? (isArabic ? 'ص' : 'AM') : (isArabic ? 'م' : 'PM');

    // 0 and 12 both map to 12 — midnight is 12 AM, noon is 12 PM.
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    return '$hour12:${minute.toString().padLeft(2, '0')} $meridiem';
  }

  /// Wraps a token in a left-to-right isolate.
  ///
  /// An Arabic meridiem (`\u0635` / `\u0645`) is a strong RTL letter, so a bare
  /// `12:00 \u0645  -  5:00 \u0645` reorders under the bidi algorithm even inside an
  /// LTR-directed `Text`: the meridiems and the dash resolve into one RTL run
  /// and the range comes out as `12:00\u0645 5:00 - \u0645`. Isolating each end
  /// keeps its digits and its meridiem together, in that order.
  static String _ltrIsolate(String value) => '\u2066$value\u2069';

  /// `10:00 AM  -  1:00 PM`.
  ///
  /// Collapses to a single time when both ends are equal: the backend stores a
  /// zero-width window that way, and "10:51 AM – 10:51 AM" reads as a bug.
  static String? timeRange(String? from, String? to) {
    final start = timeOfDay(from);
    final end = timeOfDay(to);
    if (start == null) return end == null ? null : _ltrIsolate(end);
    if (end == null || end == start) return _ltrIsolate(start);
    return '${_ltrIsolate(start)}  -  ${_ltrIsolate(end)}';
  }

  /// Same as [mediumDate] with the time appended, for detail screens.
  static String dateWithTime(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${mediumDate(local)} · $hour:$minute';
  }
}
