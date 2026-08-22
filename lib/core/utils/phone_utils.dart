/// Libyan phone handling. The API treats the phone number as the customer's
/// primary identity and expects E.164 (`+218XXXXXXXXX`), so the same value has
/// to reach both `request-otp` and `verify-otp` — normalizing at the edge keeps
/// the two calls in agreement no matter how the user typed it.
abstract class PhoneUtils {
  PhoneUtils._();

  static const String countryCode = '+218';
  static const String _digits = '218';

  /// National subscriber number length, excluding the country code.
  static const int nationalLength = 9;

  /// Converts any of `0912345678`, `912345678`, `218912345678`, `+218 91 234
  /// 5678` into `+218912345678`. Input that cannot be interpreted is returned
  /// trimmed, so validation — not normalization — decides what is acceptable.
  static String normalize(String input) {
    final cleaned = input.replaceAll(RegExp(r'\D'), '');
    if (cleaned.isEmpty) return input.trim();

    if (cleaned.startsWith(_digits)) return '+$cleaned';
    if (cleaned.startsWith('0')) return '$countryCode${cleaned.substring(1)}';
    if (cleaned.length == nationalLength) return '$countryCode$cleaned';
    return '$cleaned';
  }

  static bool isValid(String input) =>
      RegExp(r'^\+218[0-9]{9}$').hasMatch(normalize(input));

  /// Groups the national part for display: `+218 91 234 5678`.
  static String forDisplay(String input) {
    final normalized = normalize(input);
    if (!isValid(normalized)) return input;

    final national = normalized.substring(countryCode.length);
    return '$countryCode ${national.substring(0, 2)} '
        '${national.substring(2, 5)} ${national.substring(5)}';
  }
}
