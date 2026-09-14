import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// Picks backend copy for the language the app is showing right now, falling
/// back to the other language rather than rendering nothing when only one side
/// was filled in. Returns null when neither was.
///
/// Call this from an entity getter, not from `toEntity()`: resolving at parse
/// time freezes the text in whatever language was active when the response
/// landed, so a mid-session language switch leaves the old wording on screen.
String? localizedCopy(String? ar, String? en) {
  final isArabic = Get.locale?.languageCode == 'ar';
  final preferred = (isArabic ? ar : en) ?? '';
  if (preferred.isNotEmpty) return preferred;
  final fallback = (isArabic ? en : ar) ?? '';
  return fallback.isEmpty ? null : fallback;
}
