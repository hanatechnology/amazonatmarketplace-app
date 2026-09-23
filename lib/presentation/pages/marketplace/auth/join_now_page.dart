import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../data/services/session_service.dart';
import 'package:marketplace/app/routes/app_router.dart';

/// Welcome — sign in, or browse first.
///
/// The catalogue is open: `/products`, `/categories` and `/banners` answer 200
/// without a bearer, so a guest has a real shop to walk through. Signing in is
/// still the primary action, because everything that ends in an order — stores,
/// addresses, checkout, orders, notifications — is bearer-only and answers 401.
/// There is no social sign-in endpoint anywhere in the contract, so none is
/// offered.
///
/// The three chips underneath are facts each backed by an endpoint —
/// payment methods, verified stores, city coverage — not decoration.
class JoinNowPage extends StatelessWidget {
  const JoinNowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.brand,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 34,
                  color: palette.onBrand,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                LocaleKeys.welcomeTitle.tr,
                style: MarketplaceTypography.heroDisplay.copyWith(
                  fontSize: 34,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                LocaleKeys.welcomeSubtitle.tr,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 12.5,
                  height: 1.7,
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 26),
              const _TrustChip(
                icon: Icons.account_balance_wallet_outlined,
                labelKey: LocaleKeys.trustPayment,
              ),
              const SizedBox(height: 9),
              const _TrustChip(
                icon: Icons.verified_outlined,
                labelKey: LocaleKeys.trustStores,
              ),
              const SizedBox(height: 9),
              const _TrustChip(
                icon: Icons.local_shipping_outlined,
                labelKey: LocaleKeys.trustDelivery,
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => AppRouter.toNamed(Routes.MARKETPLACE_LOGIN),
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
                    LocaleKeys.getStarted.tr,
                    style: MarketplaceTypography.buttonLabel.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: palette.onBrand,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () {
                    SessionService.to.continueAsGuest();
                    Get.offAllNamed(Routes.MARKETPLACE_MAIN);
                  },
                  child: Text(
                    LocaleKeys.continueAsGuest.tr,
                    style: MarketplaceTypography.pillLabel.copyWith(
                      fontSize: 12,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  LocaleKeys.termsAgreement.tr,
                  textAlign: TextAlign.center,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    fontSize: 10,
                    color: palette.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.labelKey});

  final IconData icon;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.surfaceSunken,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 15, color: palette.brand),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            labelKey.tr,
            style: MarketplaceTypography.pillLabel.copyWith(
              fontSize: 12,
              color: palette.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
