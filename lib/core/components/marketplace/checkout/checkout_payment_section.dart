import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../localization/locale_keys.dart';
import '../../../../domain/entities/marketplace/order_entity.dart';
import 'checkout_section_header.dart';
import 'checkout_payment_card.dart';

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

/// Payment method selection, rendered from the server's list rather than a
/// hardcoded enum — a gateway missing credentials is withdrawn upstream.
class CheckoutPaymentSection extends StatelessWidget {
  const CheckoutPaymentSection({super.key, required this.data});

  final CheckoutPaymentSectionDto data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutSectionHeader(
          data: CheckoutSectionHeaderDto(
            title: LocaleKeys.paymentMethod.tr,
            hasError: data.hasError,
            errorMessage: LocaleKeys.selectPayment.tr,
          ),
        ),
        const SizedBox(height: MarketplaceSpacing.sm),
        if (data.isLoading)
          const Padding(
            padding: EdgeInsets.all(MarketplaceSpacing.md),
            child: Center(
              child: SizedBox(
                width: MarketplaceSpacing.lg,
                height: MarketplaceSpacing.lg,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MarketplaceColors.primary,
                ),
              ),
            ),
          )
        else
          for (int i = 0; i < data.methods.length; i++) ...[
            if (i > 0) const SizedBox(height: MarketplaceSpacing.sm),
            CheckoutPaymentCard(
              method: data.methods[i],
              isSelected: data.selectedMethod == data.methods[i],
              onTap: () => data.onSelect(data.methods[i]),
            ),
          ],
        if (data.selectedMethod == PaymentMethod.edfali &&
            data.edfaliMobileController != null) ...[
          const SizedBox(height: MarketplaceSpacing.md),
          Text(
            LocaleKeys.edfaliWallet.tr,
            style: MarketplaceTypography.cardTitle,
          ),
          const SizedBox(height: MarketplaceSpacing.xs),
          TextField(
            controller: data.edfaliMobileController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: LocaleKeys.edfaliWalletHint.tr,
              hintStyle: MarketplaceTypography.inputPlaceholder,
              errorText: data.edfaliMobileError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
