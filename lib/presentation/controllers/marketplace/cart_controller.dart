import 'package:get/get.dart';
import 'package:marketplace/domain/entities/marketplace/local_cart_item_entity.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';
import 'package:marketplace/domain/entities/marketplace/cart_vendor_group.dart';
import 'package:marketplace/domain/entities/marketplace/checkout_args.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/get_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/add_to_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/remove_from_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/update_local_cart_quantity_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/clear_local_cart_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/main_navigation_controller.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/components/marketplace/auth/sign_in_prompt_sheet.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/app/routes/app_router.dart';

class CartController extends GetxController {
  // ── Dependencies injected in onInit ───────────────────────
  late final GetLocalCartUseCase _getCart;
  late final AddToLocalCartUseCase _addToCart;
  late final RemoveFromLocalCartUseCase _removeItem;
  late final UpdateLocalCartQuantityUseCase _updateQty;
  late final ClearLocalCartUseCase _clearCart;

  // ── Reactive state ─────────────────────────────────────────
  final items = <LocalCartItemEntity>[].obs;
  final isLoading = true.obs;
  final isCheckingOut = false.obs;

  // ── Computed getters ───────────────────────────────────────

  /// The cart split by store. Each group checks out on its own.
  List<CartVendorGroup> get vendorGroups => CartVendorGroup.from(items);

  /// Total quantity of all items in cart — used for the bottom nav badge.
  int get cartCount => items.fold(0, (sum, e) => sum + e.quantity);

  /// Goods across every store. Informational: it is never charged as one
  /// amount, because each store is paid for separately.
  double get cartTotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  /// What the original prices would have cost, minus what is being charged.
  /// Already reflected in the line prices — display only, never subtracted.
  double get savings => items.fold(0, (sum, item) => sum + item.lineSaving);

  bool get hasItems => items.isNotEmpty;

  // ── Lifecycle ──────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initDependencies();
    loadCart();
  }

  void _initDependencies() {
    _getCart = Get.find<GetLocalCartUseCase>();
    _addToCart = Get.find<AddToLocalCartUseCase>();
    _removeItem = Get.find<RemoveFromLocalCartUseCase>();
    _updateQty = Get.find<UpdateLocalCartQuantityUseCase>();
    _clearCart = Get.find<ClearLocalCartUseCase>();
  }

  // ── Operations ─────────────────────────────────────────────

  void loadCart() {
    isLoading.value = true;
    items.assignAll(_getCart.call());
    isLoading.value = false;
    _syncNavBadge();
  }

  /// Called from ProductDetailsController / product card to add an item.
  Future<void> addProduct(ProductEntity product, int quantity) async {
    await _addToCart.call(product, quantity);
    _refresh();
  }

  Future<void> removeItem(String productId) async {
    await _removeItem.call(productId);
    _refresh();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    await _updateQty.call(productId, quantity);
    _refresh();
  }

  /// Checks out one store's group. Every other group stays in the cart, so a
  /// customer buying from three makers places three orders without losing the
  /// other two baskets — same as the web client.
  void checkoutGroup(CartVendorGroup group) {
    if (group.items.isEmpty) return;

    final args = CheckoutArgs(
      vendorId: group.vendorId,
      vendorName: group.vendorName,
      vendorLogoUrl: group.vendorLogoUrl,
      items: group.items
          .map((i) => (
                productId: i.productId,
                quantity: i.quantity,
                imageUrl: i.imageUrl,
                productName: i.productName,
                productPrice: i.price
              ))
          .toList(),
      subtotal: group.subtotal,
      discount: group.savings,
    );

    // Checkout is where a guest has to become a customer: shipping fee,
    // payment methods and `POST /orders/checkout` are all bearer-only. The
    // basket rides along with the guard, so signing in lands on this vendor's
    // checkout rather than back on an empty cart.
    if (!AuthGuard.ensureSignedIn(
      reasonKey: LocaleKeys.signInRequiredCheckout,
      intendedRoute: Routes.MARKETPLACE_CHECKOUT,
      arguments: args,
    )) {
      return;
    }

    AppRouter.toNamed(Routes.MARKETPLACE_CHECKOUT, arguments: args);
  }

  /// Opens a store profile from a cart group, once there is a session for it.
  void openStore(String vendorId) {
    if (vendorId.isEmpty) return;
    if (!AuthGuard.ensureSignedIn(
      reasonKey: LocaleKeys.signInRequiredStores,
      intendedRoute: Routes.MARKETPLACE_SELLER,
      arguments: vendorId,
    )) {
      return;
    }
    AppRouter.toNamed(Routes.MARKETPLACE_SELLER, arguments: vendorId);
  }

  /// Empties one store's items after its order is placed. The web calls this
  /// `clearVendor`; the other stores' groups are left untouched.
  Future<void> clearVendor(String vendorId) async {
    final doomed = items.where((item) => item.sellerId == vendorId).toList();
    for (final item in doomed) {
      await _removeItem.call(item.productId);
    }
    _refresh();
  }

  Future<void> clearCart() async {
    await _clearCart.call();
    _refresh();
  }

  // ── Helpers ────────────────────────────────────────────────

  void _refresh() {
    items.assignAll(_getCart.call());
    _syncNavBadge();
  }

  void _syncNavBadge() {
    try {
      Get.find<MainNavigationController>().updateCartCount(cartCount);
    } catch (_) {
      // MainNavigationController not yet registered (e.g., during tests)
    }
  }
}
