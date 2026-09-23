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

/// The sign-in wall a guest meets inside a tab.
///
/// Used where a whole tab's data is bearer-only — the sellers list — so there
/// is no list to show and nothing to gate per row. A tab cannot be redirected
/// the way a pushed route can: it lives in its own nested navigator inside the
/// shell, which route middleware never sees. This is the in-place equivalent.
class SignInRequiredView extends StatelessWidget {
  const SignInRequiredView({
    super.key,
    required this.titleKey,
    required this.bodyKey,
    this.icon = Icons.lock_outline_rounded,
    this.intendedRoute,
  });

  final String titleKey;
  final String bodyKey;
  final IconData icon;

  /// Where to land after signing in. Null means the shell itself is enough —
  /// the tab will simply have its data once the session exists.
  final String? intendedRoute;

  void _signIn() {
    SessionService.to.rememberIntendedRoute(intendedRoute);
    AppRouter.toNamed<void>(Routes.MARKETPLACE_LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.xl,
          vertical: MarketplaceSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.surfaceSunken,
                borderRadius: BorderRadius.circular(MarketplaceRadius.xl),
              ),
              child: Icon(icon, size: 28, color: palette.brand),
            ),
            const SizedBox(height: MarketplaceSpacing.md),
            Text(
              titleKey.tr,
              textAlign: TextAlign.center,
              style: MarketplaceTypography.sectionDisplay.copyWith(
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: MarketplaceSpacing.xs),
            // Arabic runs long here — the copy is a full sentence, so the box
            // is given room rather than sized to the English line.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                bodyKey.tr,
                textAlign: TextAlign.center,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 12.5,
                  height: 1.7,
                  color: palette.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: MarketplaceSpacing.lg),
            SizedBox(
              width: 220,
              height: 46,
              child: ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.brand,
                  foregroundColor: palette.onBrand,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MarketplaceRadius.full),
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
          ],
        ),
      ),
    );
  }
}
