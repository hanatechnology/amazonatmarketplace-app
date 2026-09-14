import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/status_tone.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../controllers/marketplace/auth_controller.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';

/// Create account — reached only when `request-otp` answers
/// `registration_required`.
///
/// This step is *before* the OTP, not after it: the endpoint will not send a
/// code for an unknown number until it has `first_name` and `email`, so a
/// post-verification "complete your profile" screen cannot exist. Submitting
/// repeats `request-otp` with the profile attached, which registers the
/// customer and dispatches the code in one call.
///
/// Last name is optional — the DTO requires only `phone`, and requiring more
/// than the contract does would reject people the backend would accept.
class CreateAccountPage extends GetView<AuthController> {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: StickyBackBar(
        child:  SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackButton(),
              const SizedBox(height: 14),
              Text(
                LocaleKeys.createAccount.tr,
                style: MarketplaceTypography.heroDisplay.copyWith(
                  fontSize: 30,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                LocaleKeys.createAccountSubtitle.tr,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 12.5,
                  height: 1.7,
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const _PhoneSummary(),
              const SizedBox(height: 22),
              Obx(
                () => _Field(
                  label: LocaleKeys.firstNameLabel.tr,
                  hint: LocaleKeys.firstNameHint.tr,
                  controller: controller.firstNameController,
                  error: controller.firstNameError.value,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 14),
              _Field(
                label: LocaleKeys.lastNameLabel.tr,
                hint: LocaleKeys.lastNameHint.tr,
                controller: controller.lastNameController,
                isOptional: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              Obx(
                () => _Field(
                  label: LocaleKeys.email.tr,
                  hint: LocaleKeys.emailHint.tr,
                  controller: controller.emailController,
                  error: controller.emailError.value,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => controller.sendOtp(),
                ),
              ),
              const SizedBox(height: 26),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading ? null : controller.sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.brand,
                      foregroundColor: palette.onBrand,
                      disabledBackgroundColor: palette.surfaceSunken,
                      disabledForegroundColor: palette.textMuted,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(MarketplaceRadius.full),
                      ),
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: palette.onBrand,
                            ),
                          )
                        : Text(
                            LocaleKeys.sendOtp.tr,
                            style:
                                MarketplaceTypography.buttonLabel.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: const BackButtonSlot(),
      ),
    );
  }
}

/// The number already entered, so the customer can see what they are signing
/// up with without going back for it.
class _PhoneSummary extends GetView<AuthController> {
  const _PhoneSummary();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.smartphone_outlined,
            size: 15,
            color: palette.textMuted,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Obx(
              () => Text(
                PhoneUtils.forDisplay(controller.phoneNumber.value),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                style: MarketplaceTypography.rowTitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: Get.back,
            behavior: HitTestBehavior.opaque,
            child: Text(
              LocaleKeys.editPhone.tr,
              style: MarketplaceTypography.pillLabel.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: palette.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    this.error,
    this.isOptional = false,
    this.keyboardType,
    this.textDirection,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? error;
  final bool isOptional;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label.toUpperCase(),
              style: MarketplaceTypography.labelCaps.copyWith(
                color: palette.textMuted,
                letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.2,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: palette.surfaceSunken,
                  borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                ),
                child: Text(
                  LocaleKeys.optionalChip.tr,
                  style: MarketplaceTypography.labelCaps.copyWith(
                    fontSize: 8.5,
                    color: palette.textMuted,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 7),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasError
                  ? StatusTone.danger.foreground(palette.isDark)
                  : palette.hairline,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textDirection: textDirection,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              cursorColor: palette.brand,
              style: MarketplaceTypography.rowTitle.copyWith(
                fontSize: 14,
                color: palette.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: hint,
                hintStyle: MarketplaceTypography.rowTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: palette.textMuted,
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              error!,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 11,
                color: StatusTone.danger.foreground(palette.isDark),
              ),
            ),
          ),
      ],
    );
  }
}
