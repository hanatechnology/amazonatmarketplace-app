import 'package:get/get.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../domain/usecases/marketplace/product/get_products_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_categories_use_case.dart';
import '../../../domain/usecases/marketplace/product/search_products_use_case.dart';

class HomeController extends BaseStateController<GetProductsUseCase> {
  // ── Operation keys ─────────────────────────────────────
  static const String kCategories = 'categories';
  static const String kProducts = 'products';
  static const String kSearch = 'search';

  // ── Local reactive state ───────────────────────────────
  final searchQuery = ''.obs;
  final activeBannerIndex = 0.obs;

  // ── Banner data (static for now, later from API) ───────
  final banners = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadBanners();
    loadHomeData();
  }

  void _loadBanners() {
    // TODO: Replace with API call when banner endpoint is ready
    banners.value = [
      {
        'title': 'new_collection',
        'subtitle': 'discount_banner',
        'cta': 'shop_now',
        'image': 'assets/images/banner_1.png',
      },
      {
        'title': 'new_collection',
        'subtitle': 'discount_banner',
        'cta': 'shop_now',
        'image': 'assets/images/banner_2.png',
      },
    ];
  }

  /// Load categories + products in parallel
  Future<void> loadHomeData() async {
    await handleMultipleStates({
      kCategories: () => Get.find<GetCategoriesUseCase>().execute(),
      kProducts: () => useCase.execute(),
    });
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
