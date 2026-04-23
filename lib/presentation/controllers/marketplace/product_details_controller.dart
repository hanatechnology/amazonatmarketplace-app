import 'package:get/get.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../domain/usecases/marketplace/product/get_product_details_use_case.dart';
import '../../../domain/entities/marketplace/product_details_entity.dart';
import 'cart_controller.dart';

class ProductDetailsController
    extends BaseStateController<GetProductDetailsUseCase> {
  // ── Operation keys ──────────────────────────────────────
  static const String kProduct = 'product';

  // ── Arguments ───────────────────────────────────────────
  late String productId;

  // ── Local reactive state ────────────────────────────────
  final quantity = 1.obs;
  final activeImageIndex = 0.obs;
  final isDescriptionExpanded = false.obs;
  final isAddingToCart = false.obs;

  @override
  void onInit() {
    super.onInit();
    productId = Get.arguments as String? ?? '';
    if (productId.isNotEmpty) loadProduct();
  }

  Future<void> loadProduct() async {
    await handleState(kProduct, () => useCase.call(productId));
  }

  Future<void> refresh() => loadProduct();

  // ── Quantity ─────────────────────────────────────────────
  void increment() => quantity.value++;
  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }

  void onImageChanged(int index) => activeImageIndex.value = index;

  void toggleDescription() =>
      isDescriptionExpanded.value = !isDescriptionExpanded.value;

  // ── Add to cart ───────────────────────────────────────────
  Future<void> addToCart() async {
    if (isAddingToCart.value) return;
    final ProductDetailsEntity? product =
        getOperationData<ProductDetailsEntity>(kProduct);
    if (product == null) return;

    isAddingToCart.value = true;
    try {
      await Get.find<CartController>()
          .addProduct(product.toProductEntity(), quantity.value);

      Get.back();
    } finally {
      isAddingToCart.value = false;
    }
  }

  /// Navigate to product's reviews page
  void goToReviews() {
    Get.toNamed('/marketplace/reviews', arguments: productId);
  }

  /// Navigate to all sellers offering this product
  void goToProductSellers() {
    Get.toNamed('/marketplace/product-sellers', arguments: productId);
  }
}
