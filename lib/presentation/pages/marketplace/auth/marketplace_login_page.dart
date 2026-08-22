import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../controllers/marketplace/auth_controller.dart';

class MarketplaceLoginPage extends GetView<AuthController> {
  const MarketplaceLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: MarketplaceSpacing.md),



              const SizedBox(height: MarketplaceSpacing.xxl),

              // ── Brand Icon + App Name ────────────────────
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: MarketplaceColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    size: 36,
                    color: MarketplaceColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.md),
              Center(
                child: Text(
                  LocaleKeys.appName.tr,
                  style: MarketplaceTypography.screenTitle.copyWith(
                    fontSize: 32,
                    color: MarketplaceColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: MarketplaceSpacing.sm),

              // ── Title & Subtitle ────────────────────────
              Center(
                child: Text(
                  LocaleKeys.loginTitle.tr,
                  style: MarketplaceTypography.sectionHeading,
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              Center(
                child: Text(
                  LocaleKeys.loginSubtitle.tr,
                  style: MarketplaceTypography.descriptionBody,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: MarketplaceSpacing.xl),

              // ── Phone Number Field ──────────────────────
              Text(
                LocaleKeys.phoneNumber.tr,
                style: MarketplaceTypography.cardTitle.copyWith(
                  color: MarketplaceColors.textBody,
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              Obx(() => TextField(
                controller: controller.phoneController,
                focusNode: controller.phoneFocusNode,
                keyboardType: TextInputType.phone,
                style: MarketplaceTypography.body,
                decoration: InputDecoration(
                  hintText: LocaleKeys.phoneHint.tr,
                  errorText: controller.phoneError.value,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Libya — the API accepts E.164 only, and the
                        // controller normalizes whatever is typed to +218.
                        Text(
                          '${PhoneUtils.countryCode} ',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          height: 24,
                          child: VerticalDivider(
                            color: MarketplaceColors.stroke,
                            width: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onChanged: (_) => controller.phoneError.value = null,
              )),

              // ── Sign-up fields (revealed on registration_required) ──
              Obx(() {
                if (!controller.needsRegistration.value) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: MarketplaceSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        LocaleKeys.signUpPrompt.tr,
                        style: MarketplaceTypography.descriptionBody,
                      ),
                      const SizedBox(height: MarketplaceSpacing.md),
                      TextField(
                        controller: controller.firstNameController,
                        textInputAction: TextInputAction.next,
                        style: MarketplaceTypography.body,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.firstNameLabel.tr,
                          hintText: LocaleKeys.firstNameHint.tr,
                          errorText: controller.firstNameError.value,
                        ),
                        onChanged: (_) =>
                            controller.firstNameError.value = null,
                      ),
                      const SizedBox(height: MarketplaceSpacing.md),
                      TextField(
                        controller: controller.lastNameController,
                        textInputAction: TextInputAction.next,
                        style: MarketplaceTypography.body,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.lastNameOptional.tr,
                          hintText: LocaleKeys.lastNameHint.tr,
                        ),
                      ),
                      const SizedBox(height: MarketplaceSpacing.md),
                      TextField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        style: MarketplaceTypography.body,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.email.tr,
                          hintText: LocaleKeys.emailHint.tr,
                          errorText: controller.emailError.value,
                        ),
                        onChanged: (_) => controller.emailError.value = null,
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: MarketplaceSpacing.lg),

              // ── Send OTP Button ─────────────────────────
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading ? null : controller.sendOtp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, MarketplaceSpacing.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MarketplaceRadius.button),
                  ),
                ),
                child: controller.isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MarketplaceColors.onPrimary,
                        ),
                      )
                    : Text(
                        controller.needsRegistration.value
                            ? LocaleKeys.signUp.tr
                            : LocaleKeys.sendOtp.tr,
                        style: MarketplaceTypography.buttonLabel,
                      ),
              )),

              const SizedBox(height: MarketplaceSpacing.sm),

              // Continue as Guest — secondary option below Send OTP
              OutlinedButton(
                onPressed: controller.continueAsGuest,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, MarketplaceSpacing.buttonHeight),
                  side: const BorderSide(color: MarketplaceColors.stroke),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MarketplaceRadius.button),
                  ),
                ),
                child: Text(
                  LocaleKeys.continueAsGuest.tr,
                  style: MarketplaceTypography.body.copyWith(
                    color: MarketplaceColors.textBody,
                  ),
                ),
              ),

              const SizedBox(height: MarketplaceSpacing.lg),

              // ── Divider with "Or continue with" ─────────
              Row(
                children: [
                  const Expanded(child: Divider(color: MarketplaceColors.stroke)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: MarketplaceSpacing.md),
                    child: Text(
                      LocaleKeys.orContinueWith.tr,
                      style: MarketplaceTypography.descriptionBody,
                    ),
                  ),
                  const Expanded(child: Divider(color: MarketplaceColors.stroke)),
                ],
              ),

              const SizedBox(height: MarketplaceSpacing.lg),

              // ── Google Button ───────────────────────────
              _SocialLoginButton(
                label: LocaleKeys.continueWithGoogle.tr,
                iconPath: 'assets/icons/google.svg', // Add SVG asset
                onTap: controller.continueWithGoogle,
              ),

              const SizedBox(height: MarketplaceSpacing.md),

              // ── Apple Button ────────────────────────────
              _SocialLoginButton(
                label: LocaleKeys.continueWithApple.tr,
                iconPath: 'assets/icons/apple.svg', // Add SVG asset
                onTap: controller.continueWithApple,
              ),

              const SizedBox(height: MarketplaceSpacing.xl),

              // ── Terms Agreement ─────────────────────────
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.termsAgreement.tr,
                      style: MarketplaceTypography.descriptionBody.copyWith(
                        color: MarketplaceColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {/* TODO: Open Terms URL */},
                      child: Text(
                        LocaleKeys.termsOfService.tr,
                        style: MarketplaceTypography.descriptionBody.copyWith(
                          color: MarketplaceColors.link,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(
                      ' ${LocaleKeys.and.tr} ',
                      style: MarketplaceTypography.descriptionBody.copyWith(
                        color: MarketplaceColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {/* TODO: Open Privacy URL */},
                      child: Text(
                        LocaleKeys.privacyPolicy.tr,
                        style: MarketplaceTypography.descriptionBody.copyWith(
                          color: MarketplaceColors.link,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: MarketplaceSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable social login button (outlined style)
class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, MarketplaceSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MarketplaceRadius.button),
        ),
        side: const BorderSide(color: MarketplaceColors.stroke),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use Image.asset for PNG or flutter_svg for SVG
          // For now, use a placeholder icon
          const Icon(Icons.login, size: 20, color: MarketplaceColors.textBody),
          const SizedBox(width: 12),
          Text(
            label,
            style: MarketplaceTypography.body.copyWith(
              color: MarketplaceColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}
