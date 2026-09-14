import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'marketplace_colors.dart';
import 'marketplace_palette.dart';
import 'marketplace_typography.dart';
import 'marketplace_radius.dart';

/// Marketplace theme — light and dark, both built from the same
/// [MarketplacePalette] so a screen only ever reads `context.palette`.
class MarketplaceTheme {
  static ThemeData get lightTheme => _build(MarketplacePalette.light);

  static ThemeData get darkTheme => _build(MarketplacePalette.dark);

  static ThemeData _build(MarketplacePalette palette) {
    final isDark = palette.isDark;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: MarketplaceTypography.fontFamily,
      fontFamilyFallback: MarketplaceTypography.fontFamilyFallback,
      extensions: <ThemeExtension<dynamic>>[palette],
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: palette.brand,
        onPrimary: palette.onBrand,
        secondary: palette.accent,
        onSecondary: palette.onAccent,
        surface: palette.surface,
        onSurface: palette.textPrimary,
        outline: palette.hairline,
        error: MarketplaceColors.errorContent,
        onError: MarketplaceColors.white,
      ),
      scaffoldBackgroundColor: palette.background,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: MarketplaceTypography.screenTitle.copyWith(
          color: palette.textPrimary,
        ),
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.brand,
          foregroundColor: palette.onBrand,
          minimumSize: const Size(double.infinity, 48),
          shape:
              RoundedRectangleBorder(borderRadius: MarketplaceRadius.buttonBR),
          textStyle: MarketplaceTypography.buttonLabel,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.brand,
          side: BorderSide(color: palette.hairline),
          minimumSize: const Size(double.infinity, 48),
          shape:
              RoundedRectangleBorder(borderRadius: MarketplaceRadius.buttonBR),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceSunken,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        hintStyle: MarketplaceTypography.inputPlaceholder.copyWith(
          color: palette.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          borderSide: BorderSide(color: palette.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          borderSide: BorderSide(color: palette.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          borderSide: BorderSide(color: palette.brand, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: MarketplaceRadius.cardBR,
          side: BorderSide(color: palette.hairline),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: palette.hairline,
        thickness: 1,
        space: 0,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
