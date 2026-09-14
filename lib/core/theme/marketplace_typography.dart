import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'marketplace_colors.dart';

/// Text styles for the Marketplace UI.
///
/// Body/UI text is Plus Jakarta Sans (400/500/600/700). Display text — hero
/// headlines, section titles, prices — is Instrument Serif, which is what gives
/// the redesigned screens their editorial feel. Neither face ships Arabic
/// glyphs, so [fontFamilyFallback] keeps Arabic rendering on the bundled Inter
/// and then the platform default.
abstract class MarketplaceTypography {
  MarketplaceTypography._();

  /// Body / UI face.
  static const String fontFamily = 'PlusJakartaSans';

  /// Display face — headlines, section titles, prices. Regular weight only;
  /// never ask it for a bold, it has none and the synthetic one is ugly.
  static const String displayFamily = 'InstrumentSerif';

  /// Arabic body face. Neither Plus Jakarta Sans nor Inter carries Arabic, so
  /// this is what actually renders every Arabic string in the app.
  static const String arabicFontFamily = 'IBMPlexSansArabic';

  /// Arabic display face — the naskh counterpart to [displayFamily].
  static const String arabicDisplayFamily = 'Amiri';

  /// Resolution order for body text: Latin face first, then Arabic, then Inter.
  static const List<String> fontFamilyFallback = [arabicFontFamily, 'Inter'];

  /// Resolution order for display text. Instrument Serif has no Arabic, so
  /// Arabic headlines land on Amiri and keep their editorial weight.
  static const List<String> displayFontFamilyFallback = [
    arabicDisplayFamily,
    arabicFontFamily,
  ];

