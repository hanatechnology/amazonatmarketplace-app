import 'package:flutter/material.dart';

/// All colors extracted from the Marketplace Figma design file.
/// Figma variables: --body-text (#4A4A4A), --icon-1 (#5E5E5E), CTA (#2E5129)
abstract class MarketplaceColors {
  MarketplaceColors._();

  // ── Brand / Primary ──────────────────────────────────────
  /// Primary CTA — buttons, active tab icons, screen titles
  static const Color primary = Color(0xFF2E5129);

  /// Secondary accent — banner bg, discount badge bg, price summary bg
  static const Color secondary = Color(0xFFDDEB9D);

  // ── Neutral / Text ───────────────────────────────────────
  /// Darkest text — section headings ("New Collection"), section titles
  static const Color textPrimary = Color(0xFF101828);

  /// Body text — product names, prices, descriptions, menu items
  /// Figma variable: --body-text
  static const Color textBody = Color(0xFF4A4A4A);

  /// Secondary text — seller names, ratings, muted labels
  static const Color textSecondary = Color(0xFF767676);

  /// Description text — long-form body, slightly different gray
  static const Color textDescription = Color(0xFF969694);

  /// Muted text — placeholders, faint labels
  static const Color textMuted = Color(0xFFA2A2A2);

  // ── UI Elements ──────────────────────────────────────────
  /// Stroke/border — card borders, input borders, dividers
  static const Color stroke = Color(0xFFC1C1C1);

  /// Lighter stroke variant
  static const Color strokeLight = Color(0xFFCBCBCB);

  /// Background surface — screen bg
  static const Color surface = Color(0xFFFFFFFF);

  /// Inactive icon/label color in bottom nav
  /// Figma variable: --icon-1
  static const Color iconInactive = Color(0xFF5E5E5E);

  /// Delete button bg, cart item delete circle
  static const Color deleteBackground = Color(0xFFEAEAEA);

  /// Profile header bg rectangle
  static const Color profileHeaderBg = Color(0xFFC1C1C1);

  // ── Semantic ─────────────────────────────────────────────
  /// Link text — "Learn more" in descriptions/reviews
  static const Color link = Color(0xFF4897FF);


  /// Status "Closed" dot
  static const Color statusClosed = Color(0xFFFF0000);

  /// Text on primary-colored surfaces
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Text on secondary-colored surfaces
  static const Color onSecondary = Color(0xFF4A4A4A);

  /// Pure white — backgrounds, app bar
  static const Color white = Color(0xFFFFFFFF);

  // ── Semantic status pills ──────────────────────────────────
  // Background/foreground pairs for badges that report a state — order
  // lifecycle, refunds, payments. Grouped the same way the web client groups
  // its badge variants.

  static const Color warningSurface = Color(0xFFFFF4E5);
  static const Color warningContent = Color(0xFF9A6400);

  static const Color infoSurface = Color(0xFFE8F1FF);
  static const Color infoContent = Color(0xFF4897FF);

  static const Color successSurface = Color(0xFFE6F7E8);
  static const Color successContent = Color(0xFF1F7A2E);

  static const Color errorSurface = Color(0xFFFDE8E8);
  static const Color errorContent = Color(0xFFD92D20);

  static const Color neutralSurface = Color(0xFFEAEAEA);
  static const Color neutralContent = Color(0xFF767676);
}
