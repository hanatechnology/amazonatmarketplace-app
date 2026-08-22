import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../domain/entities/marketplace/banner_entity.dart';
import '../../../domain/entities/marketplace/category_entity.dart';
import '../../../domain/entities/marketplace/product_entity.dart';
import '../../../domain/usecases/marketplace/banner/get_banners_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_products_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_categories_use_case.dart';
import '../../../domain/usecases/marketplace/product/search_products_use_case.dart';

class HomeController extends BaseStateController<GetProductsUseCase> {
  // ── Operation keys ─────────────────────────────────────
  static const String kCategories = 'categories';
  static const String kProducts = 'products';
  static const String kSearch = 'search';
  static const String kBanners = 'banners';

  // ── Local reactive state ───────────────────────────────
  final searchQuery = ''.obs;
  final activeBannerIndex = 0.obs;

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
    await handleMultipleStates([
      StateOperation<List<BannerEntity>>(
        kBanners,
        () => Get.find<GetBannersUseCase>().execute(),
      ),
      StateOperation<List<CategoryEntity>>(
        kCategories,
        () => Get.find<GetCategoriesUseCase>().execute(),
      ),
      StateOperation<List<ProductEntity>>(kProducts, () => useCase.execute()),
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
      // Reset to normal products
      await handleState(
        kProducts,
        () => useCase.execute(),
      );
      return;
    }
    await handleState(
      kSearch,
      () => Get.find<SearchProductsUseCase>().call(query),
    );
  }

  void onBannerChanged(int index) {
    activeBannerIndex.value = index;
  }
}
