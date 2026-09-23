import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../data/services/session_service.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_typography.dart';
import 'package:marketplace/app/routes/app_router.dart';

/// Call-site sign-in guard, for actions rather than whole screens.
///
/// A guest tapping "checkout" or "visit store" is stopped here instead of by
/// [AuthGuardMiddleware], because those journeys carry arguments the middleware
/// cannot see — the vendor's basket, the store id — and losing them would send
/// the customer back to an empty screen after signing in.
abstract class AuthGuard {
  AuthGuard._();

  /// Returns true when the action may proceed. Otherwise opens the sign-in
  /// sheet, remembers [intendedRoute] + [arguments] for after the OTP, and
  /// returns false — so every call site reads `if (!ensureSignedIn(...)) return;`.
  static bool ensureSignedIn({
    required String reasonKey,
    String? intendedRoute,
    Object? arguments,
  }) {
    if (SessionService.to.isSignedIn) return true;

    Get.bottomSheet(
      SignInPromptSheet(
        reasonKey: reasonKey,
        intendedRoute: intendedRoute,
        arguments: arguments,
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
    return false;
  }
}

/// The sheet itself — a native bottom sheet rather than the web's modal, with
/// one primary action. "Not now" simply closes: the customer keeps browsing.
class SignInPromptSheet extends StatelessWidget {
  const SignInPromptSheet({
    super.key,
    required this.reasonKey,
    this.intendedRoute,
    this.arguments,
  });

  /// Localization key for the line explaining what needs an account.
  final String reasonKey;
  final String? intendedRoute;
  final Object? arguments;

  void _signIn() {
    SessionService.to.rememberIntendedRoute(intendedRoute, arguments);
    Get.back<void>();
    AppRouter.toNamed<void>(Routes.MARKETPLACE_LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            MarketplaceSpacing.lg,
            MarketplaceSpacing.md,
            MarketplaceSpacing.lg,
            MarketplaceSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.hairline,
                    borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.lg),
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.surfaceSunken,
                  borderRadius: BorderRadius.circular(MarketplaceRadius.lg),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 22,
                  color: palette.brand,
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.md),
              Text(
                LocaleKeys.signInRequiredTitle.tr,
                style: MarketplaceTypography.sectionDisplay.copyWith(
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.xs),
              Text(
                reasonKey.tr,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 12.5,
                  height: 1.7,
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _signIn,
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
                    LocaleKeys.login.tr,
                    style: MarketplaceTypography.buttonLabel.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: palette.onBrand,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.xs),
              Center(
                child: TextButton(
                  onPressed: () => Get.back<void>(),
                  child: Text(
                    LocaleKeys.notNow.tr,
                    style: MarketplaceTypography.pillLabel.copyWith(
                      fontSize: 12,
                      color: palette.textMuted,
                    ),
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
