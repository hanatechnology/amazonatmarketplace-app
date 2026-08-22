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

  /// Same as [mediumDate] with the time appended, for detail screens.
  static String dateWithTime(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${mediumDate(local)} · $hour:$minute';
  }
}
