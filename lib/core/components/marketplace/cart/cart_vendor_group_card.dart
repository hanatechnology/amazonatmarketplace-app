import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../utils/price_formatter.dart';
import '../../../../domain/entities/marketplace/cart_vendor_group.dart';
import '../../../../domain/entities/marketplace/local_cart_item_entity.dart';
import '../app_network_image.dart';

/// One store's basket: header, its items, and its own subtotal + checkout.
///
/// Checkout is per store because an order can only carry one vendor's items —
/// so the group, not a selection, is the unit the customer acts on.
class CartVendorGroupCard extends StatelessWidget {
  const CartVendorGroupCard({
    super.key,
    required this.group,
    required this.onCheckout,
    required this.onOpenStore,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartVendorGroup group;
  final VoidCallback onCheckout;
  final VoidCallback onOpenStore;
  final void Function(LocalCartItemEntity item, int quantity) onQuantityChanged;
  final void Function(LocalCartItemEntity item) onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.hairline),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(group: group, onTap: onOpenStore),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
            child: Column(
              children: [
                for (var i = 0; i < group.items.length; i++)
                  _ItemRow(
                    item: group.items[i],
                    showDivider: i > 0,
                    onQuantityChanged: (quantity) =>
                        onQuantityChanged(group.items[i], quantity),
                    onRemove: () => onRemove(group.items[i]),
                  ),
              ],
            ),
          ),
          _Footer(group: group, onCheckout: onCheckout),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.group, required this.onTap});

  final CartVendorGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: palette.surfaceSunken,
          border: Border(bottom: BorderSide(color: palette.hairline)),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.background,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 14,
                color: palette.textSecondary,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                group.vendorName,
                style: MarketplaceTypography.rowTitle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              LocaleKeys.itemsCountOne.trPluralParams(
                LocaleKeys.itemsCount,
                group.itemCount,
                {'count': '${group.itemCount}'},
              ),
              style: MarketplaceTypography.rowMeta.copyWith(
                color: palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.showDivider,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final LocalCartItemEntity item;
  final bool showDivider;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: EdgeInsets.only(top: showDivider ? 11 : 0),
      margin: EdgeInsets.only(top: showDivider ? 11 : 0),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(top: BorderSide(color: palette.hairline))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 58,
              height: 58,
              color: palette.surfaceSunken,
              child: AppNetworkImage(
                imageUrl: item.imageUrl,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: MarketplaceTypography.cardHeading.copyWith(
                          fontSize: 12,
                          color: palette.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8),
                        child: Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: palette.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Text.rich(
                      textDirection: TextDirection.ltr,
                      TextSpan(
                        text: PriceFormatter.amount(item.price),
                        style: MarketplaceTypography.priceDisplay.copyWith(
                          fontSize: 14,
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
                    if (item.originalPrice != null &&
                        item.originalPrice! > item.price) ...[
                      const SizedBox(width: 6),
                      Text(
                        PriceFormatter.amount(item.originalPrice!),
                        textDirection: TextDirection.ltr,
                        style: MarketplaceTypography.rowMeta.copyWith(
                          fontSize: 9.5,
                          color: palette.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const Spacer(),
                    _QuantityStepper(
                      quantity: item.quantity,
                      onChanged: onQuantityChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Widget button(IconData icon, VoidCallback? onTap) => GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Icon(
            icon,
            size: 15,
            color: onTap == null ? palette.textMuted : palette.textSecondary,
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        border: Border.all(color: palette.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // One is the floor: removing the last unit is the ✕, not a quiet
          // decrement to zero.
          button(
            Icons.remove_rounded,
            quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Text(
              '$quantity',
              textDirection: TextDirection.ltr,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
          ),
          button(Icons.add_rounded, () => onChanged(quantity + 1)),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.group, required this.onCheckout});

  final CartVendorGroup group;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.hairline)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocaleKeys.subtotal.tr,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 9.5,
                  color: palette.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text.rich(
                textDirection: TextDirection.ltr,
                TextSpan(
                  text: PriceFormatter.amount(group.subtotal),
                  style: MarketplaceTypography.priceDisplay.copyWith(
                    fontSize: 17,
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
          const Spacer(),
          GestureDetector(
            onTap: onCheckout,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.brand,
                borderRadius: BorderRadius.circular(MarketplaceRadius.full),
              ),
              child: Text(
                LocaleKeys.checkout.tr,
                style: MarketplaceTypography.pillLabel.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: palette.onBrand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
