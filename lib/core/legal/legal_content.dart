import 'package:get/get.dart';

import 'legal_content_ar.dart';
import 'legal_content_en.dart';
import 'legal_document.dart';

export 'legal_content_ar.dart' show supportEmail, supportPhone;
export 'legal_document.dart';

/// The policy text for the language the app is showing right now.
///
/// Resolved on every read rather than cached: switching language must swap the
/// document under the reader, and a value captured when the screen opened would
/// leave the old wording on a screen whose chrome had already flipped.
LegalDocument legalDocument(LegalDocumentKind kind) {
  final isArabic = Get.locale?.languageCode == 'ar';

  return switch (kind) {
    LegalDocumentKind.privacyPolicy =>
      isArabic ? privacyPolicyAr : privacyPolicyEn,
    LegalDocumentKind.termsOfService =>
      isArabic ? termsOfServiceAr : termsOfServiceEn,
  };
}
