import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/domain/entities/marketplace/local_cart_item_entity.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';
import 'package:marketplace/domain/entities/marketplace/checkout_args.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/get_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/add_to_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/remove_from_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/update_local_cart_quantity_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/toggle_local_cart_selection_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/set_local_cart_select_all_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/clear_local_cart_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/main_navigation_controller.dart';
import 'package:marketplace/app/routes/app_routes.dart';

class CartController extends GetxController {
  // ── Dependencies injected in onInit ───────────────────────
  late final GetLocalCartUseCase _getCart;
  late final AddToLocalCartUseCase _addToCart;
  late final RemoveFromLocalCartUseCase _removeItem;
  late final UpdateLocalCartQuantityUseCase _updateQty;
  late final ToggleLocalCartSelectionUseCase _toggleSelect;
  late final SetLocalCartSelectAllUseCase _setSelectAll;
  late final ClearLocalCartUseCase _clearCart;

  // ── Reactive state ─────────────────────────────────────────
  final items = <LocalCartItemEntity>[].obs;
  final isLoading = true.obs;
  final isCheckingOut = false.obs;

  // ── Computed getters ───────────────────────────────────────

  List<LocalCartItemEntity> get selectedItems =>
      items.where((e) => e.isSelected).toList();

  bool get isAllSelected =>
      items.isNotEmpty && items.every((e) => e.isSelected);

  /// Total quantity of all items in cart — used for the bottom nav badge.
  int get cartCount => items.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal => selectedItems.fold(0, (sum, e) => sum + e.lineTotal);

  double get discount => selectedItems.fold(0, (sum, e) => sum + e.lineSaving);

  double get total => subtotal - discount;

  bool get hasItems => items.isNotEmpty;
  bool get hasSelection => selectedItems.isNotEmpty;

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
    _toggleSelect = Get.find<ToggleLocalCartSelectionUseCase>();
    _setSelectAll = Get.find<SetLocalCartSelectAllUseCase>();
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

  Future<void> toggleSelection(String productId) async {
    await _toggleSelect.call(productId);
    _refresh();
  }

  Future<void> toggleSelectAll() async {
    await _setSelectAll.call(!isAllSelected);
    _refresh();
  }

  void checkout() {
    if (!hasSelection) return;

    // `POST /orders/checkout` accepts one vendor per order, so a selection
    // spanning several sellers has to be narrowed before continuing.
    final vendorIds = selectedItems.map((i) => i.sellerId).toSet();
    if (vendorIds.length > 1) {
      Get.snackbar(
        LocaleKeys.error.tr,
        LocaleKeys.singleSellerCheckout.tr,
      );
      return;
    }

    final args = CheckoutArgs(
      vendorId: vendorIds.first,
      items: selectedItems
          .map((i) => (
                productId: i.productId,
                quantity: i.quantity,
                imageUrl: i.imageUrl,
                productName: i.productName,
                productPrice: i.price
              ))
          .toList(),
      subtotal: subtotal,
      discount: discount,
    );

    Get.toNamed(Routes.MARKETPLACE_CHECKOUT, arguments: args);
  }

  // ignore: unused_element
  Future<void> _runClearCart() => _clearCart.call();

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

  void _showAddedSnackbar(String productName) {
    Get.snackbar(
      '',
      '',
      messageText: Text(
        LocaleKeys.addedToCart.tr,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green.shade600,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }
}
