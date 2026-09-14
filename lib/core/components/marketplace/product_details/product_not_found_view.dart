import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_typography.dart';

/// One screen for both failures the detail endpoint can hand back.
///
/// `GET /products/{id}` 404s for a product that is missing *and* for one that
/// is inactive, so a product that sells out between the list and the detail
/// lands here rather than on the out-of-stock layout. A generic network error
/// reuses the same recovery, with the server's own message.
class ProductNotFoundView extends StatelessWidget {
  const ProductNotFoundView({
    super.key,
    required this.onBrowse,
    required this.onRetry,
    this.isNotFound = true,
    this.message,
  });

  final VoidCallback onBrowse;
  final VoidCallback onRetry;

  /// True for the documented 404; false for any other failure.
  final bool isNotFound;

  /// Server message, shown instead of the 404 copy when the failure is not a
  /// 404 — a network error should not claim the product was removed.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.xl,
            vertical: MarketplaceSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.surfaceSunken,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 38,
                  color: palette.textMuted,
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.lg),
              Text(
                isNotFound
                    ? LocaleKeys.productNotFound.tr
                    : LocaleKeys.error.tr,
                textAlign: TextAlign.center,
                style: MarketplaceTypography.heroDisplay.copyWith(
                  fontSize: 26,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              Text(
                isNotFound
                    ? LocaleKeys.productNotFoundBody.tr
                    : (message ?? LocaleKeys.error.tr),
                textAlign: TextAlign.center,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11.5,
                  height: 1.7,
                  color: palette.textSecondary,
                ),
              ),
              if (isNotFound) ...[
                const SizedBox(height: MarketplaceSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surfaceSunken,
                    borderRadius:
                        BorderRadius.circular(MarketplaceRadius.full),
                  ),
                  child: Text(
                    '404',
                    textDirection: TextDirection.ltr,
                    style: MarketplaceTypography.labelCaps.copyWith(
                      fontSize: 10,
                      color: palette.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: MarketplaceSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: MarketplaceSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: onBrowse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.brand,
                    foregroundColor: palette.onBrand,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(MarketplaceRadius.full),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.browseProducts.tr,
                    style: MarketplaceTypography.buttonLabel.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: palette.onBrand,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  LocaleKeys.retry.tr,
                  style: MarketplaceTypography.buttonLabel.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: palette.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
