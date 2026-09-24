import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/legal/legal_document.dart';
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
              const Center(child: _TermsNotice()),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// "By continuing, you agree to our Terms of Service and Privacy Policy" —
/// with both halves actually opening the document they name.
///
/// The consent line was previously flat text beside two unused translation
/// keys, which is a policy notice that cannot be read: every store requires the
/// policies to be reachable, and a customer agreeing to them has to be able to
/// see what they are agreeing to.
class _TermsNotice extends StatelessWidget {
  const _TermsNotice();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final base = MarketplaceTypography.rowMeta.copyWith(
      fontSize: 10,
      color: palette.textMuted,
      height: 1.6,
    );
    final link = base.copyWith(
      color: palette.brand,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: palette.brand,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 2,
        children: [
          Text(LocaleKeys.termsAgreement.tr, style: base),
          _LegalLink(
            label: LocaleKeys.termsOfService.tr,
            kind: LegalDocumentKind.termsOfService,
            style: link,
          ),
          Text(LocaleKeys.and.tr, style: base),
          _LegalLink(
            label: LocaleKeys.privacyPolicy.tr,
            kind: LegalDocumentKind.privacyPolicy,
            style: link,
          ),
        ],
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({
    required this.label,
    required this.kind,
    required this.style,
  });

  final String label;
  final LegalDocumentKind kind;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRouter.toNamed<void>(
        Routes.MARKETPLACE_LEGAL,
        arguments: kind,
      ),
      behavior: HitTestBehavior.opaque,
      child: Text(label, style: style),
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
