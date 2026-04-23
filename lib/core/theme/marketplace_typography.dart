import 'package:flutter/material.dart';
import 'marketplace_colors.dart';

/// Text styles from the Marketplace Figma design.
/// Font: Inter (400 Regular, 500 Medium, 600 SemiBold, 700 Bold)
abstract class MarketplaceTypography {
  MarketplaceTypography._();

  static const String fontFamily = 'Inter';

  // ── Screen Titles (24px) ─────────────────────────────────
  /// Screen titles — "Details", "My Cart", "My Order"
  static const TextStyle screenTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600,
    height: 1.0, color: MarketplaceColors.primary,
  );

  /// Product name on detail screen
  static const TextStyle productTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600,
    height: 1.0, color: MarketplaceColors.textBody,
  );

  /// Large price display on detail screen
  static const TextStyle priceTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w500,
    height: 1.0, color: MarketplaceColors.textBody,
  );

  // ── Section Headings (16px) ──────────────────────────────
  /// "Category", "Popular Product" on Home
  static const TextStyle sectionHeading = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600,
    color: MarketplaceColors.textPrimary,
  );

  /// "Description", "Reviews & Rating", profile name, "My Account"
  static const TextStyle sectionSubheading = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w500,
    color: MarketplaceColors.textBody,
  );

  /// Profile menu items, body text
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textBody,
  );

  /// CTA button labels — "Add To Cart", "CheckOut"
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w500,
    height: 1.4, color: MarketplaceColors.onPrimary,
  );

  /// Cart item count "3 Items", "Select All"
  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600,
    color: MarketplaceColors.textSecondary,
  );

  /// Seller name on detail, price summary labels
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textSecondary,
  );

  /// Old price with strikethrough
  static const TextStyle priceStrikethrough = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textBody, decoration: TextDecoration.lineThrough,
  );

  // ── Description (13px) ───────────────────────────────────
  /// Description body, banner subtitle
  static const TextStyle descriptionBody = TextStyle(
    fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w400,
    height: 1.4, color: MarketplaceColors.textSecondary,
  );

  // ── Card / Compact (12px) ────────────────────────────────
  /// Product card names, tab bar labels
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
    height: 1.0, color: MarketplaceColors.textBody,
  );

  /// Seller name on cards, prices, location text
  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.0, color: MarketplaceColors.textSecondary,
  );

  /// Price text on product card
  static const TextStyle cardPrice = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.0, color: MarketplaceColors.textBody,
  );

  /// Rating number "4.2" next to star
  static const TextStyle cardRating = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
    height: 1.0, color: MarketplaceColors.textSecondary,
  );

  /// "Add to cart" small card button text
  static const TextStyle smallButton = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.0, color: MarketplaceColors.onPrimary,
  );

  /// Search placeholder, category labels
  static const TextStyle inputPlaceholder = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.0, color: MarketplaceColors.textSecondary,
  );

  /// Bottom nav active/inactive labels
  static const TextStyle navLabel = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
    height: 1.0,
  );

  /// Banner title "New Collection"
  static const TextStyle bannerTitle = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600,
    color: MarketplaceColors.textPrimary,
  );

  /// Banner subtitle "Discount 20%..."
  static const TextStyle bannerSubtitle = TextStyle(
    fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textMuted,
  );

  /// "Shop now" CTA inside banner
  static const TextStyle bannerCta = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w600,
    color: MarketplaceColors.onPrimary,
  );

  // ── Micro (10px) ─────────────────────────────────────────
  /// Discount badge, review body, strikethrough card price
  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily, fontSize: 10, fontWeight: FontWeight.w400,
    height: 1.4, color: MarketplaceColors.textBody,
  );

  /// Quantity number in stepper (detail screen)
  static const TextStyle quantityNumber = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400,
    color: MarketplaceColors.textBody,
  );

  /// Quantity in cart (compact)
  static const TextStyle cartQuantity = TextStyle(
    fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500,
    color: MarketplaceColors.textBody,
  );

  // ── Heading Aliases ─────────────────────────────────────────
  /// Alias for screenTitle (h4 heading style)
  static const TextStyle h4 = screenTitle;

  /// Alias for sectionHeading (h5 heading style)
  static const TextStyle h5 = sectionHeading;

  /// "See All" link — 14px Medium in primary green
  static const TextStyle seeAll = TextStyle(
    fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500,
    color: MarketplaceColors.primary,
  );
}
