import 'package:flutter/material.dart';

/// Theme-aware color set for the marketplace UI.
///
/// [MarketplaceColors] holds the raw brand constants and stays the light-mode
/// source of truth for screens that have not been migrated yet. Anything that
/// must survive a theme switch reads from this extension instead:
///
/// ```dart
/// final palette = context.palette;
/// ```
@immutable
class MarketplacePalette extends ThemeExtension<MarketplacePalette> {
  const MarketplacePalette({
    required this.background,
    required this.surface,
    required this.surfaceSunken,
    required this.hairline,
    required this.brand,
    required this.onBrand,
    required this.brandDeep,
    required this.accent,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.star,
    required this.navSurface,
    required this.scrim,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.isDark,
  });

  /// Screen ground behind the content sheet.
  final Color background;

  /// Cards, sheets, nav bar fill.
  final Color surface;

  /// Inset fields — search pill, chips, disabled wells.
  final Color surfaceSunken;

  /// Hairline borders and dividers.
  final Color hairline;

  /// The color that carries an action. Deep olive in light, lime in dark —
  /// olive on an ink ground fails contrast, lime on paper fails it too.
  final Color brand;

  /// Text/icon color on top of [brand].
  final Color onBrand;

  /// The literal brand olive, unchanged in both modes. For places that must
  /// stay recognisably Amazonat — wordmark, hero pills over photography.
  final Color brandDeep;

  /// Lime highlight — selected pills, active nav pill, badges.
  final Color accent;

  /// Text/icon color on top of [accent].
  final Color onAccent;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// Rating stars.
  final Color star;

  /// Floating bottom nav fill (slightly translucent over content).
  final Color navSurface;

  /// Overlay laid over hero photography so display text stays readable.
  final Color scrim;

  final Color shimmerBase;
  final Color shimmerHighlight;

  final bool isDark;

  static const MarketplacePalette light = MarketplacePalette(
    background: Color(0xFFF5F7EE),
    surface: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF2F5E8),
    hairline: Color(0x1A141A12),
    brand: Color(0xFF2E5129),
    onBrand: Color(0xFFFFFFFF),
    brandDeep: Color(0xFF2E5129),
    accent: Color(0xFFDDEB9D),
    onAccent: Color(0xFF22301F),
    textPrimary: Color(0xFF141A12),
    textSecondary: Color(0x9E141A12),
    textMuted: Color(0x73141A12),
    star: Color(0xFF2E5129),
    navSurface: Color(0xFFFFFFFF),
    scrim: Color(0xCC0E1310),
    shimmerBase: Color(0xFFE7EADD),
    shimmerHighlight: Color(0xFFF5F7EE),
    isDark: false,
  );

  static const MarketplacePalette dark = MarketplacePalette(
    background: Color(0xFF0E1310),
    surface: Color(0xFF141A15),
    surfaceSunken: Color(0xFF19201A),
    hairline: Color(0x1FECF1E3),
    brand: Color(0xFFDDEB9D),
    onBrand: Color(0xFF0E1310),
    brandDeep: Color(0xFF2E5129),
    accent: Color(0xFFDDEB9D),
    onAccent: Color(0xFF0E1310),
    textPrimary: Color(0xFFECF1E3),
    textSecondary: Color(0xA6ECF1E3),
    textMuted: Color(0x73ECF1E3),
    star: Color(0xFFDDEB9D),
    navSurface: Color(0xFF19201A),
    scrim: Color(0xD90E1310),
    shimmerBase: Color(0xFF1C241D),
    shimmerHighlight: Color(0xFF232D24),
    isDark: true,
  );

  @override
  MarketplacePalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSunken,
    Color? hairline,
    Color? brand,
    Color? onBrand,
    Color? brandDeep,
    Color? accent,
    Color? onAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? star,
    Color? navSurface,
    Color? scrim,
    Color? shimmerBase,
    Color? shimmerHighlight,
    bool? isDark,
  }) {
    return MarketplacePalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      hairline: hairline ?? this.hairline,
      brand: brand ?? this.brand,
      onBrand: onBrand ?? this.onBrand,
      brandDeep: brandDeep ?? this.brandDeep,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      star: star ?? this.star,
      navSurface: navSurface ?? this.navSurface,
      scrim: scrim ?? this.scrim,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  MarketplacePalette lerp(ThemeExtension<MarketplacePalette>? other, double t) {
    if (other is! MarketplacePalette) return this;
    return MarketplacePalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      brandDeep: Color.lerp(brandDeep, other.brandDeep, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      star: Color.lerp(star, other.star, t)!,
      navSurface: Color.lerp(navSurface, other.navSurface, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight:
          Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension MarketplacePaletteX on BuildContext {
  /// The active theme's marketplace palette. Falls back to the light set so a
  /// widget rendered outside the app theme (previews, tests) still paints.
  MarketplacePalette get palette =>
      Theme.of(this).extension<MarketplacePalette>() ??
      MarketplacePalette.light;
}
