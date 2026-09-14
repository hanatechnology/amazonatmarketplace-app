import 'package:flutter/material.dart';

/// Border radius constants from Figma design.
abstract class MarketplaceRadius {
  MarketplaceRadius._();

  // ── Raw values ───────────────────────────────────────────
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double lg = 15.0;
  static const double xl = 20.0;
  static const double xxl = 30.0;
  static const double xxxl = 32.0;
  static const double full = 100.0;

  // ── Named use-cases ──────────────────────────────────────
  static const double screen = 30.0;
  static const double bottomNav = 30.0;
  static const double card = 15.0;
  static const double cardImage = 10.0;

  /// The product photo plate — grid card. Larger than [cardImage] because the
  /// plate is now the card itself, with no container rounded around it.
  static const double productPlate = 16.0;
  static const double cartItem = 14.0;
  static const double button = 20.0;
  static const double smallButton = 15.0;
  static const double bannerCta = 10.0;
  static const double detailImage = 32.0;
  static const double stepper = 30.0;
  static const double badge = 15.0;
  static const double discountBadge = 10.0;
  static const double avatar = 100.0;
  static const double profileHeader = 30.0;

  // ── Pre-built ────────────────────────────────────────────
  static final BorderRadius cardBR = BorderRadius.circular(card);
  static final BorderRadius buttonBR = BorderRadius.circular(button);
  static final BorderRadius smallButtonBR = BorderRadius.circular(smallButton);
  static final BorderRadius screenBR = BorderRadius.circular(screen);
  static final BorderRadius bottomNavBR = BorderRadius.only(
    topLeft: Radius.circular(bottomNav),
    topRight: Radius.circular(bottomNav),
  );
}
