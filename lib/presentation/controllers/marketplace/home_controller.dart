import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../core/states/app_state.dart';
import '../../../data/services/session_service.dart';
import '../../../domain/entities/marketplace/banner_entity.dart';
import '../../../domain/entities/marketplace/category_entity.dart';
import '../../../domain/entities/marketplace/product_entity.dart';
import '../../../domain/entities/marketplace/seller_entity.dart';
import '../../../domain/usecases/marketplace/banner/get_banners_use_case.dart';
import '../../../domain/usecases/base_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_products_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_products_page_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_categories_use_case.dart';
import '../../../domain/usecases/marketplace/seller/get_sellers_use_case.dart';
import 'package:marketplace/app/routes/app_router.dart';

class HomeController extends BaseStateController<GetProductsUseCase> {
  /// Matches the API default page size for `/products`.
  static const int kPageSize = 20;

  // ── Operation keys ─────────────────────────────────────
  static const String kCategories = 'categories';
  static const String kProducts = 'products';
  static const String kBanners = 'banners';
  static const String kStores = 'stores';

  /// How many stores the home "Featured stores" section shows.
  static const int kStoresPreviewSize = 3;

  // ── Local reactive state ───────────────────────────────
  final activeBannerIndex = 0.obs;

  /// Selected category pill. Empty means "All" — the home rail and grid are
  /// unfiltered; picking a category opens the products list instead, so this is
  /// only ever a visual selection.
  final hasMoreProducts = false.obs;
  final isLoadingMoreProducts = false.obs;

  int _productsPage = 1;

  /// Banners from `GET /banners`, ordered by the backend's `sort_order`.
  List<BannerEntity> get banners =>
      getOperationData<List<BannerEntity>>(kBanners) ?? const [];

  /// Stores from `GET /stores` — first page only, trimmed to the preview size.
  List<SellerEntity> get featuredStores =>
      getOperationData<List<SellerEntity>>(kStores) ?? const [];

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
        // `GET /stores` is the one home call that needs a bearer. For a guest
        // it is not attempted at all: the section would drop on its 401 anyway,
        // so the request is pure waste and a red line in the logs.
        if (SessionService.to.isSignedIn)
          StateOperation<List<SellerEntity>>(kStores, _loadFeaturedStores),
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
        AppRouter.toNamed(Routes.MARKETPLACE_PRODUCT,
            arguments: banner.productId);
      case BannerType.imageLink:
        final uri = Uri.tryParse(banner.linkUrl!);
        if (uri == null) return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Pull-to-refresh
  @override
  Future<void> refresh() async {
    await loadHomeData();
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

  /// First page of `GET /stores`, cut to [kStoresPreviewSize].
  ///
  /// The endpoint is paginated and the section is a preview, so the extra
  /// items are dropped here rather than in the widget — the state then holds
  /// exactly what is rendered.
  Future<AppState<List<SellerEntity>>> _loadFeaturedStores() async {
    final state = await Get.find<GetSellersUseCase>().call(
      const PaginationInput(page: 1, limit: kStoresPreviewSize),
    );

    return state.when(
      onInitial: () => const AppStateInitial<List<SellerEntity>>(),
      onLoading: () => const AppStateLoading<List<SellerEntity>>(),
      onSuccess: (paged, message) => AppStateSuccess(
        paged.items.take(kStoresPreviewSize).toList(),
        message: message,
      ),
      onError: (message, code) =>
          AppStateError<List<SellerEntity>>(message, code: code),
    );
  }
}
