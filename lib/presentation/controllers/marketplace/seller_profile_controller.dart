import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';
import 'package:marketplace/domain/entities/marketplace/seller_entity.dart';
import 'package:marketplace/domain/usecases/marketplace/seller/get_seller_details_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/seller/get_seller_products_use_case.dart';

const String kSellerProfile = 'sellerProfile';
const String kSellerProducts = 'sellerProducts';

class SellerProfileController
    extends BaseStateController<GetSellerDetailsUseCase> {
  static const int kPageSize = 20;

  late String sellerId;

  final hasMore = false.obs;
  final isLoadingMore = false.obs;

  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    sellerId = Get.arguments as String? ?? '';
    if (sellerId.isNotEmpty) {
      loadSellerProfile();
    }
  }

  /// Products can only be requested once the store is loaded — the list
  /// endpoint does not return the store name, so it has to be carried over.
  Future<void> loadSellerProfile() async {
    await handleState<SellerEntity>(
      kSellerProfile,
      () => useCase.call(sellerId),
      onSuccess: (_, __) => loadProducts(),
    );
  }

  Future<void> refreshSellerProfile() => loadSellerProfile();

  Future<void> loadProducts() async {
    _page = 1;
    await _fetchPage(append: false);
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    _page += 1;
    await _fetchPage(append: true);
    isLoadingMore.value = false;
  }

  Future<void> _fetchPage({required bool append}) async {
    final seller = this.seller;
    if (seller == null) return;

    await handlePaginationState<ProductEntity>(
      kSellerProducts,
      () async {
        final state = await Get.find<GetSellerProductsUseCase>().call(
          SellerProductsInput(
            sellerId: sellerId,
            storeName: seller.name,
            page: _page,
            limit: kPageSize,
          ),
        );
        return state.when(
          onInitial: () => const AppStateInitial<List<ProductEntity>>(),
          onLoading: () => const AppStateLoading<List<ProductEntity>>(),
          onSuccess: (paged, message) {
            hasMore.value = paged.hasMore;
            _page = paged.currentPage;
            return AppStateSuccess(paged.items, message: message);
          },
          onError: (message, code) {
            // Roll the cursor back so a retry re-requests the failed page.
            if (append && _page > 1) _page -= 1;
            return AppStateError<List<ProductEntity>>(message, code: code);
          },
        );
      },
      append: append,
    );
  }

  SellerEntity? get seller => getOperationData<SellerEntity>(kSellerProfile);

  void openProduct(ProductEntity product) =>
      Get.toNamed(Routes.MARKETPLACE_PRODUCT, arguments: product.id);
}
