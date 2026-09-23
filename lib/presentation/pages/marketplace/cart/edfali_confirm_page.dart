import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/layout/keyboard_aware_bottom_bar.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/status_tone.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../controllers/marketplace/edfali_confirm_controller.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';
import 'package:marketplace/core/components/marketplace/auth/otp_code_field.dart';

/// Step two of the Edfali flow: the 4-digit PIN the gateway sent by SMS.
///
/// The spec is explicit that the PIN is four digits and that the third wrong
/// attempt cancels the order, so the screen shows the attempts left and never
/// offers a resend — there is no endpoint for one. If the code expires, the
/// only path forward is ordering again from the cart.
class EdfaliConfirmPage extends GetView<EdfaliConfirmController> {
  const EdfaliConfirmPage({super.key});

  static const double _gutter = 20;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: StickyBackBar(
        child:  SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _NavRow(),
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 14),
                decoration: BoxDecoration(
                  color: palette.surfaceSunken,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 26,
                  color: palette.textSecondary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 8),
                child: Text(
                  LocaleKeys.edfaliConfirmTitle.tr,
                  style: MarketplaceTypography.heroDisplay.copyWith(
                    fontSize: 27,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              Obx(() => _Lead(phone: controller.otpSentTo.value)),
              const SizedBox(height: 22),
              const _PinRow(),
              Obx(() {
                final error = controller.otpError.value;
                final remaining = controller.attemptsRemaining.value;
                if (error == null && remaining == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (error != null)
                        Text(
                          error,
                          style: MarketplaceTypography.rowMeta.copyWith(
                            fontSize: 11,
                            color: StatusTone.danger
                                .foreground(palette.isDark),
                          ),
                        ),
                      if (remaining != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            LocaleKeys.edfaliAttemptsRemaining
                                .trParams({'count': '$remaining'}),
                            style: MarketplaceTypography.rowMeta.copyWith(
                              fontSize: 10.5,
                              color: palette.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),
              const _Countdown(),
              const SizedBox(height: 18),
              const _HeldOrderLine(),
              const SizedBox(height: 18),
              const _HoldWarning(),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  LocaleKeys.edfaliNoResend.tr,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    fontSize: 10.5,
                    height: 1.7,
                    color: palette.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
      bottomNavigationBar: const KeyboardAwareBottomBar(child: _Actions()),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow();

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

/// "Edfali sent a code to `number`." The number keeps its own LTR run so it
/// cannot be reordered inside the Arabic sentence.
class _Lead extends StatelessWidget {
  const _Lead({this.phone});

  final String? phone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final number = (phone ?? '').trim();

    return Text(
      LocaleKeys.edfaliLead.trParams({
        'phone': number.isEmpty ? '—' : '\u{2066}$number\u{2069}',
      }),
      style: MarketplaceTypography.rowMeta.copyWith(
        fontSize: 12,
        height: 1.65,
        color: palette.textSecondary,
      ),
    );
  }
}

class _PinRow extends GetView<EdfaliConfirmController> {
  const _PinRow();

  @override
  Widget build(BuildContext context) {
    // The row is Latin-ordered in both languages: a PIN is read left to right.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Obx(
        () => OtpCodeField(
          controller: controller.otpController,
          focusNode: controller.otpFocusNode,
          length: EdfaliConfirmController.otpLength,
          hasError: controller.otpError.value != null,
          onChanged: controller.onOtpChanged,
          gap: 9,
        ),
      ),
    );
  }
}

/// Shown only when the checkout response told us how long the code lives.
class _Countdown extends GetView<EdfaliConfirmController> {
  const _Countdown();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final countdown = controller.countdown;
      if (countdown == null) return const SizedBox.shrink();

      final tone = controller.isExpired
          ? StatusTone.danger
          : StatusTone.warning;

      return Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: tone.foreground(palette.isDark),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            LocaleKeys.codeExpiresIn.tr,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 11.5,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            countdown,
            textDirection: TextDirection.ltr,
            style: MarketplaceTypography.rowTitle.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
        ],
      );
    });
  }
}

/// Which order is being held, and for how much.
class _HeldOrderLine extends GetView<EdfaliConfirmController> {
  const _HeldOrderLine();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final orderNumber = controller.args.orderNumber;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (orderNumber != null && orderNumber.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.orderNumber.tr,
                    style: MarketplaceTypography.rowMeta.copyWith(
                      fontSize: 10.5,
                      color: palette.textMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    orderNumber,
                    textDirection: TextDirection.ltr,
                    style: MarketplaceTypography.rowTitle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocaleKeys.amountLabel.tr,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 10.5,
                  color: palette.textMuted,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                textDirection: TextDirection.ltr,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    PriceFormatter.amount(controller.args.total),
                    style: MarketplaceTypography.priceDisplay.copyWith(
                      fontSize: 22,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    PriceFormatter.unit(),
                    style: MarketplaceTypography.priceUnit.copyWith(
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HoldWarning extends StatelessWidget {
  const _HoldWarning();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = palette.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: StatusTone.warning.background(isDark),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        LocaleKeys.edfaliHoldWarn.tr,
        style: MarketplaceTypography.rowMeta.copyWith(
          fontSize: 10.5,
          height: 1.65,
          color: StatusTone.warning.foreground(isDark),
        ),
      ),
    );
  }
}

class _Actions extends GetView<EdfaliConfirmController> {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        EdfaliConfirmPage._gutter,
        14,
        EdfaliConfirmPage._gutter,
        0,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Obx(() {
            final isBusy = controller.isConfirming || controller.isCancelling;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isBusy || controller.isExpired
                        ? null
                        : controller.confirm,
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
                    child: controller.isConfirming
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: palette.onBrand,
                            ),
                          )
                        : Text(
                            LocaleKeys.confirmPayment.tr,
                            style:
                                MarketplaceTypography.buttonLabel.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: isBusy ? null : controller.cancelHeldOrder,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.textSecondary,
                      side: BorderSide(color: palette.hairline),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(MarketplaceRadius.full),
                      ),
                    ),
                    child: controller.isCancelling
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: palette.textSecondary,
                            ),
                          )
                        : Text(
                            LocaleKeys.cancelOrder.tr,
                            style:
                                MarketplaceTypography.buttonLabel.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: palette.textSecondary,
                            ),
                          ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
