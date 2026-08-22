import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// Money formatting for prices and order totals.
///
/// Everything on the marketplace is priced in Libyan Dinar. Fraction digits are
/// pinned at 2 rather than LYD's nominal 3, so every amount in the app lines up
/// — same choice the web client makes.
///
/// Grouping is done by hand instead of via `intl`: the package is not a
/// dependency of this app, and a currency string is not worth pulling one in.
abstract class PriceFormatter {
  PriceFormatter._();

  static const String defaultCurrency = 'LYD';
  static const String _arabicDinarSymbol = 'د.ل';

  static String format(num amount, {String? currency}) {
    final code = (currency ?? defaultCurrency).toUpperCase();
    final isArabic = Get.locale?.languageCode == 'ar';
    final value = _group(amount);

    // Only the local currency gets a symbol; a gateway currency (Stripe settles
    // in USD) is shown as its code so it can never be mistaken for dinars.
    if (isArabic && code == defaultCurrency) {
      return '$value $_arabicDinarSymbol';
    }
    return '$code $value';
  }

  /// Formats a decimal string straight off the wire. Unparseable input is
  /// returned as-is rather than shown as a wrong number.
  static String formatString(String amount, {String? currency}) {
    final parsed = double.tryParse(amount);
    if (parsed == null) return amount;
    return format(parsed, currency: currency);
  }

  /// `1234.5` → `1,234.50`
  static String _group(num amount) {
    final fixed = amount.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    final digits = parts.first;

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }

    final sign = amount.isNegative ? '-' : '';
    return '$sign$buffer.${parts.last}';
  }
}
