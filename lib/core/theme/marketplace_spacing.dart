/// Spacing and dimension constants from Figma measurements.
abstract class MarketplaceSpacing {
  MarketplaceSpacing._();

  // ── Spacing scale ────────────────────────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ── Screen-level ─────────────────────────────────────────
  static const double screenPaddingH = 16.0;
  static const double screenTopOffset = 52.0;

  // ── Component gaps ───────────────────────────────────────
  static const double sectionGap = 16.0;
  static const double productGridGap = 16.0;
  static const double categoryGap = 16.0;
  static const double cartItemGap = 16.0;
  static const double menuItemGap = 16.0;

  // ── Component dimensions ─────────────────────────────────
  static const double bottomNavHeight = 56.0;
  static const double buttonHeight = 48.0;
  static const double smallButtonHeight = 28.0;
  static const double searchBarHeight = 48.0;
  static const double filterButtonSize = 48.0;

  /// Canonical product image ratio, width / height.
  ///
  /// 4:5 portrait. Every surface that shows a product photo — grid card,
  /// details hero, fullscreen gallery — frames it in this box, so the same
  /// photograph is composed the same way wherever the customer meets it.
  /// Vendors should upload at this ratio; anything else is letterboxed rather
  /// than cropped, so nothing of the product is ever cut away.
  static const double productImageAspectRatio = 4 / 5;

  /// Inset between the photo plate's edge and the photo inside it. The photo
  /// is laid in with `contain`, so this is breathing room, not a crop.
  static const double productCardImagePadding = 9.0;

  /// Everything below the photo plate, summed rather than guessed:
  /// 10 gap + 38 two-line name + 4 + 16 seller + 9 + 44 add row.
  ///
  /// The name and seller boxes are sized for Arabic leading, which is taller
  /// than Latin — a box that fits English clips `IBM Plex Sans Arabic`. The
  /// plate is the part that flexes, so an underestimate here shortens the
  /// photo; it never overflows the card.
  static const double productCardInfoHeight = 102.0;

  /// One line of `cardHeading`, at the Arabic leading — Arabic sets taller
  /// than Latin, so a box cut to the Latin line clips it. A product name that
  /// does not fit ends in an ellipsis rather than stealing a second line: two
  /// lines made every card in the grid pay for the longest name in it.
  static const double productCardNameHeight = 19.0;
  static const double productCardSellerHeight = 16.0;

  /// The add button's row. 44 so the tap target clears the platform minimum
  /// even though the painted circle is 36.
  static const double productCardAddRowHeight = 44.0;

  static const double productCardWidth = 164.0;

  /// Derived, not chosen: a 4:5 photo plate plus the fixed info block beneath
  /// it. Every grid feeds this straight into `childAspectRatio`, so changing
  /// the ratio or the info block re-lays every product grid in the app.
  static const double productCardHeight =
      productCardWidth / productImageAspectRatio + productCardInfoHeight;
  static const double productImageHeight = 119.0;
  static const double bannerHeight = 146.0;
  static const double categoryChipWidth = 80.0;
  static const double categoryImageHeight = 71.0;
  static const double detailImageHeight = 314.0;

  static const double cartItemHeight = 110.0;
  static const double cartImageWidth = 100.0;
  static const double cartImageHeight = 94.0;

  static const double avatarLarge = 98.0;
  static const double avatarSmall = 50.0;
  static const double fabSize = 40.0;

  static const double sellerCardImageWidth = 90.0;
  static const double sellerCardHeight = 111.0;

  static const int productGridColumns = 2;
}
