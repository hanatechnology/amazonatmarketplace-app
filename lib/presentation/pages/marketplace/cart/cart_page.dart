import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/marketplace/cart/cart_vendor_group_card.dart';
import '../../../../core/components/marketplace/empty_cart_view.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../domain/entities/marketplace/cart_vendor_group.dart';
import '../../../controllers/marketplace/cart_controller.dart';
import '../../../controllers/marketplace/main_navigation_controller.dart';

/// The cart, grouped by store.
///
/// An order can only carry one vendor's items, so each store's group has its
/// own subtotal and its own checkout — paying for one leaves the others in the
/// cart. That is what the web client does, and why there is no global CTA and
/// no per-item selection here.
class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  static const double _gutter = 20.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const _CartLoading();
          }

          if (!controller.hasItems) {
            return EmptyCartView(onShopNow: _goShopping);
          }

          final groups = controller.vendorGroups;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CartHeader(groups: groups),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(_gutter, 4, _gutter, 12),
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final group = groups[index];
                    return CartVendorGroupCard(
                      group: group,
                      onCheckout: () => controller.checkoutGroup(group),
                      // The store profile is bearer-only. Guarding here rather
                      // than letting the route middleware catch it keeps the
                      // vendor id, so signing in opens the store the customer
                      // tapped.
                      onOpenStore: () => controller.openStore(group.vendorId),
                      onQuantityChanged: (item, quantity) =>
                          controller.updateQuantity(item.productId, quantity),
                      onRemove: (item) => controller.removeItem(item.productId),
                    );
                  },
                ),
              ),
              _CartSummaryBar(groups: groups),
            ],
          );
        }),
      ),
    );
  }

  /// The cart is a tab, so "shop now" switches tabs rather than popping.
  static void _goShopping() {
    if (Get.isRegistered<MainNavigationController>()) {
      Get.find<MainNavigationController>().changePage(0);
    }
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.groups});

  final List<CartVendorGroup> groups;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final itemCount = groups.fold<int>(0, (sum, g) => sum + g.itemCount);

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(CartPage._gutter, 12, CartPage._gutter, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.myCart.tr,
            style: MarketplaceTypography.heroDisplay.copyWith(
              fontSize: 30,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.cartItemsFrom.trParams({
              'items': LocaleKeys.itemsCountOne.trPluralParams(
                LocaleKeys.itemsCount,
                itemCount,
                {'count': '$itemCount'},
              ),
              'stores': LocaleKeys.storesCountOne.trPluralParams(
                LocaleKeys.storesCount,
                groups.length,
                {'count': '${groups.length}'},
              ),
            }),
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 11.5,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Per-store lines, then the cart total.
///
/// The total is informational — it is never charged as one amount, because each
/// store is paid for separately. The note under it says so.
class _CartSummaryBar extends StatelessWidget {
  const _CartSummaryBar({required this.groups});

  final List<CartVendorGroup> groups;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cartTotal = groups.fold<double>(0, (sum, g) => sum + g.subtotal);

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(CartPage._gutter, 13, CartPage._gutter, 0),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: MarketplaceSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final group in groups)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.vendorName,
                          style: MarketplaceTypography.rowMeta.copyWith(
                            fontSize: 11.5,
                            color: palette.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _Money(
                        amount: group.subtotal,
                        size: 11.5,
                        color: palette.textPrimary,
                      ),
                    ],
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.only(top: 9),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: palette.hairline)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        LocaleKeys.cartTotal.tr,
                        style: MarketplaceTypography.rowTitle.copyWith(
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    Text.rich(
                      textDirection: TextDirection.ltr,
                      TextSpan(
                        text: PriceFormatter.amount(cartTotal),
                        style: MarketplaceTypography.priceDisplay.copyWith(
                          fontSize: 22,
                          color: palette.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text: ' ${PriceFormatter.unit()}',
                            style: MarketplaceTypography.priceUnit.copyWith(
                              color: palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                LocaleKeys.cartStoresNote.tr,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 10,
                  height: 1.6,
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Money extends StatelessWidget {
  const _Money({required this.amount, required this.size, required this.color});

  final double amount;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Text.rich(
      textDirection: TextDirection.ltr,
      TextSpan(
        text: PriceFormatter.amount(amount),
        style: MarketplaceTypography.rowMeta.copyWith(
          fontSize: size,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        children: [
          TextSpan(
            text: ' ${PriceFormatter.unit()}',
            style: MarketplaceTypography.priceUnit.copyWith(
              color: palette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLoading extends StatelessWidget {
  const _CartLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.palette.brand),
    );
  }
}
