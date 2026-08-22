import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../core/states/app_state.dart';
import '../../../domain/entities/marketplace/banner_entity.dart';
import '../../../domain/entities/marketplace/category_entity.dart';
import '../../../domain/entities/marketplace/product_entity.dart';
import '../../../domain/usecases/marketplace/banner/get_banners_use_case.dart';
import '../../../domain/usecases/base_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_products_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_products_page_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_categories_use_case.dart';
import '../../../domain/usecases/marketplace/product/search_products_use_case.dart';

class HomeController extends BaseStateController<GetProductsUseCase> {
  /// Matches the API default page size for `/products`.
  static const int kPageSize = 20;

  // ── Operation keys ─────────────────────────────────────
  static const String kCategories = 'categories';
  static const String kProducts = 'products';
  static const String kSearch = 'search';
  static const String kBanners = 'banners';

  // ── Local reactive state ───────────────────────────────
  final searchQuery = ''.obs;
  final activeBannerIndex = 0.obs;
  final hasMoreProducts = false.obs;
  final isLoadingMoreProducts = false.obs;

  int _productsPage = 1;

  /// Banners from `GET /banners`, ordered by the backend's `sort_order`.
  List<BannerEntity> get banners =>
      getOperationData<List<BannerEntity>>(kBanners) ?? const [];

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  /// Load banners + categories + products in parallel
  Future<void> loadHomeData() async {
    // Products are paginated, so they load through their own paginated path
    // rather than the parallel group — but still concurrently with it.
    await Future.wait([
      handleMultipleStates([
        StateOperation<List<BannerEntity>>(
          kBanners,
          () => Get.find<GetBannersUseCase>().execute(),
        ),
        StateOperation<List<CategoryEntity>>(
          kCategories,
          () => Get.find<GetCategoriesUseCase>().execute(),
        ),
      ]),
      loadProducts(),
    ]);
  }

  /// A PRODUCT banner opens the product; an IMAGE_LINK banner opens its URL
  /// outside the app. A banner with no destination is inert.
  Future<void> onBannerTap(BannerEntity banner) async {
    if (!banner.isTappable) return;

    switch (banner.type) {
      case BannerType.product:
        Get.toNamed(Routes.MARKETPLACE_PRODUCT, arguments: banner.productId);
      case BannerType.imageLink:
        final uri = Uri.tryParse(banner.linkUrl!);
        if (uri == null) return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Pull-to-refresh
  Future<void> refresh() async {
    await loadHomeData();
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      // Reset to the unfiltered first page.
      await loadProducts();
      return;
    }
    await handleState(
      kSearch,
      () => Get.find<SearchProductsUseCase>().call(query),
    );
  }

  /// Load (or reload) the first page of products.
  Future<void> loadProducts() async {
    _productsPage = 1;
    await _fetchProductsPage(append: false);
  }

  /// Append the next page. No-op while a page is in flight or once exhausted.
  Future<void> loadMoreProducts() async {
    if (isLoadingMoreProducts.value || !hasMoreProducts.value) return;
    isLoadingMoreProducts.value = true;
    _productsPage += 1;
    await _fetchProductsPage(append: true);
    isLoadingMoreProducts.value = false;
  }

  Future<void> _fetchProductsPage({required bool append}) async {
    await handlePaginationState<ProductEntity>(
      kProducts,
      () async {
        final state = await Get.find<GetProductsPageUseCase>().call(
          PaginationInput(page: _productsPage, limit: kPageSize),
        );
        return state.when(
          onInitial: () => const AppStateInitial<List<ProductEntity>>(),
          onLoading: () => const AppStateLoading<List<ProductEntity>>(),
          onSuccess: (paged, message) {
            hasMoreProducts.value = paged.hasMore;
            _productsPage = paged.currentPage;
            return AppStateSuccess(paged.items, message: message);
          },
          onError: (message, code) {
            // Roll the cursor back so a retry re-requests the failed page.
            if (append && _productsPage > 1) _productsPage -= 1;
            return AppStateError<List<ProductEntity>>(message, code: code);
          },
        );
      },
      append: append,
    );
  }

  void onBannerChanged(int index) {
    activeBannerIndex.value = index;
  }
}
