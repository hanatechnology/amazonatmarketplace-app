import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/status_tone.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../controllers/marketplace/auth_controller.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';

/// The six-digit code from `POST /auth/request-otp`.
///
/// Two timers, and they mean different things: the code itself dies after five
/// minutes, and a resend is refused for sixty seconds after the last one
/// (`otp_resend_too_soon` carries `retry_after_seconds` when the server
/// disagrees with our count). Resending is legitimate here — `request-otp` is
/// itself the resend path — unlike the Edfali payment OTP, which has none.
///
/// A wrong code keeps the digits on screen rather than wiping the row: it is
/// usually one mistyped digit, and clearing punishes the customer for it.
class VerifyPhonePage extends GetView<AuthController> {
  const VerifyPhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: StickyBackBar(
        onBack: controller.editPhone,
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackButton(),
              const SizedBox(height: 14),
              Text(
                LocaleKeys.verifyPhoneTitle.tr,
                style: MarketplaceTypography.heroDisplay.copyWith(
                  fontSize: 30,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text.rich(
                  TextSpan(
                    style: MarketplaceTypography.rowMeta.copyWith(
                      fontSize: 12.5,
                      height: 1.7,
                      color: palette.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: LocaleKeys.codeSentToPhone.trParams({
                          'phone': '\u{2066}'
                              '${PhoneUtils.forDisplay(controller.phoneNumber.value)}'
                              '\u{2069}',
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: controller.editPhone,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  LocaleKeys.editPhone.tr,
                  style: MarketplaceTypography.pillLabel.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: palette.brand,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const _PinRow(),
              const SizedBox(height: 12),
              Obx(() {
                final error = controller.otpError.value;
                if (error == null) return const SizedBox.shrink();
                return Text(
                  error,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    fontSize: 11.5,
                    color: StatusTone.danger.foreground(palette.isDark),
                  ),
                );
              }),
              const SizedBox(height: 18),
              const _ResendLine(),
              const SizedBox(height: 28),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading ? null : controller.verifyOtp,
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
                            LocaleKeys.verifyOtp.tr,
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

class _BackButton extends GetView<AuthController> {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 44, child: BackButtonSlot());
  }
}

/// Six boxes, filled left to right in both languages — a code is an LTR run.
class _PinRow extends GetView<AuthController> {
  const _PinRow();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: List.generate(
          AuthController.otpLength,
          (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i == AuthController.otpLength - 1 ? 0 : 8,
              ),
              child: _PinBox(index: i),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinBox extends GetView<AuthController> {
  const _PinBox({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final hasError = controller.otpError.value != null;
      final borderColor = hasError
          ? StatusTone.danger.foreground(palette.isDark)
          : palette.hairline;

      return SizedBox(
        height: 56,
        child: TextField(
          controller: controller.otpControllers[index],
          focusNode: controller.otpFocusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          // No maxLength: SMS autofill delivers the whole code into one box,
          // and the controller spreads it across the row.
          autofillHints: index == 0 ? const [AutofillHints.oneTimeCode] : null,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(AuthController.otpLength),
          ],
          cursorColor: palette.brand,
          style: MarketplaceTypography.rowTitle.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: hasError
                ? StatusTone.danger.foreground(palette.isDark)
                : palette.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: palette.surface,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? borderColor : palette.brand,
                width: 1.5,
              ),
            ),
          ),
          onChanged: (value) => controller.onOtpChanged(index, value),
        ),
      );
    });
  }
}

/// The resend cooldown — sixty seconds, or whatever `retry_after_seconds` said.
class _ResendLine extends GetView<AuthController> {
  const _ResendLine();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final canResend = controller.isResendEnabled.value;

      return Row(
        children: [
          Text(
            LocaleKeys.didntReceiveCode.tr,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 11.5,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: canResend ? controller.resendOtp : null,
            behavior: HitTestBehavior.opaque,
            child: Text(
              canResend
                  ? LocaleKeys.resendOtp.tr
                  : LocaleKeys.resendIn.trParams(
                      {'seconds': '${controller.resendCountdown.value}'},
                    ),
              style: MarketplaceTypography.pillLabel.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: canResend ? palette.brand : palette.textMuted,
              ),
            ),
          ),
        ],
      );
    });
  }
}
