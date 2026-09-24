/// Which policy a screen is showing.
enum LegalDocumentKind { privacyPolicy, termsOfService }

/// One numbered clause: a heading, optional prose, optional bulleted items.
class LegalSection {
  const LegalSection({
    required this.title,
    this.paragraphs = const <String>[],
    this.bullets = const <String>[],
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}

/// A policy as the app renders it.
///
/// The text is long-form prose that only ever appears on one screen, so it
/// lives here as structured content rather than as a hundred flat translation
/// keys: a policy is edited as a document, and keeping it as one keeps the
/// Arabic and English versions legible side by side when the wording changes.
/// Everything else on the screen — its title bar, the back control — still goes
/// through `LocaleKeys`.
class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.intro,
    required this.sections,
    required this.lastUpdated,
  });

  final String title;

  /// Standfirst above the first clause.
  final String intro;

  final List<LegalSection> sections;

  /// Human-readable month and year this wording was last revised. Shown so the
  /// customer can tell one version of the policy from another.
  final String lastUpdated;
}
