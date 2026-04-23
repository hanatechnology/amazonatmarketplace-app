import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';

class OrderCancelledPage extends StatelessWidget {
  const OrderCancelledPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          child: Column(
            children: [
              const Spacer(),

              // ── Error icon ───────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  size: 60,
                  color: Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.lg),

              Text(
                LocaleKeys.paymentCancelled.tr,
                style: MarketplaceTypography.screenTitle.copyWith(
                  color: MarketplaceColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              Text(
                LocaleKeys.paymentCancelledMessage.tr,
                style: MarketplaceTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // ── CTAs ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: MarketplaceSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MarketplaceColors.primary,
                    foregroundColor: MarketplaceColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(MarketplaceRadius.button),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.retry.tr,
                    style: MarketplaceTypography.buttonLabel,
                  ),
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              SizedBox(
                width: double.infinity,
                height: MarketplaceSpacing.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => Get.offAllNamed(Routes.MARKETPLACE_MAIN),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MarketplaceColors.primary,
                    side: const BorderSide(color: MarketplaceColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(MarketplaceRadius.button),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.continueShopping.tr,
                    style: MarketplaceTypography.buttonLabel.copyWith(
                      color: MarketplaceColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
