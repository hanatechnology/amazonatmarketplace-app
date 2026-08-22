import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/components/marketplace/marketplace_app_bar.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../controllers/marketplace/auth_controller.dart';

class VerifyPhonePage extends GetView<AuthController> {
  const VerifyPhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: MarketplaceAppBar(title: LocaleKeys.verifyPhoneTitle.tr),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: MarketplaceSpacing.xl),

              // ── Title ───────────────────────────────────
              Text(
                LocaleKeys.verifyPhoneTitle.tr,
                style: MarketplaceTypography.sectionHeading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MarketplaceSpacing.sm),

              // ── Subtitle with phone number ──────────────
              Obx(() => Text(
                    LocaleKeys.otpSentTo.trParams({
                      'phone': PhoneUtils.forDisplay(
                        controller.phoneNumber.value,
                      ),
                    }),
                    style: MarketplaceTypography.descriptionBody,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                  )),

              const SizedBox(height: MarketplaceSpacing.xl),

              // ── OTP Input Fields ────────────────────────
              // Six boxes at a fixed width overflow a 320 dp screen, so they
              // share the row instead.
              Row(
                children: List.generate(
                    AuthController.otpLength,
                    (i) => Expanded(
                        child: Padding(
                      padding: EdgeInsets.only(
                        right: i == AuthController.otpLength - 1
                            ? 0
                            : MarketplaceSpacing.sm,
                      ),
                      child: SizedBox(
                          height: 56,
                          child: TextField(
                            controller: controller.otpControllers[i],
                            focusNode: controller.otpFocusNodes[i],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            // No maxLength: SMS autofill delivers the whole
                            // code into one box, and the controller spreads it
                            // across the row.
                            autofillHints: i == 0
                                ? const [AutofillHints.oneTimeCode]
                                : null,
                            style: MarketplaceTypography.sectionHeading,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                AuthController.otpLength,
                              ),
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(MarketplaceRadius.sm),
                                borderSide: const BorderSide(
                                    color: MarketplaceColors.stroke),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(MarketplaceRadius.sm),
                                borderSide: const BorderSide(
                                  color: MarketplaceColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) =>
                                controller.onOtpChanged(i, value),
                          ),
                        ),
                    ))),
              ),

              // ── OTP Error ───────────────────────────────
              Obx(() => controller.otpError.value != null
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: MarketplaceSpacing.sm),
                      child: Text(
                        controller.otpError.value!,
                        style: MarketplaceTypography.micro
                            .copyWith(color: MarketplaceColors.statusClosed),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink()),

              const SizedBox(height: MarketplaceSpacing.xl),

              // ── Verify Button ───────────────────────────
              Obx(() => ElevatedButton(
                    onPressed:
                        controller.isLoading ? null : controller.verifyOtp,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                          double.infinity, MarketplaceSpacing.buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(MarketplaceRadius.button),
                      ),
                    ),
                    child: controller.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: MarketplaceColors.onPrimary,
                            ),
                          )
                        : Text(
                            LocaleKeys.verifyOtp.tr,
                            style: MarketplaceTypography.buttonLabel,
                          ),
                  )),

              const SizedBox(height: MarketplaceSpacing.lg),

              // ── Resend Timer ────────────────────────────
              Center(
                child: Obx(() {
                  if (controller.isResendEnabled.value) {
                    return GestureDetector(
                      onTap: controller.resendOtp,
                      child: Text(
                        LocaleKeys.resendOtp.tr,
                        style: MarketplaceTypography.body.copyWith(
                          color: MarketplaceColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Text(
                        LocaleKeys.didntReceiveCode.tr,
                        style: MarketplaceTypography.descriptionBody,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        LocaleKeys.resendIn.trParams({
                          'seconds': '${controller.resendCountdown.value}',
                        }),
                        style: MarketplaceTypography.cardTitle.copyWith(
                          color: MarketplaceColors.primary,
                        ),
                      ),
                    ],
                  );
                }),
              ),

              const SizedBox(height: MarketplaceSpacing.md),

              // ── Change phone number ─────────────────────
              Center(
                child: TextButton(
                  onPressed: controller.editPhone,
                  child: Text(
                    LocaleKeys.editPhone.tr,
                    style: MarketplaceTypography.body.copyWith(
                      color: MarketplaceColors.textSecondary,
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
