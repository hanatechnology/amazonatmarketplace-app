import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/components/marketplace/checkout/checkout_address_section.dart';
import '../../../../core/components/marketplace/checkout/checkout_bottom_bar.dart';
import '../../../../core/components/marketplace/checkout/checkout_order_summary.dart';
import '../../../../core/components/marketplace/checkout/checkout_payment_section.dart';
import '../../../../core/components/layout/keyboard_aware_bottom_bar.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../controllers/marketplace/checkout_controller.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';

/// Checkout for exactly one store.
///
/// The cart may hold several stores; an order cannot — `mixed_vendors` is a
/// server error — so this screen names the store it is paying for before
/// anything else, and the other groups stay in the cart untouched.
///
/// Steps run in the order the API forces: address first, because shipping
/// cannot be priced without one, then payment, then the wallet number when the
/// method needs it.
class CheckoutPage extends GetView<CheckoutController> {
  const CheckoutPage({super.key});

  static const double _gutter = 20;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: StickyBackBar(
        child:  SafeArea(
        bottom: false,
        child: Obx(() {
          final args = controller.checkoutArgs;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _NavRow(),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: Text(
                    LocaleKeys.checkoutTitle.tr,
                    style: MarketplaceTypography.heroDisplay.copyWith(
                      fontSize: 28,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                _StoreBar(
                  vendorName: args.vendorName,
                  vendorLogoUrl: args.vendorLogoUrl,
                  itemCount: args.items.length,
                ),
                const SizedBox(height: 16),
                CheckoutAddressSection(
                  data: CheckoutAddressSectionDto(
                    addresses: controller.addresses,
                    selectedAddressId: controller.selectedAddressId.value,
                    isLoading: controller.isLoadingAddresses.value,
                    hasError: controller.addressError.value,
                    deliveryUnavailable: controller.deliveryUnavailable.value,
                    onSelect: controller.selectAddress,
                    onAddNew: controller.navigateToAddAddress,
                  ),
                ),
                const SizedBox(height: 18),
                CheckoutOrderSummary(
                  items: args.items,
                  isExpanded: controller.isSummaryExpanded.value,
                  onToggle: controller.toggleSummary,
                ),
                const SizedBox(height: 18),
                CheckoutPaymentSection(
                  data: CheckoutPaymentSectionDto(
                    methods: controller.paymentMethods,
                    selectedMethod: controller.selectedPayment.value,
                    isLoading: controller.isLoadingMethods.value,
                    hasError: controller.paymentError.value,
                    onSelect: controller.selectPaymentMethod,
                    edfaliMobileController: controller.edfaliMobile,
                    edfaliMobileError: controller.edfaliMobileError.value,
                  ),
                ),
              ],
            ),
          );
        }),
      )),
      bottomNavigationBar: KeyboardAwareBottomBar(
        child: Obx(
          () => CheckoutBottomBar(
            data: CheckoutBottomBarDto(
              subtotal: controller.checkoutArgs.total,
              total: controller.total,
              shippingFee: controller.shippingFee.value?.chargeable,
              isShippingLoading: controller.isLoadingShipping.value,
              isLoading: controller.isCheckingOut.value,
              // Always live: tapping with a step missing is how the customer
              // finds out which one, and a dead button explains nothing.
              isEnabled: true,
              onPlaceOrder: controller.placeOrder,
            ),
          ),
        ),
      ),
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

/// Names the store this checkout belongs to, with its item count.
class _StoreBar extends StatelessWidget {
  const _StoreBar({
    required this.vendorName,
    required this.itemCount,
    this.vendorLogoUrl = '',
  });

  final String vendorName;
  final String vendorLogoUrl;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(MarketplaceRadius.md + 2),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            // The storefront glyph is the fallback, not the default: a store
            // that has a logo should be recognisable by it here too.
            child: vendorLogoUrl.isEmpty
                ? Icon(
                    Icons.storefront_outlined,
                    size: 15,
                    color: palette.textSecondary,
                  )
                : AppNetworkImage(
                    imageUrl: vendorLogoUrl,
                    width: 30,
                    height: 30,
                    borderRadius: 10,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.payingStore.tr,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    fontSize: 9.5,
                    color: palette.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vendorName,
                  style: MarketplaceTypography.rowTitle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            LocaleKeys.itemsCountOne.trPluralParams(
              LocaleKeys.itemsCount,
              itemCount,
              {'count': '$itemCount'},
            ),
            style: MarketplaceTypography.rowMeta.copyWith(
              color: palette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
