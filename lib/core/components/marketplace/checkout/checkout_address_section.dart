import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../localization/locale_keys.dart';
import 'checkout_section_header.dart';
import 'checkout_address_card.dart';

class CheckoutAddressSectionDto {
  const CheckoutAddressSectionDto({
    required this.addresses,
    required this.selectedAddressId,
    required this.onSelect,
    required this.onAddNew,
    this.isLoading = false,
    this.hasError = false,
  });

  final List<CheckoutAddressDto> addresses;
  final String? selectedAddressId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddNew;
  final bool isLoading;
  final bool hasError;
}

/// Address selection section: list of saved addresses + "Add new" card.
class CheckoutAddressSection extends StatelessWidget {
  const CheckoutAddressSection({super.key, required this.data});

  final CheckoutAddressSectionDto data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutSectionHeader(
          data: CheckoutSectionHeaderDto(
            title: LocaleKeys.deliveryAddress.tr,
            hasError: data.hasError,
            errorMessage: LocaleKeys.selectAddress.tr,
          ),
        ),
        const SizedBox(height: MarketplaceSpacing.sm),
        if (data.isLoading)
          const _AddressShimmer()
        else ...[
          for (final address in data.addresses) ...[
            CheckoutAddressCard(
              address: address,
              isSelected: address.id == data.selectedAddressId,
              onTap: () => data.onSelect(address.id),
            ),
            const SizedBox(height: MarketplaceSpacing.sm),
          ],
          _AddNewAddressCard(onTap: data.onAddNew),
        ],
      ],
    );
  }
}

class _AddNewAddressCard extends StatelessWidget {
  const _AddNewAddressCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(MarketplaceSpacing.md),
        decoration: BoxDecoration(
          color: MarketplaceColors.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          border: Border.all(
            color: MarketplaceColors.stroke,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.add_circle_outline,
              color: MarketplaceColors.primary,
            ),
            const SizedBox(width: MarketplaceSpacing.sm),
            Text(
              LocaleKeys.addNewAddress.tr,
              style: MarketplaceTypography.body.copyWith(
                color: MarketplaceColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressShimmer extends StatelessWidget {
  const _AddressShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: MarketplaceSpacing.sm),
          child: Shimmer.fromColors(
            baseColor: MarketplaceColors.stroke.withValues(alpha: 0.4),
            highlightColor: MarketplaceColors.stroke.withValues(alpha: 0.15),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: MarketplaceColors.deleteBackground,
                borderRadius: BorderRadius.circular(MarketplaceRadius.card),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
