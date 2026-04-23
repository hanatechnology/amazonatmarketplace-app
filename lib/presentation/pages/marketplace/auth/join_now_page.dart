import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../app/routes/app_routes.dart';

class JoinNowPage extends StatelessWidget {
  const JoinNowPage({super.key});

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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // ── Illustration Placeholder ────────────────
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: MarketplaceColors.secondary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: MarketplaceColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: MarketplaceSpacing.xl),

              Text(
                LocaleKeys.joinNowTitle.tr,
                style: MarketplaceTypography.screenTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              Text(
                LocaleKeys.joinNowSubtitle.tr,
                style: MarketplaceTypography.descriptionBody,
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // ── Get Started Button ──────────────────────
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.MARKETPLACE_LOGIN),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, MarketplaceSpacing.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MarketplaceRadius.button),
                  ),
                ),
                child: Text(
                  LocaleKeys.getStarted.tr,
                  style: MarketplaceTypography.buttonLabel,
                ),
              ),

              const SizedBox(height: MarketplaceSpacing.md),

              // ── Already have account? Login ─────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.alreadyHaveAccount.tr,
                    style: MarketplaceTypography.descriptionBody,
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.MARKETPLACE_LOGIN),
                    child: Text(
                      LocaleKeys.login.tr,
                      style: MarketplaceTypography.body.copyWith(
                        color: MarketplaceColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: MarketplaceSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
