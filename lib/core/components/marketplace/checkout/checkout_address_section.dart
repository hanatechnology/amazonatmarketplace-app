import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';
import 'checkout_address_card.dart';
import 'checkout_section_label.dart';

class CheckoutAddressSectionDto {
  const CheckoutAddressSectionDto({
    required this.addresses,
    required this.selectedAddressId,
    required this.onSelect,
    required this.onAddNew,
    this.isLoading = false,
    this.hasError = false,
    this.deliveryUnavailable = false,
  });

  final List<CheckoutAddressDto> addresses;
  final String? selectedAddressId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddNew;
  final bool isLoading;
  final bool hasError;

  /// The chosen address is outside this store's delivery zone.
  final bool deliveryUnavailable;
}

/// Step one: where the order goes. Shipping cannot be priced until this is
/// answered, so it comes before payment.
class CheckoutAddressSection extends StatelessWidget {
  const CheckoutAddressSection({super.key, required this.data});

  final CheckoutAddressSectionDto data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutSectionLabel(
          title: LocaleKeys.deliveryAddress.tr,
          // The coverage failure is the more specific of the two, so it wins:
          // "select an address" reads as nonsense next to one already selected.
          errorMessage: data.deliveryUnavailable
              ? LocaleKeys.vendorDoesNotDeliver.tr
              : (data.hasError ? LocaleKeys.selectAddress.tr : null),
        ),
        if (data.isLoading)
          const _AddressShimmer()
        else ...[
          for (final address in data.addresses) ...[
            CheckoutAddressCard(
              address: address,
              isSelected: address.id == data.selectedAddressId,
              onTap: () => data.onSelect(address.id),
            ),
            const SizedBox(height: 9),
          ],
          _AddAddressLink(onTap: data.onAddNew),
        ],
      ],
    );
  }
}

class _AddAddressLink extends StatelessWidget {
  const _AddAddressLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          '+ ${LocaleKeys.addNewAddress.tr}'.toUpperCase(),
          style: MarketplaceTypography.linkCaps.copyWith(
            color: palette.brand,
            letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.1,
          ),
        ),
      ),
    );
  }
}

class _AddressShimmer extends StatelessWidget {
  const _AddressShimmer();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Shimmer.fromColors(
      baseColor: palette.shimmerBase,
      highlightColor: palette.shimmerHighlight,
      child: Column(
        children: List.generate(
          2,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: palette.shimmerBase,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
