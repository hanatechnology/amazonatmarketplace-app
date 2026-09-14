import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../domain/entities/marketplace/product_details_entity.dart';
import '../../../domain/entities/marketplace/product_entity.dart';
import '../../../domain/usecases/marketplace/product/get_product_details_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_vendor_products_use_case.dart';
import 'cart_controller.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/theme/marketplace_spacing.dart';
import '../../../core/theme/marketplace_radius.dart';

class ProductDetailsController
    extends BaseStateController<GetProductDetailsUseCase> {
  // ── Operation keys ──────────────────────────────────────
  static const String kProduct = 'product';
  static const String kStoreProducts = 'store_products';

  /// How many siblings the "more from this store" rail asks for.
  static const int _railLength = 10;

  // ── Arguments ───────────────────────────────────────────
  late String productId;

  // ── Local reactive state ────────────────────────────────
  final quantity = 1.obs;
  final activeImageIndex = 0.obs;
  final isDescriptionExpanded = false.obs;
  final isAddingToCart = false.obs;

  /// The detail endpoint returns 404 for a product that is missing *or*
  /// inactive. Both land on the same "not found" screen, so the failure is
  /// tracked separately from a generic network error.
  final isNotFound = false.obs;

  @override
  void onInit() {
    super.onInit();
    productId = Get.arguments as String? ?? '';
    if (productId.isNotEmpty) loadProduct();
  }

  Future<void> loadProduct() async {
    isNotFound.value = false;
    await handleState<ProductDetailsEntity>(
      kProduct,
      () => useCase.call(productId),
      onSuccess: (product, _) {
        _clampQuantityToStock();
        loadStoreProducts(product);
      },
      onError: (_, code) => isNotFound.value = code == 404,
    );
  }

  @override
  Future<void> refresh() => loadProduct();

  /// The rail is secondary: it loads after the product and its failure never
  /// takes the page down with it.
  Future<void> loadStoreProducts(ProductDetailsEntity product) async {
    if (product.vendor.id.isEmpty) return;
    await handleState<List<ProductEntity>>(
      kStoreProducts,
      () => Get.find<GetVendorProductsUseCase>().call(
        VendorProductsInput(
          vendorId: product.vendor.id,
          excludeProductId: product.id,
          limit: _railLength,
        ),
      ),
    );
  }

  // ── Quantity ─────────────────────────────────────────────

  /// Highest quantity the customer may pick, or null when the endpoint
  /// reported no stock figure — then the stepper is left unbounded rather than
  /// blocking a product that is really orderable.
  int? get maxQuantity =>
      getOperationData<ProductDetailsEntity>(kProduct)?.maxOrderableQuantity;

  /// True once the stepper has reached the stock ceiling.
  bool get isAtStockLimit {
    final max = maxQuantity;
    return max != null && quantity.value >= max;
  }

  void increment() {
    final max = maxQuantity;
    if (max != null && quantity.value >= max) {
      // Say why the button stopped responding; a dead control reads as a bug.
      Get.closeAllSnackbars();
      Get.rawSnackbar(
        message: LocaleKeys.stockLimitReached.trParams({'count': '$max'}),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(MarketplaceSpacing.md),
        borderRadius: MarketplaceRadius.md,
      );
      return;
    }
    quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }

  /// Stock can drop while the page is open, so the chosen quantity is trimmed
  /// back whenever a fresh product lands.
  void _clampQuantityToStock() {
    final max = maxQuantity;
    if (max != null && quantity.value > max) quantity.value = max;
  }

  void onImageChanged(int index) => activeImageIndex.value = index;

  void toggleDescription() =>
      isDescriptionExpanded.value = !isDescriptionExpanded.value;

  // ── Add to cart ───────────────────────────────────────────
  Future<void> addToCart() async {
    if (isAddingToCart.value) return;
    final product = getOperationData<ProductDetailsEntity>(kProduct);
    if (product == null || !product.isActive) return;

    isAddingToCart.value = true;
    try {
      await Get.find<CartController>()
          .addProduct(product.toProductEntity(), quantity.value);
      Get.back();
    } finally {
      isAddingToCart.value = false;
    }
  }

  // ── Navigation ────────────────────────────────────────────
  void openStore() {
    final product = getOperationData<ProductDetailsEntity>(kProduct);
    final vendorId = product?.vendor.id ?? '';
    if (vendorId.isEmpty) return;
    Get.toNamed(Routes.MARKETPLACE_SELLER, arguments: vendorId);
  }

  void openCategory() {
    final product = getOperationData<ProductDetailsEntity>(kProduct);
    final category = product?.category;
    if (category == null || category.id.isEmpty) return;
    Get.toNamed(
      Routes.MARKETPLACE_PRODUCTS_LIST,
      arguments: <String, dynamic>{
        'categoryId': category.id,
        'categoryName': category.name,
      },
    );
  }

  /// A sibling from the same store replaces this page rather than stacking on
  /// top of it — otherwise browsing a store's rail builds an unbounded stack.
  void openProduct(ProductEntity product) => Get.offNamed(
        Routes.MARKETPLACE_PRODUCT,
        arguments: product.id,
        preventDuplicates: false,
      );

  void browseProducts() => Get.offNamed(Routes.MARKETPLACE_PRODUCTS_LIST);
}
