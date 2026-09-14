import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_icons.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';

/// Sticky bottom bar: quantity stepper plus the primary action.
///
/// The cart is client-side — there is no cart endpoint — so the quantity here
/// is local state right up until the product is handed to `CartController`,
/// exactly as the web client does it.
///
/// When the product is not orderable the stepper disappears and the action
/// becomes an inert "currently unavailable" pill: nothing to notify, nothing to
/// pre-order, because the contract offers neither.
class ProductAddToCartBar extends StatelessWidget {
  const ProductAddToCartBar({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAddToCart,
    this.isAvailable = true,
    this.isAdding = false,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onAddToCart;
  final bool isAvailable;
  final bool isAdding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          decoration: BoxDecoration(
            color: palette.surface
                .withValues(alpha: palette.isDark ? 0.72 : 0.82),
            border: Border(top: BorderSide(color: palette.hairline)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (isAvailable) ...[
                    _Stepper(
                      quantity: quantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
                    const SizedBox(width: 11),
                  ],
                  Expanded(
                    child: isAvailable
                        ? _PrimaryAction(
                            isAdding: isAdding,
                            onTap: onAddToCart,
                          )
                        : const _UnavailableAction(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final canDecrement = quantity > 1;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        border: Border.all(color: palette.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: MarketplaceIcons.minus,
            onTap: canDecrement ? onDecrement : null,
            color: canDecrement ? palette.textSecondary : palette.textMuted,
          ),
          SizedBox(
            width: 26,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: MarketplaceTypography.rowTitle.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
          ),
          _StepButton(
            icon: MarketplaceIcons.plus,
            onTap: onIncrement,
            color: palette.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 26,
        height: 48,
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.isAdding, required this.onTap});

  final bool isAdding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: isAdding ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.brand,
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        ),
        child: isAdding
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.onBrand,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MarketplaceIcons.myOrder,
                    size: 16,
                    color: palette.onBrand,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    LocaleKeys.addToCart.tr,
                    style: MarketplaceTypography.buttonLabel.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: palette.onBrand,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _UnavailableAction extends StatelessWidget {
  const _UnavailableAction();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        border: Border.all(color: palette.hairline),
      ),
      child: Text(
        LocaleKeys.currentlyUnavailable.tr,
        style: MarketplaceTypography.buttonLabel.copyWith(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: palette.textMuted,
        ),
      ),
    );
  }
}