  // ── Screen Titles (24px) ─────────────────────────────────
  /// Screen titles — "Details", "My Cart", "My Order"
  static const TextStyle screenTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 24, fontWeight: FontWeight.w600,
    height: 1.0, color: MarketplaceColors.primary,
  );

  /// Product name on detail screen
  static const TextStyle productTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 24, fontWeight: FontWeight.w600,
    height: 1.0, color: MarketplaceColors.textBody,
  );

  /// Large price display on detail screen
  static const TextStyle priceTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 24, fontWeight: FontWeight.w500,
    height: 1.0, color: MarketplaceColors.textBody,
  );

  // ── Section Headings (16px) ──────────────────────────────
  /// "Category", "Popular Product" on Home
  static const TextStyle sectionHeading = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 16, fontWeight: FontWeight.w600,
    color: MarketplaceColors.textPrimary,
  );

  /// "Description", "Reviews & Rating", profile name, "My Account"
  static const TextStyle sectionSubheading = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 16, fontWeight: FontWeight.w500,
    color: MarketplaceColors.textBody,
  );

  /// Profile menu items, body text
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 16, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textBody,
  );

  /// CTA button labels — "Add To Cart", "CheckOut"
  /// Carries no colour of its own. A baked-in white here beat every button's
  /// `foregroundColor`, which in dark mode painted white text on the light lime
  /// brand fill — legible in neither theme by accident. Buttons set their own
  /// `foregroundColor`; this style only sets the type.
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 16, fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// Cart item count "3 Items", "Select All"
  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 16, fontWeight: FontWeight.w600,
    color: MarketplaceColors.textSecondary,
  );

  /// Seller name on detail, price summary labels
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 16, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textSecondary,
  );

  /// Old price with strikethrough
  static const TextStyle priceStrikethrough = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 16, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textBody, decoration: TextDecoration.lineThrough,
  );

  // ── Description (13px) ───────────────────────────────────
  /// Description body, banner subtitle
  static const TextStyle descriptionBody = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 13, fontWeight: FontWeight.w400,
    height: 1.4, color: MarketplaceColors.textSecondary,
  );

  // ── Card / Compact (12px) ────────────────────────────────
  /// Product card names, tab bar labels
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 12, fontWeight: FontWeight.w500,
    height: 1.0, color: MarketplaceColors.textBody,
  );

  /// Seller name on cards, prices, location text
  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.0, color: MarketplaceColors.textSecondary,
  );

  /// Price text on product card
  static const TextStyle cardPrice = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.0, color: MarketplaceColors.textBody,
  );

  /// Rating number "4.2" next to star
  static const TextStyle cardRating = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 12, fontWeight: FontWeight.w500,
    height: 1.0, color: MarketplaceColors.textSecondary,
  );

  /// "Add to cart" small card button text
  static const TextStyle smallButton = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.0, color: MarketplaceColors.onPrimary,
  );

  /// Search placeholder, category labels
  static const TextStyle inputPlaceholder = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.0, color: MarketplaceColors.textSecondary,
  );

  /// Bottom nav active/inactive labels
  static const TextStyle navLabel = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 12, fontWeight: FontWeight.w500,
    height: 1.0,
  );

  /// Banner title "New Collection"
  static const TextStyle bannerTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 16, fontWeight: FontWeight.w600,
    color: MarketplaceColors.textPrimary,
  );

  /// Banner subtitle "Discount 20%..."
  static const TextStyle bannerSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 13, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textMuted,
  );

  /// "Shop now" CTA inside banner
  static const TextStyle bannerCta = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 12, fontWeight: FontWeight.w600,
    color: MarketplaceColors.onPrimary,
  );

  // ── Micro (10px) ─────────────────────────────────────────
  /// Discount badge, review body, strikethrough card price
  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 10, fontWeight: FontWeight.w400,
    height: 1.4, color: MarketplaceColors.textBody,
  );

  /// Quantity number in stepper (detail screen)
  static const TextStyle quantityNumber = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 16, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textBody,
  );

  /// Quantity in cart (compact)
  static const TextStyle cartQuantity = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 14, fontWeight: FontWeight.w500,
    color: MarketplaceColors.textBody,
  );

  // ── Heading Aliases ─────────────────────────────────────────
  /// Alias for screenTitle (h4 heading style)
  static const TextStyle h4 = screenTitle;

  /// Alias for sectionHeading (h5 heading style)
  static const TextStyle h5 = sectionHeading;

  /// "See All" link — 14px Medium in primary green
  static const TextStyle seeAll = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback, fontSize: 14, fontWeight: FontWeight.w500,
    color: MarketplaceColors.primary,
  );

  // ── Display / editorial ──────────────────────────────────
  // Getters, not consts: Amiri needs more leading than Instrument Serif, and
  // has no italic, so these resolve against the active locale. Callers still
  // write `MarketplaceTypography.heroDisplay.copyWith(color: ...)`.

  static bool get isArabic => Get.locale?.languageCode == 'ar';

  /// Arabic display text clips its dots and descenders at Latin leading.
  static double _leading(double latin, double arabic) =>
      isArabic ? arabic : latin;

  static TextStyle get _displayBase => TextStyle(
        fontFamily: displayFamily,
        fontFamilyFallback: displayFontFamilyFallback,
        fontWeight: FontWeight.w400,
      );

  /// Hero headline over banner artwork.
  static TextStyle get heroDisplay =>
      _displayBase.copyWith(fontSize: 31, height: _leading(1.05, 1.4));

  /// Italic emphasis inside [heroDisplay]. Amiri ships no italic — Arabic keeps
  /// the upright face rather than a synthesised slant.
  static TextStyle get heroDisplayEmphasis => _displayBase.copyWith(
        fontSize: 31,
        height: _leading(1.05, 1.4),
        fontStyle: isArabic ? FontStyle.normal : FontStyle.italic,
      );

  /// Section title — "New arrivals", "Featured stores".
  static TextStyle get sectionDisplay =>
      _displayBase.copyWith(fontSize: 24, height: _leading(1.0, 1.38));

  /// Price on a rail/grid card. Figures stay Latin in both locales, so this
  /// needs only a little extra room.
  static TextStyle get priceDisplay =>
      _displayBase.copyWith(fontSize: 17, height: _leading(1.0, 1.2));

  /// Wordmark in the home header — always Latin, never localised.
  static const TextStyle wordmark = TextStyle(
    fontFamily: displayFamily,
    fontSize: 21,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: 0.3,
  );

  /// Italic half of the wordmark.
  static const TextStyle wordmarkEmphasis = TextStyle(
    fontFamily: displayFamily,
    fontSize: 21,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: 0.3,
    fontStyle: FontStyle.italic,
  );

  // ── Labels ───────────────────────────────────────────────
  // Also getters: Arabic sits taller in the same box, and tracking that reads
  // as elegant in Latin caps only smears an Arabic string, so it is dropped.

  static double _tracking(double latin) => isArabic ? 0 : latin;

  static TextStyle get _labelBase => TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      );

  /// Tracked uppercase kicker — "NEW COLLECTION".
  static TextStyle get labelCaps => _labelBase.copyWith(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        height: _leading(1.2, 1.5),
        letterSpacing: _tracking(1.7),
      );

  /// Tracked uppercase action link — "SEE ALL".
  static TextStyle get linkCaps => _labelBase.copyWith(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        height: _leading(1.2, 1.5),
        letterSpacing: _tracking(1.2),
      );

  /// Category pill label.
  static TextStyle get pillLabel => _labelBase.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        height: _leading(1.2, 1.5),
      );

  /// Product title on a rail/grid card.
  static TextStyle get cardHeading => _labelBase.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        height: _leading(1.25, 1.5),
      );

  /// Store or order name in a row.
  static TextStyle get rowTitle => _labelBase.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        height: _leading(1.25, 1.5),
      );

  /// Supporting line under a card or row title.
  static TextStyle get rowMeta => _labelBase.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        height: _leading(1.3, 1.55),
      );

  /// Currency suffix beside a [priceDisplay].
  static TextStyle get priceUnit => _labelBase.copyWith(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        height: 1.0,
      );

  /// Floating bottom-nav label.
  static TextStyle get navLabelSmall => _labelBase.copyWith(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        height: _leading(1.0, 1.35),
        letterSpacing: _tracking(0.3),
      );
}
