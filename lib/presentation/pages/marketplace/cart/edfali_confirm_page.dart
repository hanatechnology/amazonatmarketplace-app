import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/components/marketplace/marketplace_app_bar.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../controllers/marketplace/edfali_confirm_controller.dart';

/// Step two of the Edfali flow: the four-digit PIN sent by SMS.
class EdfaliConfirmPage extends GetView<EdfaliConfirmController> {
  const EdfaliConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: MarketplaceAppBar(title: LocaleKeys.edfaliConfirmTitle.tr),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: MarketplaceSpacing.xl),
              Text(
                PriceFormatter.format(controller.args.total),
                style: MarketplaceTypography.screenTitle.copyWith(
                  color: MarketplaceColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              Obx(() => Text(
                    LocaleKeys.edfaliCodeSentTo.trParams({
                      'phone': controller.otpSentTo.value ?? '',
                    }),
                    style: MarketplaceTypography.descriptionBody,
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: MarketplaceSpacing.xl),
              const _PinRow(),
              Obx(() {
                final error = controller.otpError.value;
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: MarketplaceSpacing.sm),
                  child: Text(
                    error,
                    style: MarketplaceTypography.micro
                        .copyWith(color: MarketplaceColors.errorContent),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
              Obx(() {
                final remaining = controller.attemptsRemaining.value;
                if (remaining == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: MarketplaceSpacing.xs),
                  child: Text(
                    LocaleKeys.edfaliAttemptsRemaining
                        .trParams({'count': '$remaining'}),
                    style: MarketplaceTypography.micro.copyWith(
                      color: MarketplaceColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
              const SizedBox(height: MarketplaceSpacing.xl),
              Obx(() => ElevatedButton(
                    onPressed:
                        controller.isConfirming ? null : controller.confirm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        MarketplaceSpacing.buttonHeight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(MarketplaceRadius.button),
                      ),
                    ),
                    child: controller.isConfirming
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: MarketplaceColors.onPrimary,
                            ),
                          )
                        : Text(
                            LocaleKeys.confirmPayment.tr,
                            style: MarketplaceTypography.buttonLabel,
                          ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinRow extends GetView<EdfaliConfirmController> {
  const _PinRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        EdfaliConfirmController.otpLength,
        (i) => Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: i == EdfaliConfirmController.otpLength - 1
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
                // No maxLength: SMS autofill delivers the whole PIN into one
                // box, and the controller spreads it across the row.
                autofillHints:
                    i == 0 ? const [AutofillHints.oneTimeCode] : null,
                style: MarketplaceTypography.sectionHeading,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    EdfaliConfirmController.otpLength,
                  ),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
                    borderSide:
                        const BorderSide(color: MarketplaceColors.stroke),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
                    borderSide: const BorderSide(
                      color: MarketplaceColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) => controller.onOtpChanged(i, value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
