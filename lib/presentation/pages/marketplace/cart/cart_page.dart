import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/components/marketplace/cart_item_card.dart';
import '../../../../core/components/marketplace/cart_price_summary.dart';
import '../../../../core/components/marketplace/empty_cart_view.dart';
import '../../../../core/components/marketplace/loading_shimmer.dart';
import '../../../controllers/marketplace/cart_controller.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: AppBar(
        title: Text(LocaleKeys.myCart.tr),
        automaticallyImplyLeading: false, // Hidden when displayed in tab
        elevation: 0,
        backgroundColor: MarketplaceColors.surface,
        foregroundColor: MarketplaceColors.textPrimary,
        centerTitle: false,
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(right: MarketplaceSpacing.screenPaddingH),
            child: Obx(() {
              if (controller.isLoading.value || controller.items.isEmpty) {
                return const SizedBox.shrink();
              }
              return Center(
                child: Text(
                  LocaleKeys.items.trParams({
                    'count': controller.items.length.toString(),
                  }),
                  style: MarketplaceTypography.bodySecondary.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _LoadingView();
        }

        if (controller.items.isEmpty) {
          return EmptyCartView(
            onShopNow: () => Get.back(), // Typically Navigates home or pops tab
          );
        }

        return Column(
          children: [
            _ToolbarRow(controller: controller),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(
                  left: MarketplaceSpacing.screenPaddingH,
                  right: MarketplaceSpacing.screenPaddingH,
                  top: MarketplaceSpacing.sm,
                  bottom:
                      MarketplaceSpacing.xxl + 80, // Space for fab/bottom area
                ),
                itemCount: controller.items.length, // +1 for summary
                separatorBuilder: (_, index) {
                  if (index == controller.items.length - 1) {
                    return const SizedBox(height: MarketplaceSpacing.lg);
                  }
                  return const SizedBox(height: MarketplaceSpacing.md);
                },
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return Dismissible(
                    key: Key(item.productId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding:
                          const EdgeInsets.only(right: MarketplaceSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius:
                            BorderRadius.circular(MarketplaceRadius.cartItem),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: Colors.white, size: 28),
                    ),
                    onDismissed: (_) => controller.removeItem(item.productId),
                    child: CartItemCard(
                      imageUrl: item.imageUrl,
                      name: item.productName,
                      sellerName: item.sellerName,
                      price: item.price,
                      originalPrice: item.originalPrice,
                      discountPercent: item.discountPercent,
                      quantity: item.quantity,
                      isSelected: item.isSelected,
                      onTap: () => Get.toNamed('/marketplace/product',
                          arguments: item.productId),
                      onSelect: (_) =>
                          controller.toggleSelection(item.productId),
                      onDelete: () => controller.removeItem(item.productId),
                      onQuantityChange: (qty) =>
                          controller.updateQuantity(item.productId, qty),
                    ),
                  );
                },
              ),
            ),
            CartPriceSummary(
              data: CartPriceSummaryDto(
                subtotal: controller.subtotal,
                discount: controller.discount,
                total: controller.total,
              ),
            )
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value || controller.items.isEmpty) {
          return const SizedBox.shrink();
        }
        return _CheckoutBottomBar(controller: controller);
      }),
    );
  }
}

class _ToolbarRow extends StatelessWidget {
  const _ToolbarRow({required this.controller});

  final CartController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.screenPaddingH),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Select All Checkbox
          GestureDetector(
            onTap: controller.toggleSelectAll,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: controller.isAllSelected
                          ? MarketplaceColors.primary
                          : MarketplaceColors.stroke,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: controller.isAllSelected
                        ? MarketplaceColors.primary
                        : null,
                  ),
                  child: controller.isAllSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: MarketplaceColors.onPrimary,
                        )
                      : null,
                ),
                const SizedBox(width: MarketplaceSpacing.sm),
                Text(
                  LocaleKeys.selectAll.tr,
                  style: MarketplaceTypography.bodySecondary,
                ),
              ],
            ),
          ),
          // Selected Count
          Text(
            LocaleKeys.items.trParams(
                {'count': controller.selectedItems.length.toString()}),
            style: MarketplaceTypography.bodySecondary,
          ),
        ],
      ),
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar({required this.controller});

  final CartController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          MarketplaceSpacing.screenPaddingH,
          MarketplaceSpacing.sm,
          MarketplaceSpacing.screenPaddingH,
          MarketplaceSpacing.md,
        ),
        decoration: BoxDecoration(
          color: MarketplaceColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 8,
            )
          ],
        ),
        child: SizedBox(
          height: MarketplaceSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed:
                controller.hasSelection && !controller.isCheckingOut.value
                    ? controller.checkout
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: MarketplaceColors.primary,
              foregroundColor: MarketplaceColors.onPrimary,
              disabledBackgroundColor:
                  MarketplaceColors.primary.withOpacity(0.5),
              disabledForegroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MarketplaceRadius.button),
              ),
            ),
            child: controller.isCheckingOut.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    '${LocaleKeys.checkout.tr} (${controller.selectedItems.length})',
                    style: MarketplaceTypography.buttonLabel,
                  ),
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(MarketplaceSpacing.screenPaddingH),
      itemCount: 3,
      separatorBuilder: (_, __) =>
          const SizedBox(height: MarketplaceSpacing.md),
      itemBuilder: (_, __) => const CartItemShimmer(),
    );
  }
}
