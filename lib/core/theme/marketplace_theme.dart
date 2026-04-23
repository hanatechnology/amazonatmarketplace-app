import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'marketplace_colors.dart';
import 'marketplace_typography.dart';
import 'marketplace_radius.dart';

/// Marketplace theme — replaces AppTheme.lightTheme for marketplace screens.
/// Uses Inter font (LTR), green primary, and marketplace-specific tokens.
class MarketplaceTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: MarketplaceTypography.fontFamily,

      colorScheme: const ColorScheme.light(
        primary: MarketplaceColors.primary,
        secondary: MarketplaceColors.secondary,
        surface: MarketplaceColors.surface,
        onPrimary: MarketplaceColors.onPrimary,
        onSecondary: MarketplaceColors.onSecondary,
        outline: MarketplaceColors.stroke,
        error: Colors.red,
      ),

      scaffoldBackgroundColor: MarketplaceColors.surface,

      appBarTheme: const AppBarTheme(
        backgroundColor: MarketplaceColors.surface,
        foregroundColor: MarketplaceColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: MarketplaceTypography.screenTitle,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MarketplaceColors.primary,
          foregroundColor: MarketplaceColors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: MarketplaceRadius.buttonBR),
          textStyle: MarketplaceTypography.buttonLabel,
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MarketplaceColors.primary,
          side: const BorderSide(color: MarketplaceColors.stroke),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: MarketplaceRadius.buttonBR),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MarketplaceColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        hintStyle: MarketplaceTypography.inputPlaceholder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          borderSide: const BorderSide(color: MarketplaceColors.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          borderSide: const BorderSide(color: MarketplaceColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          borderSide: const BorderSide(color: MarketplaceColors.primary, width: 1.5),
        ),
      ),

      cardTheme: CardThemeData(
        color: MarketplaceColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: MarketplaceRadius.cardBR,
          side: const BorderSide(color: MarketplaceColors.stroke),
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: const DividerThemeData(
        color: MarketplaceColors.stroke, thickness: 1, space: 0,
      ),

      splashFactory: InkSparkle.splashFactory,
    );
  }
}
