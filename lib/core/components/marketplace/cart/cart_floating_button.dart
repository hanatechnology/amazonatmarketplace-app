import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../presentation/controllers/marketplace/cart_controller.dart';
import '../../../../presentation/controllers/marketplace/main_navigation_controller.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_icons.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';

/// Shortcut back to the cart from any screen that is pushed over the shell.
///
/// Product details, a category listing, search results and a store page are all
/// root-navigator routes, so the tab bar — and with it the cart badge — is
/// hidden while they are open. Without this, adding three products means three
/// trips back through the stack to check the basket.
///
/// It only appears once there is something in the cart: an empty basket has
/// nothing to go back to, and the button would just cover product artwork.
class CartFloatingButton extends StatelessWidget {
  const CartFloatingButton({super.key});

  static const double _size = 52;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cart = Get.find<CartController>();

    return Obx(() {
      final count = cart.cartCount;
      if (count == 0) return const SizedBox.shrink();

      return Padding(
        // Lifts it clear of the "add" buttons on the last row of product cards,
        // which the Scaffold's own 16pt offset leaves it sitting on top of.
        padding: const EdgeInsets.only(bottom: 10),
        child: Semantics(
          label: LocaleKeys.backToCart.tr,
          button: true,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _openCart();
            },
            child: Container(
              width: _size,
              height: _size,
              // Reads as navigation, not as an action: the "add" buttons on the
              // product cards underneath are solid brand circles of almost this
              // size, and a second brand circle over them is a mis-tap waiting to
              // happen. This borrows the tab bar's pill instead — same surface,
              // same hairline, so it reads as "the bar you left behind".
              decoration: BoxDecoration(
                color: palette.navSurface,
                shape: BoxShape.circle,
                border: Border.all(color: palette.hairline),
                boxShadow: [
                  BoxShadow(
                    color: Color.alphaBlend(
                      palette.textPrimary.withValues(alpha: 0.12),
                      Colors.transparent,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: AlignmentDirectional.center,
                children: [
                  Icon(
                    MarketplaceIcons.cartFilled,
                    size: 22,
                    color: palette.brand,
                  ),
                  // Rides the rim rather than sitting on the glyph — nothing
                  // clips it, and the icon stays readable.
                  PositionedDirectional(
                    top: -3,
                    end: -3,
                    child: _CountBadge(count: count),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// The cart is a tab, not a route, so this returns to the shell and selects
  /// it. A stack that no longer holds the shell — a screen opened straight from
  /// a notification — is replaced by it instead.
  static void _openCart() {
    if (Get.isRegistered<MainNavigationController>() &&
        AppRouteObserver.instance.contains(Routes.MARKETPLACE_MAIN)) {
      Get.find<MainNavigationController>()
          .changePage(MainNavigationController.cartTab);
      Get.until((route) => route.settings.name == Routes.MARKETPLACE_MAIN);
      return;
    }

    Get.offAllNamed(
      Routes.MARKETPLACE_MAIN,
      arguments: <String, dynamic>{'tab': MainNavigationController.cartTab},
    );
  }
}

/// The quantity, capped so a long basket cannot widen the badge past the button.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: palette.brand,
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        border: Border.all(color: palette.navSurface, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        // Latin digits, left-to-right, inside an Arabic interface too.
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        style: MarketplaceTypography.navLabelSmall.copyWith(
          color: palette.onBrand,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
    );
  }
}
