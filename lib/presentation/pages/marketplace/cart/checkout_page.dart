import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/components/marketplace/cart_price_summary.dart';
import '../../../../core/components/marketplace/checkout/checkout_order_summary.dart';
import '../../../../core/components/marketplace/checkout/checkout_order_item_row.dart';
import '../../../../core/components/marketplace/checkout/checkout_address_section.dart';
import '../../../../core/components/marketplace/checkout/checkout_payment_section.dart';
import '../../../../core/components/marketplace/checkout/checkout_bottom_bar.dart';
import '../../../controllers/marketplace/checkout_controller.dart';

class CheckoutPage extends GetView<CheckoutController> {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: AppBar(
        title: Text(LocaleKeys.checkoutTitle.tr),
        elevation: 0,
        backgroundColor: MarketplaceColors.surface,
        foregroundColor: MarketplaceColors.textPrimary,
        centerTitle: false,
      ),
      body: Obx(() {
        final args = controller.checkoutArgs;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: MarketplaceSpacing.screenPaddingH,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: MarketplaceSpacing.sectionGap),

                  // ── Order Summary (collapsible) ────────────────
                  CheckoutOrderSummary(
                    data: CheckoutOrderSummaryDto(
                      items: args.items
                          .map((i) => CheckoutOrderItemDto(
                                imageUrl: i.imageUrl,
                                name: i.productName,
                                quantity: i.quantity,
                                unitPrice: i.productPrice,
                              ))
                          .toList(),
                      subtotal: args.subtotal,
                      isExpanded: controller.isSummaryExpanded.value,
                      onToggle: controller.toggleSummary,
                    ),
                  ),
                  const SizedBox(height: MarketplaceSpacing.sectionGap),

                  // ── Delivery Address ───────────────────────────
                  CheckoutAddressSection(
                    data: CheckoutAddressSectionDto(
                      addresses: controller.addresses,
                      selectedAddressId: controller.selectedAddressId.value,
                      isLoading: controller.isLoadingAddresses.value,
                      hasError: controller.addressError.value,
                      onSelect: controller.selectAddress,
                      onAddNew: controller.navigateToAddAddress,
                    ),
                  ),
                  const SizedBox(height: MarketplaceSpacing.sectionGap),

                  // ── Payment Method ────────────────────────────
                  CheckoutPaymentSection(
                    data: CheckoutPaymentSectionDto(
                      selectedMethod: controller.selectedPayment.value,
                      hasError: controller.paymentError.value,
                      onSelect: controller.selectPaymentMethod,
                    ),
                  ),
                  const SizedBox(height: MarketplaceSpacing.sectionGap),

                  // ── Order Total ───────────────────────────────
                  CartPriceSummary(
                    data: CartPriceSummaryDto(
                      subtotal: args.subtotal,
                      discount: args.discount,
                      total: args.total,
                    ),
                  ),

                  // Bottom padding for sticky bar
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() => CheckoutBottomBar(
            data: CheckoutBottomBarDto(
              total: controller.total,
              isLoading: controller.isCheckingOut.value,
              isEnabled: true,
              onPlaceOrder: controller.placeOrder,
            ),
          )),
    );
  }
}
