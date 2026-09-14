import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/marketplace/order_entity.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/status_tone.dart';
import 'checkout_payment_card.dart';
import 'checkout_section_label.dart';

class CheckoutPaymentSectionDto {
  const CheckoutPaymentSectionDto({
    required this.methods,
    required this.selectedMethod,
    required this.onSelect,
    this.hasError = false,
    this.isLoading = false,
    this.edfaliMobileController,
    this.edfaliMobileError,
  });

  /// Methods this deployment can actually complete, from
  /// `GET /orders/payment-methods`.
  final List<PaymentMethod> methods;
  final PaymentMethod? selectedMethod;
  final ValueChanged<PaymentMethod> onSelect;
  final bool hasError;
  final bool isLoading;

  /// Wallet to debit. Required by the API when EDFALI is selected.
  final TextEditingController? edfaliMobileController;
  final String? edfaliMobileError;
}

/// Step two, rendered from the server's list rather than a hardcoded enum — a
/// gateway missing credentials is withdrawn upstream, and offering it here
/// would only produce a failed order.
class CheckoutPaymentSection extends StatelessWidget {
  const CheckoutPaymentSection({super.key, required this.data});

  final CheckoutPaymentSectionDto data;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutSectionLabel(
          title: LocaleKeys.paymentMethod.tr,
          errorMessage: data.hasError ? LocaleKeys.selectPayment.tr : null,
        ),
        if (data.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.brand,
                ),
              ),
            ),
          )
        else
          for (final method in data.methods) ...[
            CheckoutPaymentCard(
              method: method,
              isSelected: data.selectedMethod == method,
              onTap: () => data.onSelect(method),
            ),
            const SizedBox(height: 9),
          ],
        if (data.selectedMethod == PaymentMethod.edfali &&
            data.edfaliMobileController != null)
          _EdfaliWalletField(
            controller: data.edfaliMobileController!,
            errorMessage: data.edfaliMobileError,
          ),
      ],
    );
  }
}

/// The wallet to debit. The API never falls back to the account phone, so this
/// is collected explicitly and shown back before the order is submitted.
class _EdfaliWalletField extends StatelessWidget {
  const _EdfaliWalletField({
    required this.controller,
    this.errorMessage,
  });

  final TextEditingController controller;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasError = errorMessage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: palette.surfaceSunken,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? StatusTone.danger.foreground(palette.isDark)
                  : palette.hairline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.edfaliWallet.tr.toUpperCase(),
                style: MarketplaceTypography.labelCaps.copyWith(
                  color: palette.textMuted,
                  letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.2,
                ),
              ),
              const SizedBox(height: 3),
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                style: MarketplaceTypography.rowTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: palette.textPrimary,
                ),
                cursorColor: palette.brand,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: LocaleKeys.edfaliWalletHint.tr,
                  hintStyle: MarketplaceTypography.rowTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: palette.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Text(
            errorMessage!,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 10.5,
              color: StatusTone.danger.foreground(palette.isDark),
            ),
          ),
        ],
      ],
    );
  }
}
